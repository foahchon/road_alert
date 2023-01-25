import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_alert/services/auth_service.dart';
import 'package:road_alert/services/incidents_service.dart';

import '../../models/incident_model.dart';
import '../../models/incident_note_model.dart';
part 'management_state.dart';

enum ManagementStatus { unknown, requested, loading, loaded, notSignedIn }

class ManagementCubit extends Cubit<ManagementState> {
  final AuthService _authService;
  final IncidentsService _incidentsService;

  ManagementCubit(AuthService authService, IncidentsService incidentsService)
      : _authService = authService,
        _incidentsService = incidentsService,
        super(ManagementInitialState());

  Future<void> getIncidents() async {
    if (_authService.isSignedIn) {
      emit(IncidentsLoading());
      final incidents = await _incidentsService.getIncidents();
      emit(IncidentsLoaded(incidents: incidents));
    }
  }

  Future<void> getNotesForIncident(Incident incident) async {
    emit(IncidentNotesLoading());
    var incidentNotes = await _incidentsService.getNotesForIncident(incident);
    emit(IncidentNotesLoaded(notes: incidentNotes));
  }

  Future<void> addNoteForIncident(Incident incident, String text) async {
    emit(IncidentNotesLoading());
    await _incidentsService.addNoteForIncident(incident, text);
    var incidentNotes = await _incidentsService.getNotesForIncident(incident);
    emit(IncidentNotesLoaded(notes: incidentNotes));
  }
}
