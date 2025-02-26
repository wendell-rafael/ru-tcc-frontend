import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class AdminUploadController {
  AdminUploadController() {
    tz.initializeTimeZones();
  }

  Future<String> uploadFile(String filePath) async {
    var saoPaulo = tz.getLocation('America/Sao_Paulo');
    int month = tz.TZDateTime.now(saoPaulo).month;
    String fileName = "cardapio-mes$month.csv";
    String destination = "uploads/csv/$fileName";
    File file = File(filePath);
    Reference storageRef = FirebaseStorage.instance.ref().child(destination);
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> saveUploadMetadata(String fileName, String downloadUrl) async {
    await FirebaseFirestore.instance.collection('uploads').add({
      'fileName': fileName,
      'url': downloadUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
