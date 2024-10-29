import 'package:cloud_firestore/cloud_firestore.dart';

enum BorrowStatus { pending, borrowed, returned }

class Borrow {
  final String docId;
  final String bookId;
  final String borrowerId;
  final DateTime startDate;
  final DateTime returnDate;
  final double totalCharge;
  final BorrowStatus status;

  Borrow({
    required this.docId,
    required this.status,
    required this.bookId,
    required this.borrowerId,
    required this.startDate,
    required this.returnDate,
    required this.totalCharge,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last,
      'bookId': bookId,
      'borrowerId': borrowerId,
      'startDate': Timestamp.fromDate(startDate),
      'returnDate': Timestamp.fromDate(returnDate),
      'totalCharge': totalCharge,
    };
  }

  factory Borrow.fromJson(Map<String, dynamic> json, String docID) {
    return Borrow(
      docId: docID,
      status: BorrowStatus.values
          .firstWhere((e) => e.toString().split('.').last == json['status']),
      bookId: json['bookId'],
      borrowerId: json['borrowerId'],
      startDate: (json['startDate'] as Timestamp).toDate(),
      returnDate: (json['returnDate'] as Timestamp).toDate(),
      totalCharge: json['totalCharge'],
    );
  }
}
