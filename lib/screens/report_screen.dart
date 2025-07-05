// lib/screens/report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/log_provider.dart';
import '../providers/med_provider.dart';
import '../services/report_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 7));
  DateTime _to = DateTime.now();
  final _qC = TextEditingController();

  Future<void> _pickFrom() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: _from,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (dt != null) setState(() => _from = dt);
  }

  Future<void> _pickTo() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: _to,
      firstDate: _from,
      lastDate: DateTime.now(),
    );
    if (dt != null) setState(() => _to = dt);
  }

  @override
  Widget build(BuildContext context) {
    final logs = context.read<LogProvider>().logs;
    final meds = context.read<MedProvider>().meds;

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Report')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _pickFrom,
                  child: Text('From: ${_from.toLocal()}'.split(' ')[0]),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: _pickTo,
                  child: Text('To:   ${_to.toLocal()}'.split(' ')[0]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _qC,
            decoration: const InputDecoration(labelText: 'Questions for Doctor'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Build & Share PDF'),
            onPressed: () async {
              final file = await ReportService()
                  .generate(logs, meds, _from, _to, _qC.text);
              await Share.shareXFiles([XFile(file.path)],
                  text: 'My Symptom Report');
            },
          ),
        ],
      ),
    );
  }
}
