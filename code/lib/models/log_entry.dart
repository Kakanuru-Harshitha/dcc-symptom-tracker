// lib/models/log_entry.dart
import 'symptom.dart';
class LogEntry {
  int? id;
  DateTime date;
  List<Symptom> symptoms;
  String note;
  bool medsMorning;
  bool medsAfternoon;
  LogEntry({
    this.id,
    required this.date,
    required this.symptoms,
    required this.note,
    required this.medsMorning,
    required this.medsAfternoon,
  });
  Map<String,dynamic> toMap() => {
        'id': id,
        'date': date.millisecondsSinceEpoch,
        'symptoms': symptoms.map((s)=>s.toMap()).toList(),
        'note': note,
        'medsMorning': medsMorning?1:0,
        'medsAfternoon': medsAfternoon?1:0,
      };
  factory LogEntry.fromMap(Map<String,dynamic> m) => LogEntry(
        id: m['id'],
        date: DateTime.fromMillisecondsSinceEpoch(m['date']),
        symptoms: (m['symptoms'] as List)
            .map((x)=>Symptom.fromMap(Map<String,dynamic>.from(x)))
            .toList(),
        note: m['note'],
        medsMorning: m['medsMorning']==1,
        medsAfternoon: m['medsAfternoon']==1,
      );
}
