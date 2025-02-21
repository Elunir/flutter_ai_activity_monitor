import 'dart:convert';
import 'package:activity_monitoring/activity_monitoring/service/database_service.dart';
import 'package:activity_monitoring/activity_monitoring/service/usage_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QueryScreen extends StatefulWidget {
  @override
  _QueryScreenState createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isFetchingStats = false;
  String _selectedFilter = "day"; // Default filter to "day"

  @override
  void initState() {
    super.initState();
  }

  /// Asks AI about phone usage based on stored logs
  Future<void> askAI(String question) async {
    if (_isFetchingStats) {
      setState(() {
        _response = "⏳ Please wait, fetching usage data...";
      });
      return;
    }

    setState(() {
      _isFetchingStats = true;
    });

    final logs = await DatabaseService.instance.fetchUsageData(_selectedFilter);
    final activityData = logs.map((e) => "${e['package_name']}: ${e['duration']} ms").join(", ");

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.119:11434/v1/chat/completions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'llama3.2:latest',
          'messages': [
            {'role': 'system', 'content': 'You are an AI assistant that analyzes app usage history.'},
            {'role': 'user', 'content': 'Activity Log: $activityData.\n\nQuestion: $question'}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _response = data['choices'][0]['message']['content']?.toString() ?? 'No response received.';
        });
      } else {
        setState(() {
          _response = "⚠️ API Error: ${response.statusCode} - ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "⚠️ Network error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isFetchingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Activity Assistant')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Ask about your phone activity'),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
                items: [
                  DropdownMenuItem(value: "day", child: Text("Today")),
                  DropdownMenuItem(value: "month", child: Text("This Month")),
                  DropdownMenuItem(value: "year", child: Text("This Year")),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => askAI(_controller.text),
                child: const Text('Ask AI'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await UsageStatsService.trackAppUsage();
                  setState(() {});
                },
                child: const Text('Refresh App Usage Stats'),
              ),
              const SizedBox(height: 20),
              Text('Response:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(_response, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
