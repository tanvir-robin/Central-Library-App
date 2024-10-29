import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

User? loggedInUser;

class User {
  final String email;
  final String name;
  final String photo;

  User({
    required this.email,
    required this.name,
    required this.photo,
  });

  // Factory method to create a User from a map (e.g., from JSON)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photo: map['photo'] ?? '',
    );
  }

  // Method to convert a User to a map (e.g., for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photo': photo,
    };
  }
}

class AuthController extends GetxController {
  static Future<User?> fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          loggedInUser = User.fromMap(userDoc.data()!);
          return loggedInUser;
        } else {
          print('User document does not exist');
          return null;
        }
      } else {
        print('No user is currently signed in');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  static Future<User?> fetchByUserID(String id) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(id).get();

      if (userDoc.exists) {
        User user = User.fromMap(userDoc.data()!);
        return user;
      } else {
        print('User document does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
