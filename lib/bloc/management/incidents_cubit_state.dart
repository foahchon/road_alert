part of 'incidents_cubit.dart';

abstract class IncidentsCubitState extends Equatable {}

class ManagementInitialState extends IncidentsCubitState {
  @override
  List<Object> get props => [];
}

class IncidentsCubitError extends IncidentsCubitState {
  final String message;

  IncidentsCubitError({required this.message});

  @override
  List<Object> get props => [message];
}

class IncidentCreating extends IncidentsCubitState {
  @override
  List<Object> get props => [];
}

class IncidentCreated extends IncidentsCubitState {
  @override
  List<Object> get props => [];
}

class IncidentsLoading extends IncidentsCubitState {
  @override
  List<Object> get props => [];
}

class IncidentsLoaded extends IncidentsCubitState {
  final List<Incident> incidents;
  IncidentsLoaded({required this.incidents});

  @override
  List<Object> get props => [incidents];
}

class IncidentNotesLoading extends IncidentsCubitState {
  @override
  List<Object> get props => [];
}

class IncidentNotesLoaded extends IncidentsCubitState {
  final List<IncidentNote> notes;
  IncidentNotesLoaded({required this.notes});

  @override
  List<Object> get props => [notes];
}

class IncidentCompleting extends IncidentsCubitState {
  @override
  List<Object> get props => [];
}

class IncidentCompleted extends IncidentsCubitState {
  final bool completed;
  IncidentCompleted({this.completed = true});

  @override
  List<Object> get props => [completed];
}

class AddressFetching extends IncidentsCubitState {
  @override
  List<Object> get props => [];
}

class AddressFetched extends IncidentsCubitState {
  final GoogleMapServiceResult result;

  AddressFetched({required this.result});

  @override
  List<Object> get props => [result];
}
