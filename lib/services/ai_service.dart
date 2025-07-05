import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/log_entry.dart';
import '../models/daily_metrics.dart';

class AiService {
  AiService._internal();
  static final instance = AiService._internal();
  factory AiService() => instance;

  // API key should be passed securely, not hardcoded
  static const _apiKey = String.fromEnvironment('OPENAI_API_KEY');

  Future<String> generateInsight(
    List<LogEntry> logs,
    List<DailyMetrics> metrics,
    DateTime from,
    DateTime to,
  ) async {
    final payload = {
      'logs': logs.map((l) => l.toMap()).toList(),
      'metrics': metrics.map((m) => m.toJson()).toList(),
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    };

    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a health-tracking assistant. Return concise insights.'
        },
        {
          'role': 'user',
          'content': jsonEncode(payload)
        }
      ],
      'max_tokens': 180,
      'temperature': 0.7
    });

    final resp = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: body,
    );

    if (resp.statusCode != 200) {
      throw Exception('OpenAI error: ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    return decoded['choices'][0]['message']['content'].toString().trim();
  }
}
