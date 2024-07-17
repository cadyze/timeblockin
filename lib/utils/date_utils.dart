import 'package:intl/intl.dart';
import 'package:time_planner/time_planner.dart';

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
        TimePlannerTitle(date: formattedDate, title: getDayOfWeek(date.day)));
  }

  return titles;
}

String getDayOfWeek(int day) {
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

int getTimeDifferenceInMinutes(DateTime start, DateTime end) {
  Duration difference = end.difference(start);
  return difference.inMinutes;
}
