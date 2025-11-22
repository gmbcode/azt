import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class MailService {
  /// Sends an email by calling our local Python proxy server.
  /// This avoids CORS issues on the Web.
  static Future<void> sendStatusUpdateEmail(
      String recipientEmail, String recipientName, String orderId, String newStatus) async {
    
    // Determine the correct URL for the local server
    String baseUrl;
    if (kIsWeb) {
      // For Web, localhost is 127.0.0.1
      baseUrl = 'https://upbound-nena-noncritical.ngrok-free.dev'; 
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // For Android Emulator, localhost is 10.0.2.2
      baseUrl = 'http://upbound-nena-noncritical.ngrok-free.dev';
    } else {
      // For iOS Simulator, localhost is 127.0.0.1
      baseUrl = 'http://upbound-nena-noncritical.ngrok-free.dev';
    }

    final Uri url = Uri.parse('$baseUrl/send-email');

    try {
      print("📨 Sending request to local server: $url");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "recipient_email": recipientEmail,
          "recipient_name": recipientName,
          "order_id": orderId,
          "new_status": newStatus
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Email sent successfully via local server!");
      } else {
        print("❌ Server error: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("❌ Connection error: $e");
      if (kIsWeb) {
        print("👉 Make sure your Python server is running (python server.py)");
      } else {
        print("👉 Make sure your Python server is running and your emulator can reach it.");
      }
    }
  }
}