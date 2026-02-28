import 'package:daraz_clone/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = context.watch<AuthViewModel>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFFE4572E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authVM.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No user data'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Avatar
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFFE4572E),
                    child: Text(
                      (user.firstName?.isNotEmpty == true)
                          ? user.firstName![0].toUpperCase()
                          : "G",
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '@${user.username}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                _infoTile(Icons.email, 'Email', user.email),
                _infoTile(Icons.phone, 'Phone', user.phone),
                _infoTile(Icons.location_city, 'City', user.city),
              ],
            ),
    );
  }

  Widget _infoTile(IconData? icon, String? label, String? value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE4572E)),
      title: Text(
        label ?? "Title",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(value ?? "SUb-Title"),
    );
  }
}
