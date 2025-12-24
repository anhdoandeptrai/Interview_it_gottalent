import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FirebaseStorageTestApp());
}

class FirebaseStorageTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Storage Test',
      home: StorageTestScreen(),
    );
  }
}

class StorageTestScreen extends StatefulWidget {
  @override
  _StorageTestScreenState createState() => _StorageTestScreenState();
}

class _StorageTestScreenState extends State<StorageTestScreen> {
  String _status = 'Ready to test';
  bool _isLoading = false;

  Future<void> _testFirebaseStorageRules() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Firebase Storage...';
    });

    try {
      // Test 1: Check Firebase Auth
      print('🔐 Testing Firebase Auth...');
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Anonymous sign in for testing
        await FirebaseAuth.instance.signInAnonymously();
        user = FirebaseAuth.instance.currentUser;
        print('✅ Anonymous auth successful: ${user?.uid}');
      } else {
        print('✅ User already authenticated: ${user.uid}');
      }

      setState(() {
        _status = 'Auth successful. Testing Storage Rules...';
      });

      // Test 2: Try to upload a test file
      print('📁 Testing Storage Upload...');

      final FirebaseStorage storage = FirebaseStorage.instance;

      // Create test data
      Uint8List testData = Uint8List.fromList('Test PDF content'.codeUnits);

      // Test current app path structure
      String testPath = 'pdfs/${user!.uid}/test-session/test.pdf';
      print('📤 Upload path: $testPath');

      Reference ref = storage.ref().child(testPath);

      // Try upload
      UploadTask uploadTask = ref.putData(testData);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('📊 Upload progress: ${(progress * 100).toStringAsFixed(2)}%');

        setState(() {
          _status = 'Upload progress: ${(progress * 100).toStringAsFixed(1)}%';
        });
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Upload successful!');
      print('🔗 Download URL: $downloadUrl');

      setState(() {
        _status = 'SUCCESS! Storage upload works.\nURL: $downloadUrl';
      });

      // Test 3: Try to download
      print('📥 Testing download...');
      Uint8List? downloadedData = await ref.getData();

      if (downloadedData != null) {
        String content = String.fromCharCodes(downloadedData);
        print('✅ Download successful: $content');

        setState(() {
          _status = 'SUCCESS! Upload & Download work!\nContent: $content';
        });
      }

      // Cleanup - delete test file
      await ref.delete();
      print('🗑️ Test file deleted');
    } catch (e) {
      print('❌ Error: $e');

      if (e.toString().contains('object-not-found') ||
          e.toString().contains('404')) {
        setState(() {
          _status =
              '❌ FIREBASE RULES ERROR!\n\nNeed to update Storage Rules:\n1. Go to Firebase Console\n2. Storage > Rules\n3. Set: allow read, write: if true;';
        });
      } else if (e.toString().contains('permission-denied') ||
          e.toString().contains('403')) {
        setState(() {
          _status =
              '❌ PERMISSION DENIED!\n\nRules are too restrictive.\nCheck Storage Rules in Firebase Console.';
        });
      } else {
        setState(() {
          _status = '❌ ERROR: $e';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testStorageRulesVariants() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing different path patterns...';
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await FirebaseAuth.instance.signInAnonymously();
        user = FirebaseAuth.instance.currentUser;
      }

      final FirebaseStorage storage = FirebaseStorage.instance;
      Uint8List testData = Uint8List.fromList('Test content'.codeUnits);

      // Test different path patterns
      List<String> testPaths = [
        'test.pdf', // Root level
        'pdfs/test.pdf', // Simple path
        'pdfs/${user!.uid}/test.pdf', // User path
        'pdfs/${user.uid}/session123/test.pdf', // Full path structure
      ];

      for (String path in testPaths) {
        try {
          print('Testing path: $path');
          setState(() {
            _status = 'Testing path: $path';
          });

          Reference ref = storage.ref().child(path);
          await ref.putData(testData);

          print('✅ SUCCESS: $path');
          await ref.delete(); // Cleanup
        } catch (e) {
          print('❌ FAILED: $path - $e');
        }
      }

      setState(() {
        _status = 'Path testing completed. Check console logs.';
      });
    } catch (e) {
      setState(() {
        _status = 'Test error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Storage Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Firebase Storage Rules Test',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This will test if Firebase Storage rules allow uploads.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testFirebaseStorageRules,
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Testing...'),
                      ],
                    )
                  : Text('Test Firebase Storage Rules'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testStorageRulesVariants,
              child: Text('Test Different Paths'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _status,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
