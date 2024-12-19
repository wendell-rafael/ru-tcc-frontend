import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _favorites = []; // Lista de itens favoritos

  void _addFavorite() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !_favorites.contains(text)) {
      setState(() {
        _favorites.add(text); // Adiciona o item à lista
      });
      _controller.clear(); // Limpa o campo de texto
    }
  }

  void _removeFavorite(String item) {
    setState(() {
      _favorites.remove(item); // Remove o item da lista
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE65100),
        title: Text('Favoritos', style: TextStyle(fontSize: 24)),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O que você gostaria de comer?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white), // Texto em branco
                    decoration: InputDecoration(
                      hintText: 'Digite o nome do item...',
                      hintStyle: TextStyle(color: Colors.white70), // Placeholder em branco
                      filled: true,
                      fillColor: Color(0xFFE65100), // Fundo laranja
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addFavorite,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE65100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  child: Text(
                    'Adicionar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Seus Favoritos:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: _favorites.isEmpty
                  ? Center(
                child: Text(
                  'Nenhum favorito adicionado.',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
                  : ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final item = _favorites[index];
                  return Card(
                    color: Color(0xFFE65100), // Fundo laranja no card
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        item,
                        style: TextStyle(fontSize: 18, color: Colors.white), // Texto em branco
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white), // Ícone em branco
                        onPressed: () => _removeFavorite(item),
                        tooltip: 'Remover',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
