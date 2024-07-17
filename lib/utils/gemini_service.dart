import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';
import 'dart:math';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'date_utils.dart';

class GeminiService {
  List<TimePlannerTask> tasks;

  GeminiService(this.tasks);

  void addObject(BuildContext context) {
    List<Color?> colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.lime[600]
    ];

    tasks.add(
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

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Random task added to time planner!')));
  }

  Future<List<TimePlannerTask>?> handleQuestion(BuildContext context,
      String question, TextEditingController controller) async {
    controller.text = "LOADING...";
    String occupiedTimeSlots = "";
    for (int i = 0; i < tasks.length; i++) {
      TimePlannerDateTime day = tasks[i].dateTime;
      occupiedTimeSlots +=
          "A task is set on ${getDayOfWeek(day.day)} at ${day.hour}:${day.minutes} and lasts";
      occupiedTimeSlots +=
          " for ${tasks[i].minutesDuration.toString()} minutes. \n";
    }
    print(occupiedTimeSlots);

    final gemini = Gemini.instance;
    try {
      Candidates? geminiResponse = await gemini.text("""
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
      """);

      if (geminiResponse != null) {
        String responseString = geminiResponse.output!;
        List<String> responseSplit = responseString.split('\n');
        List<String> taskInfo = [];

        // print(responseSplit);

        List<Color?> colors = [
          Colors.purple,
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.lime[600]
        ];
        Color? colorForGroup = colors[Random().nextInt(colors.length)];

        for (String line in responseSplit) {
          if (!line.contains('TASK')) {
            if (taskInfo.isEmpty) {
              if (!['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                  .every((element) => !line.contains(element))) {
                taskInfo.add(line);
              }
            } else {
              taskInfo.add(line);
            }
          }

          if (taskInfo.length >= 6) {
            String dayOfWeek = taskInfo[0];
            List<String> startSplit = taskInfo[1].split(":");
            List<String> endSplit = taskInfo[2].split(":");

            DateTime startTime = DateTime(
                0, 0, 0, int.parse(startSplit[0]), int.parse(startSplit[1]));
            DateTime endTime = DateTime(
                0, 0, 0, int.parse(endSplit[0]), int.parse(endSplit[1]));
            int duration = getTimeDifferenceInMinutes(startTime, endTime);

            String taskHeader = taskInfo[3];
            print(taskInfo);
            TimePlannerTask taskToAdd = TimePlannerTask(
              color: colorForGroup,
              minutesDuration: duration,
              description: taskInfo[4],
              dateTime: TimePlannerDateTime(
                  day: getDayOfWeekFromString(dayOfWeek),
                  hour: int.parse(startSplit[0]),
                  minutes: int.parse(startSplit[1])),
              child: Text(
                taskHeader,
                style: TextStyle(color: Colors.grey[350], fontSize: 12),
              ),
            );
            tasks.add(taskToAdd);
            taskInfo.clear();
          }
        }

        controller.text = "";
        return tasks;
      }
    } catch (e) {
      print(e);
      throw (e);
    }
    return null;
  }
}
