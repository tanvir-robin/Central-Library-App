import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elmouaddibe_examen/books_screen.dart';
import 'package:elmouaddibe_examen/email_helper.dart';
import 'package:elmouaddibe_examen/models/borrow_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class BorrowBookScreen extends StatefulWidget {
  final Book book;

  const BorrowBookScreen({super.key, required this.book});

  @override
  _BorrowBookScreenState createState() => _BorrowBookScreenState();
}

class _BorrowBookScreenState extends State<BorrowBookScreen>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  String selectedPeriod = '3 Days';
  late double totalCharge;
  late DateTime returnDate;
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> periods = [
    '3 Days',
    '7 Days',
    '10 Days',
    '14 Days',
    '21 Days',
    '28 Days'
  ];

  @override
  void initState() {
    super.initState();
    _calculateReturnDateAndCharge();
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

  void _calculateReturnDateAndCharge() {
    int days = int.parse(selectedPeriod.split(' ')[0]);
    returnDate = selectedDate.add(Duration(days: days));
    totalCharge = widget.book.charge * (days > 14 ? 1.5 : 1.0);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _calculateReturnDateAndCharge();
      });
    }
  }

  void _onPeriodChanged(String? newPeriod) {
    setState(() {
      selectedPeriod = newPeriod!;
      _calculateReturnDateAndCharge();
    });
  }

  void _borrowBook() async {
    EasyLoading.show(status: 'Loading...');
    final borrow = Borrow(
      docId: '',
      status: BorrowStatus.pending,
      bookId: widget.book.docID!,
      borrowerId: FirebaseAuth.instance.currentUser!.uid,
      startDate: selectedDate,
      returnDate: returnDate,
      totalCharge: totalCharge,
    );

    await FirebaseFirestore.instance.collection('borrows').add(borrow.toJson());

    // Generate the PDF file
    final pdfData = await generatePdf(
      FirebaseAuth.instance.currentUser!.displayName!,
      widget.book.title,
      widget.book.author,
      selectedDate,
      returnDate,
      totalCharge,
    );

    // Save the PDF file to device storage
    final pdfFile = await savePdfToFile(pdfData, widget.book.title);

    await EmailService().sendConfirmation(
      FirebaseAuth.instance.currentUser!.email!,
      widget.book,
      pdfFile,
    );

    // Decrease the quantity in stock
    final bookRef =
        FirebaseFirestore.instance.collection('books').doc(widget.book.docID);
    await bookRef.update({
      'quantityInStock': FieldValue.increment(-1),
    });

    EasyLoading.dismiss();
    Navigator.pop(context);
  }

// Save the PDF to a file on the device
  Future<File> savePdfToFile(Uint8List pdfData, String bookTitle) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/${bookTitle.replaceAll(' ', '_')}_Certification.pdf';
    final file = File(filePath);

    await file.writeAsBytes(pdfData);
    return file;
  }

  Future<Uint8List> generatePdf(
      String customerName,
      String title,
      String author,
      DateTime startDate,
      DateTime returnDate,
      double totalCharge) async {
    final pdf = pw.Document();

    // Define custom styles
    final headerStyle = pw.TextStyle(
        fontSize: 20,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#00466a'));
    final subHeaderStyle = pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#333333'));
    final normalTextStyle =
        pw.TextStyle(fontSize: 12, color: PdfColor.fromHex('#333333'));
    final boldTextStyle = pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#333333'));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Library Heading
              pw.Container(
                padding: pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Column(
                  children: [
                    pw.Text('PSTU Central Library', style: headerStyle),
                    pw.Text('Patuakhali Science and Technology University',
                        style: subHeaderStyle),
                  ],
                ),
              ),
              pw.Divider(color: PdfColor.fromHex('#00466a'), thickness: 2),
              pw.SizedBox(height: 15),
              // Customer Borrow Acknowledgement Title
              pw.Text(
                'Customer Borrow Acknowledgement',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#00466a')),
              ),
              pw.SizedBox(height: 20),

              // Borrower Details
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      color: PdfColor.fromHex('#00466a'), width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Borrower Name:', style: boldTextStyle),
                    pw.Text(customerName, style: normalTextStyle),
                    pw.SizedBox(height: 5),
                    pw.Text('Book Title:', style: boldTextStyle),
                    pw.Text(title, style: normalTextStyle),
                    pw.SizedBox(height: 5),
                    pw.Text('Author:', style: boldTextStyle),
                    pw.Text(author, style: normalTextStyle),
                    pw.SizedBox(height: 5),
                    pw.Text('Borrow Date:', style: boldTextStyle),
                    pw.Text('${startDate.toLocal()}', style: normalTextStyle),
                    pw.SizedBox(height: 5),
                    pw.Text('Return Date:', style: boldTextStyle),
                    pw.Text('${returnDate.toLocal()}', style: normalTextStyle),
                    pw.SizedBox(height: 5),
                    pw.Text('Total Charge:', style: boldTextStyle),
                    pw.Text('BDT ${totalCharge.toStringAsFixed(2)}',
                        style: normalTextStyle),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Footer Section
              pw.Text(
                'Thank you for using PSTU Library Services!',
                style: normalTextStyle,
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'For more information, please contact us at: pstulibrary@pstu.edu.bd',
                style: normalTextStyle,
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Regards, \nPSTU Library Team',
                style: normalTextStyle,
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColor.fromHex('#00466a'), thickness: 1),
              pw.Text(
                'PSTU Library | Bangladesh',
                style: pw.TextStyle(
                    fontSize: 10, color: PdfColor.fromHex('#999999')),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Borrow ${widget.book.title}'),
        backgroundColor: theme.primaryColor,
      ),
      body: FadeTransition(
        opacity: _animation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(widget.book.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      widget.book.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Author: ${widget.book.author}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoRow('Charge', 'BDT ${totalCharge.toStringAsFixed(2)}'),
              _buildInfoRow('Start Date',
                  DateFormat('dd MMM, yyyy').format(selectedDate)),
              ElevatedButton(
                onPressed: _selectDate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Select Borrow Date'),
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedPeriod,
                      decoration: InputDecoration(
                        labelText: 'Select Borrowing Period',
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: periods.map((String period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: _onPeriodChanged,
                      style: theme.textTheme.titleMedium,
                      icon: const Icon(Icons.arrow_drop_down),
                    ),
                    if (['14 Days', '21 Days', '28 Days']
                        .contains(selectedPeriod))
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Additional charges apply for periods over 14 days.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                  'Return Date', DateFormat('dd MMM, yyyy').format(returnDate)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _borrowBook,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Confirm Borrow'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
