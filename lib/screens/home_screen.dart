import 'package:flutter/material.dart';
import '/models/medication_model.dart';
import '/database/dao_medication.dart';
import 'form_screen.dart';
import 'medication_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {

  List<MedicationModel> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  void _loadMedications() async {
    final list = await DaoMedication.getMedications();
    if (!mounted) return;
    setState(() {
      _medications = list;
    });
  }

  Future<void> _setTakenStatus(MedicationModel med, bool isTaken) async {
    await DaoMedication.updateTakenStatus(
      id: med.id,
      is_taken: isTaken,
      taken_at: isTaken ? DateTime.now().toIso8601String() : null,
    );

    _loadMedications();
  }

  Future<bool> _deleteMedication(MedicationModel med) async {
    final confirmed = await showDialog<bool> (
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Excluir medicamento'),
          content: Text(
            'Deseja realmente excluir "${med.name}" da lista?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return false;

    final result = await DaoMedication.removeMedication(med);
    _loadMedications();
    return result;
  }

  Future<void> _openForm({MedicationModel? medication}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormScreen(medication: medication),
      ),
    );

    if (saved == true) {
      _loadMedications();
    }
  }

  Future<void> _openDetail(MedicationModel med) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationDetailScreen(medication: med),
      ),
    );

    if (changed == true && mounted) {
      _loadMedications();
    }
  }

  String _formatTakenAt(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) {
      return '';
    }

    final dt = DateTime.tryParse(isoString);
    if (dt == null) {
      return isoString;
    }

    final local = dt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year às $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Meus Medicamentos'),
        
      ),
      body: _medications.isEmpty
        ? Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Nenhum medicamento cadastrado.\nToque no + para adicionar.',
              textAlign: TextAlign.center,
            ),
          ),
        )
      : ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: _medications.length,
        itemBuilder: (context, index) {
          final med = _medications[index];
          final formattedTakenAt = med.is_taken ? _formatTakenAt(med.taken_at) : '';
          final subtitleParts = <String>[
            med.dosage,
            if (med.schedule != null && med.schedule!.trim().isNotEmpty)
              med.schedule!.trim(),
            med.is_taken ? 'Status: Tomado' : 'Status: Não tomado',
          ];

          return Card(
            margin: EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _openDetail(med),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                med.name,
                                style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                              ),
                              SizedBox(height: 4),
                              Text(subtitleParts.join(' . ')),
                              if (formattedTakenAt.isNotEmpty) ...[
                                SizedBox(height: 4),
                                Text(
                                  'Tomado em : $formattedTakenAt',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined),
                        tooltip: 'Editar',
                        onPressed: () => _openForm(medication: med),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        tooltip: 'Excluir',
                        onPressed: () => _deleteMedication(med),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: med.is_taken
                          ? OutlinedButton(
                            onPressed: () => _setTakenStatus(med, false),
                            child: Text('Marcar não tomado'),
                          )
                        : ElevatedButton(
                          onPressed: () => _setTakenStatus(med, true),
                          child: Text('Marcar como tomado'),
                        ),
                      ),
                    ],
                  ),  
                ],
              ),              
            )
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        tooltip: 'Cadastrar medicamento',
        child: Icon(Icons.add),
      )
    );
  }
}