import 'package:athlo/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileModal extends StatefulWidget {
  final String currentUsername;
  final Function(String) onUpdate;

  const EditProfileModal({
    Key? key,
    required this.currentUsername,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController _usernameController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      setState(() {
        _errorMessage = 'Username tidak boleh kosong';
      });
      return;
    }

    if (newUsername == widget.currentUsername) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onUpdate(newUsername);
      authService.value.updateUsername(username: newUsername);
      if (mounted) {
        Navigator.pop(context);
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Edit Profile'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 50),
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoTextField(
                controller: _usernameController,
                placeholder: 'Username',
                enabled: !_isLoading,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: CupertinoColors.systemRed, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_isLoading) ...[
                const SizedBox(height: 16),
                const CupertinoActivityIndicator(),
              ],
            ],
          ),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        CupertinoDialogAction(
          onPressed: _isLoading ? null : _handleUpdate,
          isDefaultAction: true,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

// Helper function to show the modal
void showEditProfileModal(
    BuildContext context, {
      required String currentUsername,
      required Function(String) onUpdate,
    }) {
  showCupertinoDialog(
    context: context,
    builder: (context) => EditProfileModal(
      currentUsername: currentUsername,
      onUpdate: onUpdate,
    ),
  );
}