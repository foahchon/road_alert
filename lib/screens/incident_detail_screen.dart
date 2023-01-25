import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:road_alert/models/incident_model.dart';
import 'package:road_alert/services/incidents_service.dart';

import '../bloc/management/management_cubit.dart';

class IncidentDetailScreen extends StatefulWidget {
  final Incident _incident;
  final IncidentsService _incidentsService;

  const IncidentDetailScreen(
      {super.key, required incident, required incidentsService})
      : _incident = incident,
        _incidentsService = incidentsService;

  @override
  createState() => IncidentDetailScreenState();
}

class IncidentDetailScreenState extends State<IncidentDetailScreen> {
  String? _imagePath;
  final _myController = TextEditingController();

  @override
  void initState() {
    _imagePath = widget._incidentsService
        .getPublicUrlForPath(widget._incident.imagePath);
    context.read<ManagementCubit>().getNotesForIncident(widget._incident);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Description",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(widget._incident.description),
            Text(
              "Address",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(widget._incident.address),
            Text(
              "Coordinates",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
                '(${widget._incident.latitude}, ${widget._incident.longitude})'),
            _imagePath == null
                ? const Text('Loading...')
                : Image.network(_imagePath!),
            ElevatedButton(
              child: const Text('Complete'),
              onPressed: () {
                debugPrint('Completed incident with id ${widget._incident.id}');
                widget._incidentsService.completeIncident(widget._incident);
              },
            ),
            ElevatedButton(
              child: const Text('Navigate To Location'),
              onPressed: () async {
                (await MapLauncher.installedMaps).first.showDirections(
                    destination: Coords(
                        widget._incident.latitude, widget._incident.longitude));
              },
            ),
            TextField(
              controller: _myController,
            ),
            ElevatedButton(
              child: const Text('Add note'),
              onPressed: () async {
                await context
                    .read<ManagementCubit>()
                    .addNoteForIncident(widget._incident, _myController.text);
                _myController.clear();
              },
            ),
            BlocBuilder<ManagementCubit, ManagementState>(
              builder: (context, state) {
                if (state is IncidentNotesLoading) {
                  return const Text('Notes loading...');
                } else if (state is IncidentNotesLoaded) {
                  return ListView.builder(
                    itemCount: state.notes.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(state.notes[index].text),
                      subtitle: Text(state.notes[index].user),
                    ),
                    shrinkWrap: true,
                  );
                } else {
                  return const Text('Error.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
