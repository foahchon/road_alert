import 'package:supabase_flutter/supabase_flutter.dart';

class UsersService {
  isSignedIn() {
    return Supabase.instance.client.auth.currentSession != null;
  }

  loginWithProvider() {}

  signOut() {
    Supabase.instance.client.auth.signOut();
  }
}
