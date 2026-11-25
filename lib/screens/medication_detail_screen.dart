import 'package:flutter/material.dart';
import '/database/dao_medication.dart';
import '/models/medication_model.dart';
import 'form_screen.dart';

class MedicationDetailScreen extends StatefulWidget {
  final MedicationModel medication;

  const MedicationDetailScreen({super.key, required this.medication});

  @override
  State<StatefulWidget> createState() {
    return _MedicationDetailScreenState();
  }

}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  late MedicationModel _medication;
  bool _hasChanges = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _medication = widget.medication;
  }

  String _formatTakenAt(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) {
      return 'Ainda não registrado';
    }

    final dt = DateTime.tryParse(isoString);
    if (dt == null) {
      return isoString;
    }

    final local = dt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2,'0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year às $hour:$minute';
  }

  Future<void> _refreshMedication() async {
    final list = await DaoMedication.getMedications();
    if (!mounted) return;

    for (final item in list) {
      if (item.id == _medication.id) {
        setState(() {
          _medication = item;
        });
        break;
      }
    }
  }

  Future<void> _toggleTakenStatus() async {
    if (_medication.id == null || _isUpdating) return;

    setState(() {
      _isUpdating= true;
    });

    try {
      final nextTaken = !_medication.is_taken;
      final nextTakenAt = nextTaken ? DateTime.now().toIso8601String() : null;

      await DaoMedication.updateTakenStatus(
        id: _medication.id,
        is_taken: nextTaken,
        taken_at: nextTakenAt,
      );

      if (!mounted) return;

      await _refreshMedication();
      if (!mounted) return;

      setState(() {
        _hasChanges = true;
      });
    } catch (error, stack) {
      debugPrint('ERRO AO ATUALIZAR: $error');
      debugPrint('$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar status: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _openEditForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormScreen(medication: _medication),
      ),
    );

    if (saved == true && mounted) {
      _hasChanges = true;
      await _refreshMedication();
    }
  }

  Future<void> _popWithResult() async {
    Navigator.pop(context, _hasChanges);
  }

  @override
  Widget build(BuildContext context) {
    final scheduleText =
      (_medication.schedule != null && _medication.schedule!.trim().isNotEmpty)
        ? _medication.schedule!.trim()
        : 'Não informado';

    final takenAtText = _medication.is_taken
      ? _formatTakenAt(_medication.taken_at)
      : 'Não marcado como tomado';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _popWithResult();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Detalhes do Medicamento'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _popWithResult,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              tooltip: 'Editar',
              onPressed: _openEditForm,
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _medication.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 16),
                      _DetailRow(label: 'Dosagem', value: _medication.dosage),
                      SizedBox(height: 10),
                      _DetailRow(label: 'Horário / Obs.', value: scheduleText),
                      SizedBox(height: 10),
                      _DetailRow(
                        label: 'Status',
                        value: _medication.is_taken ? 'Tomado' : 'Não tomado',
                      ),
                      SizedBox(height: 10),
                      _DetailRow(label: 'Registrado em', value: takenAtText),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: _medication.is_taken
                  ? OutlinedButton.icon(
                    onPressed: _isUpdating ? null : _toggleTakenStatus,
                    icon: Icon(Icons.undo),
                    label: Text('Marcar como não tomado'),
                  )
                  : ElevatedButton.icon(
                    onPressed: _isUpdating ? null : _toggleTakenStatus,
                    icon: Icon(Icons.check),
                    label: Text('Marcar como tomado'),
                  ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openEditForm,
                  icon: Icon(Icons.edit_outlined),
                  label: Text('Editar medicamento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}