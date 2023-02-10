import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:road_alert/bloc/management/incidents_cubit.dart';
import 'package:road_alert/extensions/string_extensions.dart';
import 'package:road_alert/main.dart';
import 'package:road_alert/screens/incident_detail_screen.dart';
import 'package:road_alert/services/incidents_service.dart';
import 'package:road_alert/widgets/loading_overlay.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  createState() => IncidentsScreenState();
}

class IncidentsScreenState extends State<IncidentsScreen> with RouteAware {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents in Zip'),
      ),
      body: BlocConsumer<IncidentsCubit, IncidentsCubitState>(
        listener: (context, state) {
          if (state is IncidentsLoading) {
            LoadingOverlay.of(context).show();
          } else if (state is IncidentsLoaded) {
            LoadingOverlay.of(context).hide();
          } else if (state is IncidentsCubitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is IncidentsLoaded) {
            return ListView.builder(
              itemCount: state.incidents.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(state.incidents[index].address),
                subtitle: Text(
                  state.incidents[index].description.truncate(30),
                ),
                trailing: const Icon(Icons.chevron_right_sharp),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentsCubit>().getIncidents();
    });
  }

  @override
  void didPopNext() {
    context.read<IncidentsCubit>().getIncidents();
  }
}
