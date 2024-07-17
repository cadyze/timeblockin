import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_planner/time_planner.dart';
import '../utils/date_utils.dart';
import '../utils/gemini_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TextEditingController _controller = TextEditingController();

  List<TimePlannerTask> _tasks = [];      
  late final GeminiService _geminiService;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(_tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Flutter Calendar UI w/ Gemini')),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                    width: double.infinity,
                    height: 500,
                    child: Center(
                      child: TimePlanner(
                        startHour: 0,
                        endHour: 23,
                        use24HourFormat: false,
                        setTimeOnAxis: false,
                        style: TimePlannerStyle(
                          cellHeight: 40,
                          cellWidth:
                              (MediaQuery.of(context).size.width / 7.5).round(),
                          showScrollBar: true,
                          interstitialEvenColor: Colors.grey[50],
                          interstitialOddColor: Colors.grey[200],
                        ),
                        headers: getCurrentWeekDates(),
                        tasks: _tasks,
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          labelText: 'What do you want to achieve?',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _geminiService.handleQuestion(context, _controller.text, _controller).then((List<TimePlannerTask>? tasks) {
                          if(tasks != null) {
                            setState(() {
                              _tasks = tasks;                              
                            });
                          }
                        });
                        
                        },
                      child: const Text('Ask Gemini'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
