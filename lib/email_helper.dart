import 'package:elmouaddibe_examen/books_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final String username = 'tanvirrobin0@gmail.com';
  final String password = 'fkvawdrjzgnklheb';

  // Method to send Book Borrow Confirmation email
  Future<void> sendConfirmation(String receiverEmail, Book book) async {
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 465,
      ssl: true,
      username: username,
      password: password,
    );

    final message = Message()
      ..from = Address(username, 'PSTU Library')
      ..recipients.add(receiverEmail)
      ..subject = 'Confirmation of Your Book Borrowing - ${book.title}'
      ..html = '''
    <div style="font-family: Helvetica, Arial, sans-serif; line-height: 1.6; color: #333;">
      <div style="margin: 20px auto; width: 80%; padding: 20px; border: 1px solid #ddd; border-radius: 8px;">
        <h2 style="color: #00466a;">PSTU Library - Book Borrowing Confirmation</h2>
        <p>Dear ${FirebaseAuth.instance.currentUser!.displayName},</p>
        <p>We are pleased to inform you that your request to borrow the book has been received. Below are the details of the borrowed book:</p>
        
        <div style="margin: 15px 0; padding: 15px; background-color: #f9f9f9; border-radius: 6px;">
          <p><strong>Title:</strong> ${book.title}</p>
          <p><strong>Author:</strong> ${book.author}</p>
          <p><strong>Charge:</strong>BDT ${book.charge.toStringAsFixed(2)}</p>
          <p><strong>Availability:</strong> ${book.quantityInStock > 0 ? "Available" : "Out of Stock"}</p>
        </div>
        
        <p>Please remember to return the book within the borrowing period to avoid additional charges. If you need any further assistance, feel free to contact us.</p>
        
        <p style="font-size: 0.9em; color: #555;">Thank you for choosing our library services!</p>
        
        <p style="font-size: 0.9em;">Regards,<br>PSTU Library Team</p>
        <hr style="border-top: 1px solid #ddd;">
        <p style="font-size: 0.8em; color: #999;">PSTU Library | Bangladesh</p>
      </div>
    </div>
    ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Confirmation email sent: $sendReport');
    } on MailerException catch (e) {
      print('Confirmation email not sent. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  // Method to send Book Return Confirmation email
  Future<void> sendReturnConfirmation(String receiverEmail, Book book) async {
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 465,
      ssl: true,
      username: username,
      password: password,
    );

    final message = Message()
      ..from = Address(username, 'PSTU Library')
      ..recipients.add(receiverEmail)
      ..subject = 'Thank You for Returning the Book - ${book.title}'
      ..html = '''
    <div style="font-family: Helvetica, Arial, sans-serif; line-height: 1.6; color: #333;">
      <div style="margin: 20px auto; width: 80%; padding: 20px; border: 1px solid #ddd; border-radius: 8px;">
        <h2 style="color: #00466a;">PSTU Library - Book Return Confirmation</h2>
        <p>Dear,</p>
        <p>Thank you for returning the book. We appreciate your promptness in returning it to the PSTU Library.</p>
        
        <div style="margin: 15px 0; padding: 15px; background-color: #f9f9f9; border-radius: 6px;">
          <p><strong>Title:</strong> ${book.title}</p>
          <p><strong>Author:</strong> ${book.author}</p>
          <p><strong>Charge:</strong>BDT ${book.charge.toStringAsFixed(2)}</p>
        </div>
        
        <p>If you have any further questions or need assistance, feel free to reach out to us.</p>
        
        <p style="font-size: 0.9em; color: #555;">We look forward to seeing you again!</p>
        
        <p style="font-size: 0.9em;">Regards,<br>PSTU Library Team</p>
        <hr style="border-top: 1px solid #ddd;">
        <p style="font-size: 0.8em; color: #999;">PSTU Library | Bangladesh</p>
      </div>
    </div>
    ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Return confirmation email sent: $sendReport');
    } on MailerException catch (e) {
      print('Return confirmation email not sent. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
