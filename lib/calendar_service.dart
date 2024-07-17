import 'package:googleapis/calendar/v3.dart' as calendar;
import 'auth.dart';

class CalendarService {
  Future<List<calendar.Event>> getEvents() async {
    final authClient = await Auth.obtainCredentials();
    final calendarApi = calendar.CalendarApi(authClient);

    final events = await calendarApi.events.list('primary');
    return events.items ?? [];
  }
}
