import 'package:elmouaddibe_examen/about_screen.dart';
import 'package:elmouaddibe_examen/admin/all_borrow.dart';
import 'package:elmouaddibe_examen/auth/screens/login_page.dart';
import 'package:elmouaddibe_examen/books_screen.dart';
import 'package:elmouaddibe_examen/chatbot_screen.dart';
import 'package:elmouaddibe_examen/members_screen.dart';

import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orangeAccent, Colors.orange],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Hero(
                    tag: 'library_logo',
                    child: Image.asset('assets/library.png',
                        width: 200, height: 200),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome, Admin',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Manage the library from here!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildFeatureCard(
                        icon: Icons.book,
                        title: 'Explore the books',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FacultyScreen()),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.people,
                        title: 'Manage members',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MembersScreen()),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.book,
                        title: 'Borrows',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminBorrowsScreen()),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.chat,
                        title: 'Chatbot',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const chatbotScreen()),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.info,
                        title: 'About',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AboutScreen()),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.logout,
                        title: 'Sign Out',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Advantages of our library :',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const ListTile(
                    leading: Icon(Icons.wifi, color: Colors.white),
                    title: Text(
                      'Access to a wide variety of resources',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.group_work, color: Colors.white),
                    title: Text(
                      'collaborative workspaces',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.event, color: Colors.white),
                    title: Text(
                      'Educational Programs and Community Events',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.deepOrangeAccent),
              const SizedBox(height: 10),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
