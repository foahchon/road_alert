import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;
  late final _authEventStream = StreamController<AuthEvent>();
  late final StreamSubscription<AuthState> _authStateStreamSubscription;

  AuthService() {
    _authStateStreamSubscription =
        _supabase.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
          _authEventStream.add(AuthEvent(type: AuthEventType.signIn));
          break;

        case AuthChangeEvent.signedOut:
          _authEventStream.add(AuthEvent(type: AuthEventType.signOut));
          break;

        case AuthChangeEvent.tokenRefreshed:
          _authEventStream.add(AuthEvent(type: AuthEventType.tokenRefreshing));
          break;

        default:
          break;
      }
    });
  }

  signInWithProvider(Provider provider, {required String redirect}) async {
    await _supabase.auth.signInWithOAuth(provider, redirectTo: redirect);
  }

  Stream<AuthEvent> get eventStream {
    return _authEventStream.stream;
  }

  bool get isSignedIn {
    return _supabase.auth.currentSession != null;
  }

  String? get userDisplayName {
    return _supabase.auth.currentUser?.userMetadata?['full_name'];
  }

  String? get userEmail {
    return _supabase.auth.currentUser?.userMetadata?['email'];
  }

  String? get userAccessToken {
    return _supabase.auth.currentSession?.accessToken;
  }

  signOut() async {
    await _supabase.auth.signOut();
    _authStateStreamSubscription.cancel();
  }
}

enum AuthEventType { signIn, signOut, tokenRefreshing }

class AuthEvent {
  late final AuthEventType type;

  AuthEvent({required this.type});
}
