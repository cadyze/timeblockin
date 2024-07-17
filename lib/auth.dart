import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';

class Auth {
  static const _scopes = [calendar.CalendarApi.calendarScope];

  static Future<AutoRefreshingAuthClient> obtainCredentials() async {
    final clientId = ClientId('292109056049-aemcmmhobhb0vv5tm1l8unv0pf9l6h1i.apps.googleusercontent.com', '');
    return await clientViaUserConsent(clientId, _scopes, _prompt);
  }

  static void _prompt(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
