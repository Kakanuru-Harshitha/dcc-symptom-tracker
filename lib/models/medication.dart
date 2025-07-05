// lib/models/medication.dart
class Medication {
  int? id;
  String name;
  String dosage;
  int timesPerDay;
  bool takenToday;
  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.timesPerDay,
    this.takenToday = false,
  });
  Map<String,dynamic> toMap() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'timesPerDay': timesPerDay,
        'takenToday': takenToday ? 1 : 0,
      };
  factory Medication.fromMap(Map<String,dynamic> m) => Medication(
        id: m['id'],
        name: m['name'],
        dosage: m['dosage'],
        timesPerDay: m['timesPerDay'],
        takenToday: m['takenToday']==1,
      );
}
