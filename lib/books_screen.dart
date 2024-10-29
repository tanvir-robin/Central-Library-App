import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'book_detail_screen.dart';

class Book {
  final String title;
  final String author;
  final String image;
  final String description;
  final int quantityInStock;
  final double charge;
  final String faculty;
  String? docID;
  List<Comment> comments;

  Book({
    this.docID,
    required this.title,
    required this.author,
    required this.image,
    required this.description,
    required this.quantityInStock,
    required this.charge,
    required this.faculty,
    this.comments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'image': image,
      'description': description,
      'quantityInStock': quantityInStock,
      'charge': charge,
      'faculty': faculty,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json, String id) {
    return Book(
      docID: id,
      title: json['title'],
      author: json['author'],
      image: json['image'],
      description: json['description'],
      quantityInStock: json['quantityInStock'],
      charge: (json['charge'] as num).toDouble(),
      faculty: json['faculty'],
      comments: (json['comments'] as List<dynamic>)
          .map((commentJson) => Comment.fromJson(commentJson))
          .toList(),
    );
  }
}

class Comment {
  final String user;
  final String text;
  final bool liked;

  Comment({
    required this.user,
    required this.text,
    this.liked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'text': text,
      'liked': liked,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      user: json['user'],
      text: json['text'],
      liked: json['liked'] ?? false,
    );
  }
}

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key, this.faculty});
  final String? faculty;
  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String selectedFaculty = 'General'; // Default faculty
  List<String> faculties = [
    'General',
    'CSE',
    'BBA',
    'Agriculture',
    'LLA',
    'NFS',
    'ESDM',
    'Fisheries',
    'DVM',
    'ANHVM'
  ];
  List<IconData> facultyIcons = [
    Icons.book,
    Icons.computer,
    Icons.business,
    Icons.agriculture,
    Icons.library_books,
    Icons.nature,
    Icons.science,
    Icons.water,
    Icons.pets,
    Icons.local_hospital
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _addBook(String title, String author, String image, String description,
      int quantityInStock, double charge, String faculty) async {
    final book = Book(
      title: title,
      author: author,
      image: image,
      description: description,
      quantityInStock: quantityInStock,
      charge: charge,
      faculty: faculty,
    );
    await FirebaseFirestore.instance.collection('books').add(book.toJson());
  }

  void _removeBook(String docID) async {
    if (docID.isNotEmpty) {
      await FirebaseFirestore.instance.collection('books').doc(docID).delete();
    }
  }

  void _showAddBookDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController imageController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController chargeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a new book'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(
                      labelText: 'URL of the cover (Optional)'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: quantityController,
                  decoration:
                      const InputDecoration(labelText: 'Quantity in stock'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: chargeController,
                  decoration: const InputDecoration(labelText: 'Charge'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedFaculty,
                  decoration:
                      const InputDecoration(labelText: 'Select Faculty'),
                  items: faculties.map((String faculty) {
                    int index = faculties.indexOf(faculty);
                    return DropdownMenuItem<String>(
                      value: faculty,
                      child: Row(
                        children: [
                          Icon(facultyIcons[index]),
                          const SizedBox(width: 8),
                          Text(faculty),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFaculty = value ?? 'General';
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addBook(
                  titleController.text,
                  authorController.text,
                  imageController.text.isEmpty
                      ? 'https://placehold.co/80x100'
                      : imageController.text,
                  descriptionController.text,
                  int.parse(quantityController.text),
                  double.parse(chargeController.text),
                  selectedFaculty, // Send selected faculty
                );
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, right: 10, left: 10),
      child: Scaffold(
        appBar: AppBar(
          title: widget.faculty == null
              ? const Text('Books')
              : Text('Books - ${widget.faculty}'),
          actions: [
            if (FirebaseAuth.instance.currentUser == null)
              ElevatedButton.icon(
                onPressed: _showAddBookDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for books...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: widget.faculty == null
              ? FirebaseFirestore.instance.collection('books').snapshots()
              : FirebaseFirestore.instance
                  .collection('books')
                  .where('faculty', isEqualTo: widget.faculty)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading books'));
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No books found'));
            }

            final books = snapshot.data!.docs.map((doc) {
              return Book.fromJson(doc.data() as Map<String, dynamic>, doc.id);
            }).toList();

            final filteredBooks = books.where((book) {
              return book.title.toLowerCase().contains(_searchQuery) ||
                  book.author.toLowerCase().contains(_searchQuery);
            }).toList();

            return ListView.builder(
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: ListTile(
                    leading: Image.network(
                      book.image,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 80,
                    ),
                    title: Text(
                      book.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Author: ${book.author}'),
                        Text('Faculty: ${book.faculty}'),
                        book.quantityInStock > 0
                            ? Text('Quantity: ${book.quantityInStock}')
                            : const Text(
                                'Unavailable',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        Text('Charge: ${book.charge}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _removeBook(book.docID!);
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BookDetailScreen(book: book),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class FacultyScreen extends StatelessWidget {
  final List<String> faculties = [
    'All Books', // Added "All Books" as the first option
    'General',
    'CSE',
    'BBA',
    'Agriculture',
    'LLA',
    'NFS',
    'ESDM',
    'Fisheries',
    'DVM',
    'ANHVM',
  ];

  final List<IconData> facultyIcons = [
    Icons.library_books, // Icon for "All Books"
    Icons.book,
    Icons.computer,
    Icons.business,
    Icons.agriculture,
    Icons.library_books,
    Icons.nature,
    Icons.science,
    Icons.water,
    Icons.pets,
    Icons.local_hospital,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculties'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0,
        ),
        itemCount: faculties.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (index == 0) {
                // When "All Books" is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BooksScreen(), // No faculty argument
                  ),
                );
              } else {
                // For other faculties
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BooksScreen(
                      faculty: faculties[index],
                    ),
                  ),
                );
              }
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    facultyIcons[index],
                    size: 50,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    faculties[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
