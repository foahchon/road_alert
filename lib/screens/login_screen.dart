import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:road_alert/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  late final _authService = GetIt.I.get<AuthService>();
  late final StreamSubscription<AuthEvent> _authStateSubscription;

  @override
  initState() {
    _authStateSubscription = _authService.eventStream.listen((event) {
      if (event.type == AuthEventType.signIn) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'Create Incident'),
        ));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
        child: const Text("Log In With Google"),
        onPressed: () async {
          await _authService.signInWithProvider(Provider.google,
              redirect: 'io.supabase.roadalert://login-callback');
        },
      )),
    );
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
