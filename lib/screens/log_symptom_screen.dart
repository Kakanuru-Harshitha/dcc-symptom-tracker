// lib/screens/log_symptom_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/constants.dart';
import '../widgets/body_map.dart';
import '../widgets/severity_slider.dart';
import '../models/symptom.dart';
import '../models/log_entry.dart';
import '../models/daily_metrics.dart';
import '../providers/log_provider.dart';
import '../models/metrics_provider.dart';

class LogSymptomScreen extends StatefulWidget {
  final LogEntry? entry;
  final int? index;

  const LogSymptomScreen({super.key, this.entry, this.index});

  @override
  State<LogSymptomScreen> createState() => _LogSymptomScreenState();
}

class _LogSymptomScreenState extends State<LogSymptomScreen> {
  // The date for this entry (can be passed in via arguments)
  DateTime _date = DateTime.now();

  // Controllers
  final _noteC = TextEditingController();
  final _customC = TextEditingController();
  final _dietC = TextEditingController();
  final _trigC = TextEditingController();

  // Symptom type & custom list
  late List<String> _allTypes;
  String _type = '';

  // For types requiring a body location
  static const _needsLoc = {'Pain', 'Fatigue'};
  Set<String> _locs = {};

  // Severity slider
  int _sev = 5;

  // Medication checkboxes
  bool _morn = false, _aft = false;

  // Daily‐context fields
  double _sleepH = 7;
  int _sleepQ = 6;
  int _exerciseMin = 0;
  int _stress = 5;
  int _mood = 5;

  @override
  void initState() {
    super.initState();
    _allTypes = List.from(kSymptomTypes);
    _type = _allTypes.first;

    // If we're editing an existing entry, prepopulate fields:
    final e = widget.entry;
    if (e != null) {
      _date = e.date;
      _noteC.text = e.note;
      _morn = e.medsMorning;
      _aft = e.medsAfternoon;

      // symptoms
      final firstSym = e.symptoms.first;
      _type = firstSym.type;
      _sev = firstSym.severity;
      if (_needsLoc.contains(_type)) {
        _locs = e.symptoms.map((s) => s.location).toSet();
      }

      // daily‐metrics (if any)
      final metrics = context.read<MetricsProvider>().forDate(_date);
      if (metrics != null) {
        _sleepH = metrics.sleepHours;
        _sleepQ = metrics.sleepQuality;
        _exerciseMin = metrics.exerciseMinutes;
        _stress = metrics.stressLevel;
        _mood = metrics.moodRating;
        _dietC.text = metrics.dietNotes;
        _trigC.text = metrics.triggers;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argDate = ModalRoute.of(context)?.settings.arguments;
    if (argDate is DateTime && widget.entry == null) {
      _date = argDate;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _showCustomDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add custom symptom'),
            content: TextField(
              controller: _customC,
              decoration: const InputDecoration(labelText: 'Symptom name'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final txt = _customC.text.trim();
                  if (txt.isNotEmpty && !_allTypes.contains(txt)) {
                    setState(() {
                      _allTypes.add(txt);
                      _type = txt;
                      if (!_needsLoc.contains(_type)) _locs.clear();
                    });
                  }
                  _customC.clear();
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Log Symptom' : 'Edit Symptom'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            // Date picker
            Row(
              children: [
                const Icon(Icons.calendar_month),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(
                    '${_date.month}/${_date.day}/${_date.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Symptom type + custom
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Type'),
                    value: _type,
                    items:
                        _allTypes
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                    onChanged:
                        (v) => setState(() {
                          _type = v!;
                          if (!_needsLoc.contains(_type)) _locs.clear();
                        }),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _showCustomDialog,
                  tooltip: 'Add custom symptom',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location picker
            if (_needsLoc.contains(_type)) ...[
              const Text('Locations'),
              const SizedBox(height: 8),
              BodyMap(
                selected: _locs,
                onChanged: (s) => setState(() => _locs = s),
              ),
              const SizedBox(height: 16),
            ],

            // Severity slider
            SeveritySlider(
              value: _sev,
              onChanged: (v) => setState(() => _sev = v),
            ),
            const SizedBox(height: 16),

            // Note field
            TextField(
              controller: _noteC,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Medication checkboxes
            CheckboxListTile(
              title: const Text('Morning meds taken'),
              value: _morn,
              onChanged: (v) => setState(() => _morn = v!),
            ),
            CheckboxListTile(
              title: const Text('Afternoon meds taken'),
              value: _aft,
              onChanged: (v) => setState(() => _aft = v!),
            ),

            // Daily context inputs
            const Divider(),
            const Text(
              'Daily context',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _sliderRow(
              'Sleep hours',
              _sleepH,
              0,
              12,
              (v) => setState(() => _sleepH = v),
            ),
            _sliderRow(
              'Sleep quality',
              _sleepQ.toDouble(),
              1,
              10,
              (v) => setState(() => _sleepQ = v.toInt()),
            ),
            _sliderRow(
              'Exercise (min)',
              _exerciseMin.toDouble(),
              0,
              180,
              (v) => setState(() => _exerciseMin = v.toInt()),
            ),
            _sliderRow(
              'Stress (1-10)',
              _stress.toDouble(),
              1,
              10,
              (v) => setState(() => _stress = v.toInt()),
            ),
            _sliderRow(
              'Mood (1-10)',
              _mood.toDouble(),
              1,
              10,
              (v) => setState(() => _mood = v.toInt()),
            ),

            TextField(
              controller: _dietC,
              decoration: const InputDecoration(labelText: 'Diet notes (tags)'),
            ),
            TextField(
              controller: _trigC,
              decoration: const InputDecoration(
                labelText: 'Triggers / context',
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: () {
                // Build symptom list
                final syms =
                    (_needsLoc.contains(_type) && _locs.isNotEmpty)
                        ? _locs
                            .map(
                              (loc) => Symptom(
                                type: _type,
                                location: loc,
                                severity: _sev,
                              ),
                            )
                            .toList()
                        : [Symptom(type: _type, location: '', severity: _sev)];

                final entry = LogEntry(
                  date: DateTime(_date.year, _date.month, _date.day),
                  symptoms: syms,
                  note: _noteC.text.trim(),
                  medsMorning: _morn,
                  medsAfternoon: _aft,
                );

                final logProv = context.read<LogProvider>();
                // either update or add
                if (widget.index != null) {
                  logProv.updateAt(widget.index!, entry);
                } else {
                  logProv.add(entry);
                }

                // Upsert metrics
                final metricsProv = context.read<MetricsProvider>();
                final m =
                    metricsProv.forDate(_date) ?? DailyMetrics(date: _date);
                m
                  ..sleepHours = _sleepH
                  ..sleepQuality = _sleepQ
                  ..exerciseMinutes = _exerciseMin
                  ..stressLevel = _stress
                  ..moodRating = _mood
                  ..dietNotes = _dietC.text.trim()
                  ..triggers = _trigC.text.trim();
                metricsProv.upsert(m);

                Navigator.pop(context);
              },
              child: Text(widget.entry == null ? 'Save Entry' : 'Update Entry'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the daily‐context sliders
  Widget _sliderRow(
    String label,
    double val,
    double min,
    double max,
    ValueChanged<double> cb,
  ) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label)),
        Expanded(
          child: Slider(
            value: val,
            min: min,
            max: max,
            divisions: max.toInt(),
            label: val.round().toString(),
            onChanged: cb,
          ),
        ),
      ],
    );
  }
}
