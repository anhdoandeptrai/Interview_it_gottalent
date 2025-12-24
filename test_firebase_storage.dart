import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lib/firebase_options.dart';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(StorageTestApp());
}

class StorageTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StorageTestScreen(),
    );
  }
}

class StorageTestScreen extends StatefulWidget {
  @override
  _StorageTestScreenState createState() => _StorageTestScreenState();
}

class _StorageTestScreenState extends State<StorageTestScreen> {
  String _status = 'Ready';

  Future<void> _testFirebaseStorage() async {
    setState(() => _status = 'Testing Firebase Storage...');

    try {
      print('🔥 Testing Firebase Storage');

      // Check Firebase Auth first
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('🔐 Signing in anonymously...');
        await FirebaseAuth.instance.signInAnonymously();
        user = FirebaseAuth.instance.currentUser;
        print('✅ Anonymous sign in successful: ${user?.uid}');
      }

      // Test Storage
      FirebaseStorage storage = FirebaseStorage.instance;
      print('📦 Storage bucket: ${storage.bucket}');
      print('📱 Storage app: ${storage.app.name}');

      // Create test data
      String testData = 'Hello Firebase Storage! ${DateTime.now()}';
      Uint8List bytes = Uint8List.fromList(testData.codeUnits);

      // Create reference
      String fileName =
          'test/${user!.uid}/test_${DateTime.now().millisecondsSinceEpoch}.txt';
      Reference ref = storage.ref().child(fileName);
      print('📂 Test file path: $fileName');

      // Upload test file
      print('⬆️ Uploading test file...');
      UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'text/plain'),
      );

      TaskSnapshot snapshot = await uploadTask;
      print('✅ Upload completed');

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('🔗 Download URL: $downloadUrl');

      // Clean up - delete test file
      await ref.delete();
      print('🗑️ Test file deleted');

      setState(() => _status = '✅ Firebase Storage test successful!');
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _status = '❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Storage Test')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _status,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testFirebaseStorage,
              child: Text('Test Firebase Storage'),
            ),
          ],
        ),
      ),
    );
  }
}
