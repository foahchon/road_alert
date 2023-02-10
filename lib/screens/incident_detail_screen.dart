import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:road_alert/models/incident_model.dart';
import 'package:road_alert/services/incidents_service.dart';
import 'package:road_alert/widgets/confirmation_dialog.dart';
import 'package:road_alert/widgets/loading_overlay.dart';

import '../bloc/management/incidents_cubit.dart';
import '../main.dart';

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

class IncidentDetailScreenState extends State<IncidentDetailScreen>
    with TickerProviderStateMixin {
  String? _imagePath;
  final _newNoteTextController = TextEditingController();
  late TabController _tabController;
  late final IncidentsCubit _managementCubit;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2);
    _imagePath = widget._incidentsService
        .getPublicUrlForPath(widget._incident.imagePath);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _managementCubit = context.read<IncidentsCubit>();
      _managementCubit.getNotesForIncident(widget._incident);
      _managementCubit.getCompletedForIncident(widget._incident);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IncidentsCubit, IncidentsCubitState>(
      listener: (context, state) {
        if (state is IncidentNotesLoading) {
          LoadingOverlay.of(context).show();
        } else if (state is IncidentNotesLoaded) {
          LoadingOverlay.of(context).hide();
        } else if (state is IncidentsCubitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: Image.network(
                    _imagePath!,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 3),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color>(
                      Colors.black12,
                    ),
                  ),
                  icon: Icon(
                    Icons.navigation,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  label: Text(
                    'Navigate',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                  onPressed: () async {
                    (await MapLauncher.installedMaps).first.showDirections(
                          destination: Coords(
                            widget._incident.latitude,
                            widget._incident.longitude,
                          ),
                        );
                  },
                ),
                BlocBuilder<IncidentsCubit, IncidentsCubitState>(
                    buildWhen: (_, current) => current is IncidentCompleted,
                    builder: (context, state) {
                      var textAndIconColor =
                          Theme.of(context).textTheme.bodyMedium!.color;
                      var completeIcon = Icons.check_circle_outline;
                      var completeText = 'Complete';
                      var promptText =
                          'Are you sure you want to mark this incident complete?';
                      var titleText = 'Mark incident complete?';

                      if (state is IncidentCompleted) {
                        widget._incident.complete = state.completed;
                        if (state.completed) {
                          textAndIconColor =
                              const Color.fromARGB(255, 32, 138, 36);
                          completeIcon = Icons.check_circle;
                          completeText = 'Completed';
                          promptText =
                              'Are you sure you sure you want to mark this incident incomplete?';
                          titleText = 'Mark incident incomplete?';
                        }
                      }

                      return TextButton.icon(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all<Color>(
                            Colors.black12,
                          ),
                        ),
                        icon: Icon(
                          completeIcon,
                          color: textAndIconColor,
                        ),
                        label: Text(
                          completeText,
                          style: TextStyle(
                            color: textAndIconColor,
                          ),
                        ),
                        onPressed: () async {
                          var confirmationDialog = ConfirmationDialog(
                              title: titleText, prompt: promptText);

                          var confirmation =
                              await confirmationDialog.getConfirmation(context);
                          if (confirmation) {
                            _managementCubit.setIncidentComplete(
                                widget._incident, !widget._incident.complete);
                          }
                        },
                      );
                    }),
              ],
            ),
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              tabs: const [
                Tab(
                  child: Text('Overview'),
                ),
                Tab(
                  child: Text('Notes'),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget._incident.address,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Text(widget._incident.description),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'submitted by ${widget._incident.email} on ${dateTimeFormat.format(widget._incident.createdAt!.toLocal())}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _newNoteTextController,
                          minLines: 2,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        TextButton(
                          child: const Text('Add note'),
                          onPressed: () async {
                            await widget._incidentsService.addNoteForIncident(
                                widget._incident, _newNoteTextController.text);
                            _managementCubit
                                .getNotesForIncident(widget._incident);
                            _newNoteTextController.clear();
                            FocusManager.instance.primaryFocus
                                ?.unfocus(); // hide keyboard
                          },
                        ),
                        BlocBuilder<IncidentsCubit, IncidentsCubitState>(
                          builder: (context, state) {
                            if (state is IncidentNotesLoaded) {
                              return Expanded(
                                child: ListView.builder(
                                  itemCount: state.notes.length,
                                  itemBuilder: (context, index) => ListTile(
                                    title: Text(
                                      state.notes[index].text,
                                    ),
                                    subtitle: Text(
                                      '${state.notes[index].user} on ${dateTimeFormat.format(state.notes[index].createdAt!.toLocal())}',
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
