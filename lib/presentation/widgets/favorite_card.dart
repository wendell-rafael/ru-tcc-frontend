import 'package:flutter/material.dart';

class FavoriteCard extends StatelessWidget {
  final String prato;
  final int id;
  final VoidCallback onRemove;

  const FavoriteCard({
    Key? key,
    required this.prato,
    required this.id,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFE65100),
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          prato,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: onRemove,
          tooltip: 'Remover',
        ),
      ),
    );
  }
}
