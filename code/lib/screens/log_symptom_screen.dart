// lib/screens/log_symptom_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/body_map.dart';
import '../widgets/severity_slider.dart';
import '../models/symptom.dart';
import '../models/log_entry.dart';
import '../providers/log_provider.dart';

class LogSymptomScreen extends StatefulWidget {
  const LogSymptomScreen({super.key});
  @override
  State<LogSymptomScreen> createState() => _LogSymptomScreenState();
}

class _LogSymptomScreenState extends State<LogSymptomScreen> {
  // The date for this entry (can be passed in via arguments)
  DateTime _date = DateTime.now();

  // Controllers
  final _noteC = TextEditingController();
  final _customC = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _allTypes = List.from(kSymptomTypes);
    _type = _allTypes.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If a DateTime was passed via Navigator arguments, use it
    final argDate = ModalRoute.of(context)?.settings.arguments;
    if (argDate is DateTime) {
      setState(() {
        _date = argDate;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
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
      appBar: AppBar(title: const Text('Log Symptom')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            // Date picker row
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

            // Symptom type + add custom
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

            // Location picker (only for certain types)
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
            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: () {
                // Build symptom list (with or without locations)
                final syms =
                    _needsLoc.contains(_type) && _locs.isNotEmpty
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
                  date: DateTime(
                    _date.year,
                    _date.month,
                    _date.day,
                  ), // chosen date
                  symptoms: syms,
                  note: _noteC.text.trim(),
                  medsMorning: _morn,
                  medsAfternoon: _aft,
                );
                context.read<LogProvider>().add(entry);
                Navigator.pop(context);
              },
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
