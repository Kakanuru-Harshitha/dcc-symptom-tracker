// lib/services/report_service.dart
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart'; // ← NEW
import 'package:path_provider/path_provider.dart';
import '../models/log_entry.dart';
import '../models/medication.dart';

class ReportService {
  ReportService._internal();
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;

  Future<File> generate(
    List<LogEntry> logs,
    List<Medication> meds,
    DateTime from,
    DateTime to,
    String questions,
  ) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        build:
            (ctx) => [
              // Colourful header
              pw.Container(
                color: PdfColor.fromInt(0xff1E88E5), // ← use PdfColor.fromInt
                padding: const pw.EdgeInsets.all(12),
                child: pw.Center(
                  child: pw.Text(
                    'Symptom Tracker Report',
                    style: pw.TextStyle(
                      color: PdfColors.white, // ← use PdfColors.white
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Paragraph(
                text:
                    'Period: ${from.month}/${from.day}/${from.year} — '
                    '${to.month}/${to.day}/${to.year}',
              ),
              pw.SizedBox(height: 12),

              pw.Header(text: 'Symptoms'),
              _symptomsTable(logs),
              pw.SizedBox(height: 12),

              pw.Header(text: 'Medications'),
              _medsTable(meds),
              if (questions.trim().isNotEmpty) ...[
                pw.SizedBox(height: 12),
                pw.Header(text: 'Questions'),
                pw.Bullet(text: questions),
              ],
            ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/symptom_report.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  pw.Widget _symptomsTable(List<LogEntry> logs) {
    return pw.Table.fromTextArray(
      headers: ['Date', 'Type', 'Location', 'Severity'],
      data: [
        for (var l in logs)
          for (var s in l.symptoms)
            [
              '${l.date.month}/${l.date.day}/${l.date.year}',
              s.type,
              s.location.isEmpty ? '-' : s.location,
              s.severity.toString(),
            ],
      ],
    );
  }

  pw.Widget _medsTable(List<Medication> meds) {
    return pw.Table.fromTextArray(
      headers: ['Name', 'Dosage', 'Taken Today'],
      data: [
        for (var m in meds) [m.name, m.dosage, m.takenToday ? 'Yes' : 'No'],
      ],
    );
  }
}
