import 'package:mailjet/mailjet.dart';

class MailService {
  static const String apiKey = "a733cabf8e5af56567d5cc0c39992c9e";
  static const String secretKey = "8d957c6dc19904630f615febf0b37265";
  static const String myEmail = "csawebsitemanager@gmail.com";

  static Future<void> sendStatusUpdateEmail(String recipientEmail, String recipientName, String orderId, String newStatus) async {
    try {
      MailJet mailJet = MailJet(apiKey: apiKey, secretKey: secretKey);
      
      await mailJet.sendEmail(
        subject: "Order #$orderId Status Update",
        sender: Sender(email: myEmail, name: "AZT App"),
        reciepients: [
          Recipient(email: recipientEmail, name: recipientName),
        ],
        htmlEmail: "<h3>Order Update</h3><p>Your order <b>#$orderId</b> status has been changed to: <b>$newStatus</b></p>",
      );
      print("Email sent to $recipientEmail");
    } catch (e) {
      print("Failed to send email: $e");
    }
  }
}