import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usulicius_kelompok_lucky/screens/account_screen.dart';
import 'package:usulicius_kelompok_lucky/screens/login_screen.dart';
import 'package:usulicius_kelompok_lucky/screens/about_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String _userName = '';
  String _userEmail = '';
  String? _photoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    if (user == null) {
      _navigateToLogin();
      return;
    }

    setState(() => _isLoading = true);

    try {
      await user!.reload(); // Paksa refresh data Auth
      final currentUser = FirebaseAuth.instance.currentUser;

      final DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (mounted) {
        setState(() {
          _photoUrl = currentUser?.photoURL;

          if (docSnapshot.exists && docSnapshot.data() != null) {
            final userData = docSnapshot.data() as Map<String, dynamic>;
            _userName = userData['username'] ?? 'User';
            if (_photoUrl == null) _photoUrl = userData['photoURL'];
          } else {
            _userName = 'User';
          }

          _userEmail = currentUser?.email ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 55,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
          ? NetworkImage(_photoUrl!)
          : null,
      child: _photoUrl == null || _photoUrl!.isEmpty
          ? const Icon(Icons.person, size: 60, color: Colors.grey)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Perubahan di sini: Menambahkan style fontWeight.bold
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 249, 249, 249),
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileAvatar(),

              const SizedBox(height: 15),

              _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF8B0000))
                  : Column(
                children: [
                  Text(
                    _userName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _userEmail,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              _buildSettingOption(
                context,
                icon: Icons.person_outline,
                title: 'Your account',
                onTap: () async {
                  if (_isLoading) return;
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountScreen(
                        initialName: _userName,
                        initialEmail: _userEmail,
                        initialPassword: '••••••••••',
                      ),
                    ),
                  );

                  print("Kembali dari AccountScreen, merefresh data...");
                  _loadUserData();
                },
              ),

              _buildSettingOption(
                context,
                icon: Icons.group_outlined,
                title: 'About Us',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutUsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: const Color.fromARGB(255, 249, 249, 249),
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out successfully!')),
                      );
                      _navigateToLogin();
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}