import 'package:flutter/material.dart';
import 'package:road_alert/models/incident_model.dart';
import 'package:road_alert/services/incidents_service.dart';

import '../models/incident_note_model.dart';

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
  List<IncidentNote>? _notes;

  @override
  void initState() {
    _imagePath = widget._incidentsService
        .getPublicUrlForPath(widget._incident.imagePath);
    widget._incidentsService
        .getNotesForIncident(widget._incident)
        .then((notes) {
      setState(() => _notes = notes);
      debugPrint(_notes!.length.toString());
    });
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
            _notes == null
                ? const Text('no notes')
                : ListView.builder(
                    itemCount: _notes!.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(_notes![index].text),
                      subtitle: Text(_notes![index].user),
                    ),
                    shrinkWrap: true,
                  ),
          ],
        ),
      ),
    );
  }
}
