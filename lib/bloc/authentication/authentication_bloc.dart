import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:road_alert/services/auth_service.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

enum AuthenticationStatus { unknown, signedOut, signedIn }

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthService _authService;

  AuthenticationBloc(AuthService authService)
      : _authService = authService,
        super(const AuthenticationState.unknown()) {
    _authService.eventStream.listen((data) {
      switch (data.type) {
        case AuthEventType.signIn:
          add(const AuthenticationStatusChanged(
              AuthenticationStatus.signedIn));
          break;
        case AuthEventType.signOut:
          add(const AuthenticationStatusChanged(
              AuthenticationStatus.signedOut));
          break;
        default:
          break;
      }
    });

    on<AuthenticationStatusChanged>((event, emit) async {
      switch (event.status) {
        case AuthenticationStatus.signedIn:
          return emit(const AuthenticationState.signedIn());
        case AuthenticationStatus.signedOut:
          return emit(const AuthenticationState.signedOut());
        default:
          break;
      }
    });

    on<AuthenticationLogoutRequested>((event, emit) {
      _authService.signOut();
    });
  }
}
