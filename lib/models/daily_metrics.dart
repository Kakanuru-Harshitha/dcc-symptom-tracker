import 'package:hive/hive.dart';

// part 'daily_metrics.g.dart'; // keeps IDE happy – file generated below

@HiveType(typeId: 0)
class DailyMetrics {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double sleepHours;
  @HiveField(2)
  int sleepQuality; // 1-10
  @HiveField(3)
  int exerciseMinutes; // 0-180+
  @HiveField(4)
  int stressLevel; // 1-10
  @HiveField(5)
  int moodRating; // 1-10
  @HiveField(6)
  String dietNotes;
  @HiveField(7)
  String triggers;
  @HiveField(8)
  String weather;

  // medication adherence
  @HiveField(9)
  List<int> medTimesEpoch; // epoch ms
  @HiveField(10)
  int sideEffectRate; // 1-10

  DailyMetrics({
    required this.date,
    this.sleepHours = 0,
    this.sleepQuality = 5,
    this.exerciseMinutes = 0,
    this.stressLevel = 5,
    this.moodRating = 5,
    this.dietNotes = '',
    this.triggers = '',
    this.weather = '',
    List<int>? medTimesEpoch,
    this.sideEffectRate = 5,
  }) : medTimesEpoch = medTimesEpoch ?? [];

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'sleep_h': sleepHours,
    'sleep_quality': sleepQuality,
    'exercise_min': exerciseMinutes,
    'stress': stressLevel,
    'mood': moodRating,
    'diet': dietNotes,
    'triggers': triggers,
    'weather': weather,
    'med_times': medTimesEpoch,
    'side_effect': sideEffectRate,
  };
}

/// Hand-written adapter so we don’t need build_runner
class DailyMetricsAdapter extends TypeAdapter<DailyMetrics> {
  @override
  final int typeId = 0;

  @override
  DailyMetrics read(BinaryReader r) {
    return DailyMetrics(
      date: DateTime.fromMillisecondsSinceEpoch(r.readInt()),
      sleepHours: r.readDouble(),
      sleepQuality: r.readInt(),
      exerciseMinutes: r.readInt(),
      stressLevel: r.readInt(),
      moodRating: r.readInt(),
      dietNotes: r.readString(),
      triggers: r.readString(),
      weather: r.readString(),
      medTimesEpoch: (r.readList().cast<int>()),
      sideEffectRate: r.readInt(),
    );
  }

  @override
  void write(BinaryWriter w, DailyMetrics m) {
    w
      ..writeInt(m.date.millisecondsSinceEpoch)
      ..writeDouble(m.sleepHours)
      ..writeInt(m.sleepQuality)
      ..writeInt(m.exerciseMinutes)
      ..writeInt(m.stressLevel)
      ..writeInt(m.moodRating)
      ..writeString(m.dietNotes)
      ..writeString(m.triggers)
      ..writeString(m.weather)
      ..writeList(m.medTimesEpoch)
      ..writeInt(m.sideEffectRate);
  }
}
