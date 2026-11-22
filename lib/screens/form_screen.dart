import 'package:flutter/material.dart';
import '/database/dao_medication.dart';
import '/models/medication_model.dart';

class FormScreen extends StatefulWidget {
  final MedicationModel? medication;

  const FormScreen({super.key, this.medication});

  @override
  State<StatefulWidget> createState() {
    return _FormScreenState();
  }

}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  var _nameController = TextEditingController();
  var _dosageController = TextEditingController();
  var _scheduleController = TextEditingController();

  bool _isSaving = false;

  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication?.name ?? '');
    _dosageController = TextEditingController(text: widget.medication?.dosage ?? '');
    _scheduleController = TextEditingController(text: widget.medication?.schedule ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
    final name = _nameController.text.trim();
    final dosage = _dosageController.text.trim();
    final scheduleText = _scheduleController.text.trim();
    final schedule = scheduleText.isEmpty ? null : scheduleText;

    final medication = MedicationModel(
      id: widget.medication?.id ?? 0,
      name: name,
      dosage: dosage,
      schedule: schedule,
      is_taken: widget.medication?.is_taken ?? false,
      taken_at: widget.medication?.taken_at,
    );

    if (_isEditing) {
      await DaoMedication.updateMedication(medication);
    } else {
      await DaoMedication.addMedication(medication);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  } catch (e, stack) {
    debugPrint('ERRO AO SALVAR: $e');
    debugPrint('$stack');
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao salvar: $e')),
    );
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_isEditing ? 'Editar Medicamento' : 'Novo Medicamento'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do medicamento',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do medicamento';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: 'Dosagem (ex.: 500 mg, 1 comprimido)',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a dosagem';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _scheduleController,
                decoration: InputDecoration(
                  labelText: 'Horário ou observação (opcional)',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _saveMedication(),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMedication,
                  child: Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}