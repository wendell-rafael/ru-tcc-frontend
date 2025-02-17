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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload CSV'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_drive_file, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE65100),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _pickFile,
                child: Text(
                  'Selecionar Arquivo',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              _selectedFileName != null
                  ? Text(
                'Arquivo: $_selectedFileName',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
                  : Text(
                'Nenhum arquivo selecionado',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20),
              if (_isUploading)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: Colors.grey[300],
                      color: Color(0xFFE65100),
                      minHeight: 6,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _uploadFile,
                  child: Text(
                    'Enviar Arquivo',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _importMonthlyCardapio,
                child: Text(
                  'Importar Cardápio do Mês',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
