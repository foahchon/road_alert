import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:road_alert/bloc/authentication/authentication_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.status == AuthenticationStatus.signedIn) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'Create Incident'),
          ));
        }
      },
      child: Scaffold(
        body: Center(
            child: ElevatedButton(
          child: const Text("Log In With Google"),
          onPressed: () async {
            await _authService.signInWithProvider(Provider.google,
                redirect: 'io.supabase.roadalert://login-callback');
          },
        )),
      ),
    );
  }
}
