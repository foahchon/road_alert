import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:road_alert/bloc/management/management_cubit.dart';
import 'package:road_alert/screens/incident_detail_screen.dart';
import 'package:road_alert/services/incidents_service.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  createState() => ManagementScreenState();
}

class ManagementScreenState extends State<ManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ManagementCubit>().getIncidents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Incidents in Zip")),
      body: BlocBuilder<ManagementCubit, ManagementState>(
        builder: (context, state) {
          if (state is IncidentsLoaded) {
            return ListView.builder(
              itemCount: state.incidents.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(state.incidents[index].description),
                subtitle: Text(state.incidents[index].address),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => IncidentDetailScreen(
                        incident: state.incidents[index],
                        incidentsService: GetIt.I.get<IncidentsService>(),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return Container();
        },
      ),
    );
  }
}
