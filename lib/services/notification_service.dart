import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationSender {
  Future<void> sendNotification({
    required String deviceToken,
    required String title,
    required String body,
    required String accessToken,
  }) async {
    final url = 'https://fcm.googleapis.com/v1/projects/daycaremanager-3e38b/messages:send';

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    final payload = {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": title,
          "body": body,
        },
        "android": {
          "priority": "high",
        },
        "apns": {
          "headers": {
            "apns-priority": "10",
          },
        },
      },
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully!');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }
}
