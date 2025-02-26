import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String greeting;
  final String? photoUrl; // Pode ser nulo, nesse caso vamos tentar o gravatar
  final String email; // Necessário para gerar o gravatar

  const ProfileHeader({
    Key? key,
    required this.userName,
    required this.email,
    this.greeting = "Bem-vindo(a) ao RU na Palma da Mão",
    this.photoUrl,
  }) : super(key: key);

  String _getGravatarUrl(String email) {
    final emailLower = email.trim().toLowerCase();
    final hash = md5.convert(utf8.encode(emailLower)).toString();
    return 'https://www.gravatar.com/avatar/$hash?s=200&d=404';
  }

  String _getUiAvatarUrl(String userName) {
    final encodedName = Uri.encodeComponent(userName);
    return 'https://ui-avatars.com/api/?name=$encodedName&size=200&background=0D8ABC&color=fff';
  }

  @override
  Widget build(BuildContext context) {
    // Se o photoUrl estiver definido, usamos ele; caso contrário, tentamos o gravatar
    final imageUrl = (photoUrl != null && photoUrl!.isNotEmpty)
        ? photoUrl!
        : _getGravatarUrl(email);
    return Container(
      width: double.infinity,
      color: const Color(0xFFE65100),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            // Usamos Image.network com errorBuilder para tratar o fallback para ui-avatars
            child: ClipOval(
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    _getUiAvatarUrl(userName),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            greeting,
            style:
            const TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
