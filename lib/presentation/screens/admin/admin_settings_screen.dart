import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import '../shared/alteracao_screen.dart';
import 'admin_insghts_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  int totalStudents = 0;
  int veganStudents = 0;
  int vegetarianStudents = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromFirestore();
  }

  Future<void> _loadDataFromFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Total de usuários
      final totalSnapshot = await firestore.collection('users').get();
      final totalCount = totalSnapshot.size;

      // 2. Usuários Veganos
      final veganSnapshot = await firestore
          .collection('users')
          .where('dietaryRestriction', isEqualTo: 'Vegano')
          .get();
      final veganCount = veganSnapshot.size;

      // 3. Usuários Vegetarianos
      final vegetarianSnapshot = await firestore
          .collection('users')
          .where('dietaryRestriction', isEqualTo: 'Vegetariano')
          .get();
      final vegetarianCount = vegetarianSnapshot.size;

      setState(() {
        totalStudents = totalCount;
        veganStudents = veganCount;
        vegetarianStudents = vegetarianCount;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Stream para observar a contagem de alterações no cardápio
  Stream<int> getCardapioChangesCountStream() {
    return FirebaseFirestore.instance
        .collection('cardapioChanges')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Widget auxiliar para exibir um card de informação
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  /// Widget auxiliar para exibir o botão de logout
  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      },
      child: const Text(
        'Sair',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configurações',
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFE65100),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Configurações', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE65100),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.settings, size: 80, color: Colors.black),
            const SizedBox(height: 20),

            // Card: Alunos Cadastrados
            _buildInfoCard(
              icon: Icons.group,
              title: 'Alunos Cadastrados',
              value: '$totalStudents',
              iconColor: Colors.deepOrange,
            ),
            const SizedBox(height: 12),

            // Card: Alunos Veganos
            _buildInfoCard(
              icon: Icons.eco,
              title: 'Alunos Veganos',
              value: '$veganStudents',
              iconColor: Colors.green,
            ),
            const SizedBox(height: 12),

            // Card: Alunos Vegetarianos
            _buildInfoCard(
              icon: Icons.spa,
              title: 'Alunos Vegetarianos',
              value: '$vegetarianStudents',
              iconColor: Colors.lime,
            ),
            const SizedBox(height: 12),

            // Card: Alterações no Cardápio (navega para AlteracoesScreen)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: StreamBuilder<int>(
                stream: getCardapioChangesCountStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const ListTile(
                      leading: Icon(Icons.update, color: Colors.blue),
                      title: Text('Alterações no Cardápio'),
                      trailing: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final changesCount = snapshot.data!;
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AlteracoesScreen()),
                      );
                    },
                    leading: const Icon(Icons.update, color: Colors.blue),
                    title: const Text('Alterações no Cardápio'),
                    trailing: Text(
                      '$changesCount',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Card: Dashboard de Insights (navega para insights)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminDashboardInsightsScreen()),
                  );
                },
                leading: const Icon(Icons.pie_chart, color: Colors.deepOrange),
                title: const Text('Dashboard de Insights'),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),

            const SizedBox(height: 30),

            // Botão de Sair
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }
}
