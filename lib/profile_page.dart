import 'package:athlo/services/auth_service.dart';
import 'package:athlo/widgets/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void logout() async {
    try {
      await authService.value.signOut();
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<void> _updateUsername(String newUsername) async {
    await authService.value.currentUser!.updateDisplayName(newUsername);
    await authService.value.currentUser!.reload();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: StreamBuilder<User?>(
        stream: authService.value.authStateChanges,
        builder: (context, snapshot) {
          final user = snapshot.data;
          final photoURL = user?.photoURL;
          final displayName = user?.displayName ?? 'Nope Still Blank';
          final email = user?.email ?? 'i guess its blank';

          return Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue[700],
                backgroundImage: photoURL != null
                    ? NetworkImage(photoURL)
                    : null,
                child: photoURL == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 24),
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              _buildProfileInfo(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: StreamBuilder<User?>(
            stream: authService.value.authStateChanges,
            builder: (context, snapshot) {
              final user = snapshot.data;
              final photoURL = user?.photoURL;
              final displayName = user?.displayName ?? 'Nope Still Blank';
              final email = user?.email ?? 'i guess its blank';

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.blue[700],
                          backgroundImage: photoURL != null
                              ? NetworkImage(photoURL)
                              : null,
                          child: photoURL == null
                              ? const Icon(Icons.person,
                              size: 80, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          displayName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    flex: 2,
                    child: _buildProfileInfo(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  Widget _buildProfileInfo(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Akun',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
                Icons.person_outline,
                'Nama Lengkap',
                authService.value.currentUser!.displayName ??
                    'Nope Still Blank'),
            const Divider(height: 32),
            _buildInfoRow(Icons.email_outlined, 'Email',
                authService.value.currentUser!.email ?? 'i guess its blank'),
            const Divider(height: 32),
            _buildInfoRow(Icons.phone_outlined, 'Telepon', '+62 812-3456-7890'),
            const Divider(height: 32),
            _buildInfoRow(
                Icons.location_on_outlined, 'Alamat', 'Jakarta, Indonesia'),
            const Divider(height: 32),
            _buildInfoRow(
                Icons.calendar_today_outlined,
                'Bergabung',
                '${authService.value.currentUser!.metadata.creationTime!.day}/${authService.value.currentUser!.metadata.creationTime!.month}/${authService.value.currentUser!.metadata.creationTime!.year}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showEditProfileModal(
                    context,
                    currentUsername:
                    authService.value.currentUser!.displayName ?? '',
                    onUpdate: _updateUsername,
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}