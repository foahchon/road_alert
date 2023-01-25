part of 'management_cubit.dart';

class ManagementState extends Equatable {
  @override
  List<Object> get props => [];
}

class ManagementInitialState extends ManagementState {
  ManagementInitialState();

  @override
  List<Object> get props => [];
}

class IncidentsLoading extends ManagementState {
  @override
  List<Object> get props => [];
}

class IncidentsLoaded extends ManagementState {
  final List<Incident> incidents;
  IncidentsLoaded({required this.incidents});

  @override
  List<Object> get props => [incidents];
}

class IncidentNotesLoading extends ManagementState {
  @override
  List<Object> get props => [];
}

class IncidentNotesLoaded extends ManagementState {
  final List<IncidentNote> notes;
  IncidentNotesLoaded({required this.notes});

  @override
  List<Object> get props => [notes];
}
