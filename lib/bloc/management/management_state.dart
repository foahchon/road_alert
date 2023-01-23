part of 'management_cubit.dart';

class ManagementState extends Equatable {
  final ManagementStatus status;

  const ManagementState.unknown() : status = ManagementStatus.unknown;
  const ManagementState({required this.status});
  const ManagementState.requested() : status = ManagementStatus.requested;
  const ManagementState.loading() : status = ManagementStatus.loading;
  const ManagementState.notSignedIn() : status = ManagementStatus.notSignedIn;

  @override
  List<Object> get props => [status];
}

class IncidentsLoaded extends ManagementState {
  final List<Incident> incidents;
  const IncidentsLoaded(this.incidents)
      : super(status: ManagementStatus.loaded);
}
