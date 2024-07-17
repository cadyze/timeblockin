import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:table_calendar/table_calendar.dart';
import 'config.dart';
import 'package:intl/intl.dart';
import 'package:time_planner/time_planner.dart';
import 'dart:math';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart' as ggc;
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

const String localHost = 'http://localhost:5000';
const String localHandler = 'http://localhost:5000/__/auth/handler';

String getHostUri() {
  return localHost;
}

String getHandlerUri() {
  return localHandler;
}

void main() {
  Gemini.init(apiKey: gemini_API_KEY);
  runApp(const MyApp());
}

List<TimePlannerTitle> getCurrentWeekDates() {
  List<TimePlannerTitle> titles = [];
  DateTime now = DateTime.now();
  int currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
  DateTime startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
  DateTime endOfWeek = now.add(Duration(days: 7 - currentWeekday));

  for (DateTime date = startOfWeek;
      date.isBefore(endOfWeek) || date.isAtSameMomentAs(endOfWeek);
      date = date.add(const Duration(days: 1))) {
    String formattedDate = DateFormat('EEEE, MMM d').format(date);
    titles.add(
        TimePlannerTitle(date: formattedDate, title: _getDayOfWeek(date.day)));
  }

  return titles;
}

String _getDayOfWeek(int day) {
  switch (day) {
    case 0:
      return 'SUN';
    case 1:
      return 'MON';
    case 2:
      return 'TUE';
    case 3:
      return 'WED';
    case 4:
      return 'THU';
    case 5:
      return 'FRI';
    case 6:
      return 'SAT';
    default:
      return '';
  }
}

int getDayOfWeekFromString(String day) {
  switch (day.toUpperCase()) {
    case 'SUN':
      return 0;
    case 'MON':
      return 1;
    case 'TUE':
      return 2;
    case 'WED':
      return 3;
    case 'THU':
      return 4;
    case 'FRI':
      return 5;
    case 'SAT':
      return 6;
    default:
      throw ArgumentError('Invalid day string: $day');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar UI w/ Gemini',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<TimePlannerTask> _tasks = [];

  void _addObject(BuildContext context) {
    List<Color?> colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.lime[600]
    ];

    setState(() {
      _tasks.add(
        TimePlannerTask(
          color: colors[Random().nextInt(colors.length)],
          dateTime: TimePlannerDateTime(
              day: Random().nextInt(14),
              hour: Random().nextInt(18) + 6,
              minutes: Random().nextInt(60)),
          minutesDuration: Random().nextInt(90) + 30,
          daysDuration: Random().nextInt(4) + 1,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('You click on time planner object')));
          },
          child: Text(
            'this is a demo',
            style: TextStyle(color: Colors.grey[350], fontSize: 12),
          ),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Random task added to time planner!')));
  }

  int getTimeDifferenceInMinutes(DateTime start, DateTime end) {
    Duration difference = end.difference(start);
    return difference.inMinutes;
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
                        startHour: 6,
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
                        String question = _controller.text;
                        _controller.text = "LOADING...";
                        String occupiedTimeSlots = "";
                        for (int i = 0; i < _tasks.length; i++) {
                          TimePlannerDateTime day = _tasks[i].dateTime;
                          occupiedTimeSlots +=
                              "A task is set on ${_getDayOfWeek(day.day)} at ${day.hour}:${day.minutes} and lasts";
                          occupiedTimeSlots +=
                              " for ${_tasks[i].minutesDuration.toString()} minutes. \n";
                        }
                        print(occupiedTimeSlots);
                        // Handle the question submission
                        final gemini = Gemini.instance;
                        gemini.text("""
                      The following timeslots are occupied:
                      $occupiedTimeSlots

                      and given the following question, create a plan to achieve it and split it into smaller tasks with the format provided. The created tasks must not overlap timeslots with the tasks given above under any condition. Fill out the task format below, replacing the text inside the {___}. For every day of the week, allow up to two different tasks to be created per day. Follow the options given in the (..., ...). Do not add your own text modifications such as bold, italics, or underlines.
                      Question:
                      $question
                      
                      Format:
                      
                      {TASK #} (cannot be blank, be the task number)
                      {DAY_OF_WEEK} (Options: MON, TUE, WED, THU, FRI, SAT, SUN)
                      {TIME_FROM} (cannot be blank answer on a 24:00 clock format)
                      {TIME_TO} (cannot be blank answer on a 24:00 clock format)
                      {EVENT_NAME} (cannot be blank)
                      {WHAT_TO_DO} (cannot be blank)
                      {SHOULD_REPEAT_WEEKLY} (only answer TRUE or FALSE)
                      
                      End Format:
                      
                      Example Answer Format:
                      TASK #1
                      MON
                      01:00
                      14:30
                      Go hiking
                      Find the nearest mountain and climb it.
                      FALSE
                    """).then((value) {
                          String? geminiResponse = value?.output;
                          print(geminiResponse);

                          if (geminiResponse != null) {
                            // Parse the response and add to Google Calendar
                            print(geminiResponse.split('\n'));
                            List<String> responseSplit =
                                geminiResponse.split('\n');
                            List<String> taskInfo = [];

                            List<Color?> colors = [
                              Colors.purple,
                              Colors.blue,
                              Colors.green,
                              Colors.orange,
                              Colors.lime[600]
                            ];
                            Color? colorForGroup =
                                colors[Random().nextInt(colors.length)];
                            // Loop through all the elements in order to get all the different tasks
                            for (int i = 0; i < responseSplit.length; i++) {
                              // Checks to see if there's a new given task and add the previous task then prepare for next task info.
                              if (!responseSplit[i].contains('TASK')) {
                                String line = responseSplit[i].trim();
                                if (taskInfo.isEmpty) {
                                  if (![
                                    'MON',
                                    'TUE',
                                    'WED',
                                    'THU',
                                    'FRI',
                                    'SAT',
                                    'SUN'
                                  ].every(
                                      (element) => !line.contains(element))) {
                                    taskInfo.add(line);
                                  }
                                } else {
                                  taskInfo.add(line);
                                }
                              }
                              if (taskInfo.length >= 6) {
                                // Implement previous task
                                String dayOfWeek = taskInfo[0];
                                List<String> startSplit =
                                    taskInfo[1].split(":");
                                List<String> endSplit = taskInfo[2].split(":");

                                DateTime startTime = DateTime(
                                    0,
                                    0,
                                    0,
                                    int.parse(startSplit[0]),
                                    int.parse(startSplit[1]));

                                DateTime endTime = DateTime(
                                    0,
                                    0,
                                    0,
                                    int.parse(endSplit[0]),
                                    int.parse(endSplit[1]));
                                int duration = getTimeDifferenceInMinutes(
                                    startTime, endTime);

                                String taskHeader = taskInfo[3];
                                TimePlannerTask taskToAdd = TimePlannerTask(
                                  color: colorForGroup,
                                  minutesDuration: (duration),
                                  description: taskInfo[4],
                                  dateTime: TimePlannerDateTime(
                                      day: getDayOfWeekFromString(dayOfWeek),
                                      hour: int.parse(startSplit[0]),
                                      minutes: int.parse(startSplit[1])),
                                  child: Text(
                                    taskHeader,
                                    style: TextStyle(
                                        color: Colors.grey[350], fontSize: 12),
                                  ),
                                );
                                setState(() {
                                  _tasks.add(taskToAdd);
                                });
                                print(
                                    "ADDED TASK with $taskInfo, and a duration of $duration.");
                                taskInfo.clear();
                                _controller.text = "";
                              }
                            }
                          }
                        }).catchError((e) => print(e));
                        print('Question: $question');
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

final GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '[YOUR_OAUTH_2_CLIENT_ID]',
  scopes: <String>[ggc.CalendarApi.calendarScope],
);

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> { 
  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleGetContact() async {
    setState(() {
      _contactText = 'Loading contact info...';
    });

    // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();

    assert(client != null, 'Authenticated client missing!');

    // Prepare a People Service authenticated client.
    final ggc.CalendarApi calendarApi = ggc.CalendarApi(client!);
    // Retrieve a list of the `names` of my `connections`
    // TODO: Do a response from a calendar

    setState(() {});
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error); // ignore: avoid_print
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text('Signed in successfully.'),
          Text(_contactText),
          ElevatedButton(
            onPressed: _handleSignOut,
            child: const Text('SIGN OUT'),
          ),
          ElevatedButton(
            onPressed: _handleGetContact,
            child: const Text('REFRESH'),
          ),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          const Text('You are not currently signed in.'),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('SIGN IN'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign In + googleapis'),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ),
      ),
    );
  }
}
