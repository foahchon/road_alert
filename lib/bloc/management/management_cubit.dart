import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_alert/services/auth_service.dart';
import 'package:road_alert/services/incidents_service.dart';

import '../../models/incident_model.dart';
part 'management_state.dart';

enum ManagementStatus { unknown, requested, loading, loaded, notSignedIn }

class ManagementCubit extends Cubit<ManagementState> {
  final AuthService _authService;
  final IncidentsService _incidentsService;

  ManagementCubit(AuthService authService, IncidentsService incidentsService)
      : _authService = authService,
        _incidentsService = incidentsService,
        super(const ManagementState.unknown());

  Future<void> getIncidents() async {
    if (_authService.isSignedIn) {
      emit(const ManagementState.loading());
      final incidents = await _incidentsService.getIncidents();
      emit(IncidentsLoaded(incidents));
    }
  }
}
