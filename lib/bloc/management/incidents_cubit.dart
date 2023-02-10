import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_alert/services/auth_service.dart';
import 'package:road_alert/services/google_maps_service.dart';
import 'package:road_alert/services/incidents_service.dart';
import 'package:road_alert/services/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/incident_model.dart';
import '../../models/incident_note_model.dart';
part 'incidents_cubit_state.dart';

class IncidentsCubit extends Cubit<IncidentsCubitState> {
  final AuthService _authService;
  final IncidentsService _incidentsService;
  final LocationService _locationService;
  final GoogleMapsService _googleMapsService;

  IncidentsCubit(AuthService authService, IncidentsService incidentsService,
      LocationService locationService, GoogleMapsService googleMapsService)
      : _authService = authService,
        _incidentsService = incidentsService,
        _locationService = locationService,
        _googleMapsService = googleMapsService,
        super(ManagementInitialState());

  Future<void> getIncidents() async {
    if (_authService.isSignedIn) {
      emit(IncidentsLoading());
      try {
        final incidents = await _incidentsService.getIncidents();
        emit(IncidentsLoaded(incidents: incidents));
      } on PostgrestException catch (error) {
        emit(IncidentsCubitError(message: error.message));
      }
    }
  }

  Future<void> getNotesForIncident(Incident incident) async {
    emit(IncidentNotesLoading());
    try {
      var incidentNotes = await _incidentsService.getNotesForIncident(incident);
      emit(IncidentNotesLoaded(notes: incidentNotes));
    } on PostgrestException catch (error) {
      emit(IncidentsCubitError(message: error.message));
    }
  }

  Future<void> addNoteForIncident(Incident incident, String text) async {
    emit(IncidentNotesLoading());
    try {
      await _incidentsService.addNoteForIncident(incident, text);
      var incidentNotes = await _incidentsService.getNotesForIncident(incident);
      emit(IncidentNotesLoaded(notes: incidentNotes));
    } on PostgrestException catch (error) {
      emit(IncidentsCubitError(message: error.message));
    }
  }

  Future<void> completeIncident(Incident incident, bool isCompleted) async {
    emit(IncidentCompleting());
    try {
      await _incidentsService.completeIncident(incident);
      emit(IncidentCompleted());
    } on PostgrestException catch (error) {
      emit(IncidentsCubitError(message: error.message));
    }
  }

  Future<void> getCompletedForIncident(Incident incident) async {
    emit(IncidentCompleted(completed: incident.complete));
  }

  Future<void> setIncidentComplete(Incident incident, bool complete) async {
    emit(IncidentCompleting());
    try {
      await _incidentsService.setIncidentComplete(incident, complete);
      emit(IncidentCompleted(completed: complete));
    } on PostgrestException catch (error) {
      emit(IncidentsCubitError(message: error.message));
    }
  }

  Future<void> createIncident(
      String description,
      String address,
      String zipCode,
      double latitude,
      double longitude,
      String photoPath) async {
    emit(IncidentCreating());
    var response = await _incidentsService.createIncident(
        description, address, zipCode, latitude, longitude, photoPath);

    if (response.statusCode != 200) {
      emit(IncidentsCubitError(message: response.reasonPhrase!));
    } else {
      emit(IncidentCreated());
    }
  }

  Future<void> fetchAddress() async {
    emit(AddressFetching());
    var location = await _locationService.getLocation();
    var result = await _googleMapsService.getAddress(
        location.latitude, location.longitude);
    emit(AddressFetched(result: result));
  }
}
