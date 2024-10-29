import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/borrow_model.dart';

class MyBorrowsScreen extends StatefulWidget {
  @override
  _MyBorrowsScreenState createState() => _MyBorrowsScreenState();
}

class _MyBorrowsScreenState extends State<MyBorrowsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Stream<List<Borrow>> _fetchUserBorrows() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('borrows')
        .where('borrowerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Borrow.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Borrows'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FadeTransition(
        opacity: _animation,
        child: StreamBuilder<List<Borrow>>(
          stream: _fetchUserBorrows(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching borrows'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No borrows found'));
            }

            final borrows = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: borrows.length,
              itemBuilder: (context, index) {
                final borrow = borrows[index];
                return _buildBorrowCard(borrow);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBorrowCard(Borrow borrow) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('books')
          .doc(borrow.bookId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        final bookData = snapshot.data!.data() as Map<String, dynamic>;
        final bookTitle = bookData['title'];
        final bookAuthor = bookData['author'];
        final bookImage = bookData['image'];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    bookImage,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  bookTitle,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Author: $bookAuthor'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Date: ${DateFormat('dd MMM, yyyy').format(borrow.startDate)}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Due: ${DateFormat('dd MMM, yyyy').format(borrow.returnDate)}',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Charge: BDT ${borrow.totalCharge.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      borrow.status.toString().toUpperCase().split('.').last,
                      style: TextStyle(
                        color: borrow.status == BorrowStatus.pending
                            ? Colors.orange
                            : borrow.status == BorrowStatus.borrowed
                                ? Colors.green
                                : Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        backgroundColor:
                            Colors.yellowAccent, // Highlight background
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
