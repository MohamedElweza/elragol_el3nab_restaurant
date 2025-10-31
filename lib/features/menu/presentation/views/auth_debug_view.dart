import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../../core/storage/app_secure_storage.dart';

class AuthDebugView extends StatefulWidget {
  const AuthDebugView({super.key});

  @override
  State<AuthDebugView> createState() => _AuthDebugViewState();
}

class _AuthDebugViewState extends State<AuthDebugView> {
  String _debugInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final accessToken = await AppPreferences.getAccessToken();
      final refreshToken = await AppPreferences.getRefreshToken();
      final userData = await AppPreferences.getUserData();
      final isLoggedIn = await AppPreferences.isLoggedIn();

      final info = '''
🔍 Authentication Debug Info:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📱 Is Logged In: $isLoggedIn

🔑 Access Token:
${accessToken != null ? 'Present (${accessToken.length} chars)' : 'Missing'}
${accessToken != null ? 'Preview: ${accessToken.substring(0, accessToken.length > 50 ? 50 : accessToken.length)}...' : ''}

🔄 Refresh Token:
${refreshToken != null ? 'Present (${refreshToken.length} chars)' : 'Missing'}

👤 User Data:
${userData != null ? 'Present (${userData.length} chars)' : 'Missing'}
${userData != null ? 'Preview: ${userData.substring(0, userData.length > 100 ? 100 : userData.length)}...' : ''}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      ''';

      log('🔍 Auth Debug: $info');
      
      setState(() {
        _debugInfo = info;
      });
    } catch (e) {
      log('❌ Auth Debug Error: $e');
      setState(() {
        _debugInfo = 'Error checking auth status: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Debug'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    _debugInfo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkAuthStatus,
              child: const Text('Refresh Debug Info'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await AppPreferences.clearAll();
                log('🔄 All auth data cleared');
                _checkAuthStatus();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All Auth Data'),
            ),
          ],
        ),
      ),
    );
  }
}