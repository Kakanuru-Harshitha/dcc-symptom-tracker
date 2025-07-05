// lib/models/symptom.dart
class Symptom {
  final String type;
  final String location;
  final int severity;
  Symptom({
    required this.type,
    required this.location,
    required this.severity,
  });
  Map<String,dynamic> toMap() => {
        'type': type,
        'location': location,
        'severity': severity,
      };
  factory Symptom.fromMap(Map<String,dynamic> m) => Symptom(
        type: m['type'],
        location: m['location'],
        severity: m['severity'],
      );
}
