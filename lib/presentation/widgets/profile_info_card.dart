import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String email;
  final int favoritesCount;
  final String lastCheckin;

  const ProfileInfoCard({
    Key? key,
    required this.email,
    required this.favoritesCount,
    required this.lastCheckin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.email, color: Color(0xFFE65100)),
                title: Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(email),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.favorite, color: Color(0xFFE65100)),
                title: Text("Total de Favoritos", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("$favoritesCount"),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.check, color: Color(0xFFE65100)),
                title: Text("Último Check-in", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(lastCheckin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
