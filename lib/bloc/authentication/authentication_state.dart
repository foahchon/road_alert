part of 'authentication_bloc.dart';

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;

  const AuthenticationState({required this.status});
  const AuthenticationState.signedIn() : status = AuthenticationStatus.signedIn;
  const AuthenticationState.signedOut()
      : status = AuthenticationStatus.signedOut;
  const AuthenticationState.unknown() : status = AuthenticationStatus.unknown;

  @override
  List<Object> get props => [status];
}
