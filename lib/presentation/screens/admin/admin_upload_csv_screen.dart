import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../../domain/services/cardapio_service.dart';

class AdminUploadCsvScreen extends StatefulWidget {
  @override
  _AdminUploadCsvScreenState createState() => _AdminUploadCsvScreenState();
}

class _AdminUploadCsvScreenState extends State<AdminUploadCsvScreen> {
  String? _selectedFileName;
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _downloadUrl;

  final CardapioService _cardapioService = CardapioService();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || _selectedFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum arquivo selecionado!')),
      );
      return;
    }
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });
    try {
      final File file = File(_selectedFile!.path!);
      var saoPaulo = tz.getLocation('America/Sao_Paulo');
      int month = tz.TZDateTime.now(saoPaulo).month;
      String fileName = "cardapio-mes$month.csv";
      String filePath = "uploads/csv/$fileName";
      Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = storageRef.putFile(file);
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() {
          _uploadProgress = progress;
        });
      });
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _downloadUrl = downloadUrl;
      });
      await FirebaseFirestore.instance.collection('uploads').add({
        'fileName': fileName,
        'url': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arquivo enviado com sucesso: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar arquivo: $e')),
      );
    } finally {
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _selectedFile = null;
            _selectedFileName = null;
            _uploadProgress = 0.0;
          });
        }
      });
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _importMonthlyCardapio() async {
    try {
      String message = await _cardapioService.importCardapio();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao importar cardápio: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
        _selectedFileName = result.files.first.name;
      });
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Ajuda',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem('Selecionar Arquivo', 'Escolha um arquivo CSV do seu dispositivo.'),
              SizedBox(height: 12),
              _buildHelpItem('Enviar Arquivo', 'Faz o upload do arquivo selecionado para o Firebase Storage.'),
              SizedBox(height: 12),
              _buildHelpItem('Importar Cardápio do Mês', 'Busca e importa o cardápio do mês atual (arquivo nomeado como cardapio-mesX.csv) para o sistema.'),
              SizedBox(height: 12),
              _buildHelpItem('Progresso', 'O indicador de progresso mostra a porcentagem de upload em tempo real.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fechar',
              style: TextStyle(fontSize: 16, color: Colors.deepPurple),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return RichText(
      text: TextSpan(
        text: '• $title: ',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        children: [
          TextSpan(
            text: description,
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      minimumSize: Size(double.infinity, 56),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carregar Cardapios',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: Color(0xFFE65100),
        toolbarHeight: 60,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFE65100),
        onPressed: _showHelpDialog,
        child: Icon(Icons.info),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_upload, size: 80, color: Color(0xFFE65100)),
                  SizedBox(height: 16),
                  Text(
                    'Gerencie seus arquivos CSV',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton.icon(
                    style: buttonStyle.copyWith(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.orange)),
                    onPressed: _pickFile,
                    icon: Icon(Icons.attach_file),
                    label: Text(
                      'Selecionar Arquivo',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 16),
                  _selectedFileName != null
                      ? Text(
                          'Arquivo selecionado: $_selectedFileName',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          'Nenhum arquivo selecionado',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                  SizedBox(height: 24),
                  _isUploading
                      ? Column(
                          children: [
                            LinearProgressIndicator(
                              value: _uploadProgress,
                              backgroundColor: Colors.grey[300],
                              color: Colors.orange,
                              minHeight: 8,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ],
                        )
                      : ElevatedButton.icon(
                          style: buttonStyle.copyWith(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green)),
                          onPressed: _uploadFile,
                          icon: Icon(Icons.cloud_upload),
                          label: Text(
                            'Enviar Arquivo',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: buttonStyle.copyWith(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue)),
                    onPressed: _importMonthlyCardapio,
                    icon: Icon(Icons.download),
                    label: Text(
                      'Importar Cardápio do Mês',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
