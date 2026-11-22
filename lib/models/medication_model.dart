class MedicationModel {
  int id;
  String name;
  String dosage;
  String? schedule;
  bool is_taken;
  String? taken_at;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.is_taken,
    required this.taken_at
  });

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      schedule: map['schedule'],
      is_taken: map['is_taken'] == 1 || map['is_taken'] == true,
      taken_at: map['taken_at'],
    );
  }
}