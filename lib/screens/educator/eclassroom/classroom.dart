import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stream_video_flutter/stream_video_flutter.dart';
import '../../../models/usermodel.dart';
import 'callscreen.dart';


// Global instance of StreamVideo
late StreamVideo streamVideoClient;

Future<void> initializeFirebase() async {
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
}

Future<void> initializeStreamVideo(String apiKey) async {
  final firebase.FirebaseAuth auth = firebase.FirebaseAuth.instance;
  final firebase.User? firebaseUser = auth.currentUser;

  if (firebaseUser != null) {
    final userModel = UserModel.fromFirebaseUser(firebaseUser);

    // Extract only the first name (before any space)
    final firstName = userModel.name.split(' ').first;
    final tokenService = TokenService();
    try {
      final tokenResponse = await tokenService.loadToken(firstName);

      // Initialize the StreamVideo client with the generated token
      streamVideoClient = StreamVideo(
        apiKey,
        user: User.regular(userId: firstName, role: 'user', name: userModel.name),
        userToken: tokenResponse.token,
      );
      print("StreamVideo initialized successfully for user: $firstName");
    } catch (e) {
      print("Error initializing StreamVideo: $e");
    }
  } else {
    print("User not authenticated.");
  }
}

class ClassHome extends StatelessWidget {
  const ClassHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Call',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InitializationScreen(),
    );
  }
}

class InitializationScreen extends StatelessWidget {
  const InitializationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeStreamVideo('mmhfdzb5evj2'),
      builder: (context, snapshot) {
        return const MyHomePage(title: '');
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _callIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _joinCallIdController = TextEditingController();
  final TextEditingController _joinPasswordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField(_callIdController, 'Meeting Name', 'Enter meeting name'),
              _buildTextField(_passwordController, 'Password', 'Enter password for meeting', obscureText: true),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Create Call'),
                onPressed: () async {
                  if (_callIdController.text.isEmpty || _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a meeting name and password')),
                    );
                    return;
                  }
                  _createCall(_callIdController.text, _passwordController.text);
                },
              ),
              const SizedBox(height: 32),
              _buildTextField(_joinCallIdController, 'Meeting ID', 'Enter meeting ID'),
              _buildTextField(_joinPasswordController, 'Password', 'Enter meeting password', obscureText: true),
              ElevatedButton(
                child: const Text('Join Call'),
                onPressed: () async {
                  _joinCall(_joinCallIdController.text, _joinPasswordController.text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        obscureText: obscureText,
      ),
    );
  }

  Future<void> _createCall(String callId, String password) async {
    try {
      final firebase.FirebaseAuth auth = firebase.FirebaseAuth.instance;
      final firebase.User? firebaseUser = auth.currentUser;
      if (firebaseUser == null) throw Exception('User is not authenticated');

      final userModel = UserModel.fromFirebaseUser(firebaseUser);
      final firstName = userModel.name.split(' ').first;
      final tokenResponse = await TokenService().loadToken(firstName);

      await _firestore.collection('calls').doc(callId).set({
        'password': password,
        'userId': firstName,
        'userName': userModel.name,
        'token': tokenResponse.token,
      });

      var call = StreamVideo.instance.makeCall(
        callType: StreamCallType(),
        id: callId,
      );

      await call.getOrCreate();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(call: call, callId: callId),
        ),
      );
    } catch (e) {
      debugPrint('Error creating call: $e');
    }
  }

  Future<void> _joinCall(String callId, String password) async {
    try {
      DocumentSnapshot callDoc = await _firestore.collection('calls').doc(callId).get();

      if (callDoc.exists) {
        String storedPassword = callDoc['password'];

        if (storedPassword == password) {
          var call = StreamVideo.instance.makeCall(
            callType: StreamCallType(),
            id: callId,
          );

          await call.getOrCreate();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallScreen(call: call, callId: callId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meeting ID does not exist')),
        );
      }
    } catch (e) {
      debugPrint('Error joining call: $e');
    }
  }

  @override
  void dispose() {
    _callIdController.dispose();
    _passwordController.dispose();
    _joinCallIdController.dispose();
    _joinPasswordController.dispose();
    super.dispose();
  }
}

// Token Service
class TokenService {
  const TokenService();

  final String _apiUrl = 'https://pronto.getstream.io/api/auth/create-token';
  final String _apiKey = 'mmhfdzb5evj2';

  Future<TokenResponse> loadToken(String userId) async {
    try {
      final uri = Uri.parse('$_apiUrl?user_id=$userId&apiKey=$_apiKey');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return TokenResponse.fromJson(body);
      } else {
        throw Exception('Failed to generate token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating token: $e');
    }
  }
}

// Token Response
class TokenResponse {
  final String token;
  final String apiKey;

  const TokenResponse(this.token, this.apiKey);

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      json['token'] as String,
      json['apiKey'] as String,
    );
  }
}
