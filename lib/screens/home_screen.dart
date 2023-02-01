import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_alert/services/auth_service.dart';
import 'package:road_alert/services/google_maps_service.dart';
import 'package:road_alert/services/incidents_service.dart';
import 'package:road_alert/services/location_service.dart';

import '../bloc/authentication/authentication_bloc.dart';
import '../widgets/image_form_field.dart';
import 'login_screen.dart';
import 'management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {super.key,
      required AuthService authService,
      required LocationService locationService,
      required GoogleMapsService googleMapsService,
      required IncidentsService incidentsService})
      : _authService = authService,
        _locationService = locationService,
        _googleMapsService = googleMapsService,
        _incidentsService = incidentsService;

  final AuthService _authService;
  final LocationService _locationService;
  final GoogleMapsService _googleMapsService;
  final IncidentsService _incidentsService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _newDescription = '';
  String _currentAddress = '';
  XFile? _cameraImage;

  @override
  void initState() {
    super.initState();

    widget._locationService.getLocation().then((position) {
      widget._googleMapsService
          .getFormattedAddress(position.latitude, position.longitude)
          .then((address) {
        if (mounted) {
          setState(() {
            _currentAddress = address;
          });
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget._authService.isSignedIn) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.status == AuthenticationStatus.signedOut) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Report Incident'), actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                enabled: false,
                child: Text(widget._authService.userEmail!),
              ),
              const PopupMenuDivider(
                height: 10,
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Switch to Manager View'),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text('Sign Out'),
              )
            ],
            onSelected: (value) {
              switch (value) {
                case 1:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ManagementScreen(),
                    ),
                  );
                  break;

                case 2:
                  widget._authService.signOut();
                  break;

                default:
                  break;
              }
            },
          ),
        ]),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 15,
                right: 15,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _currentAddress.isNotEmpty
                          ? _currentAddress
                          : 'Loading address...',
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    ImageFormField(
                      context: context,
                      onSaved: (newValue) {
                        _cameraImage = newValue;
                      },
                      validator: (value) {
                        if (value == null) {
                          debugPrint('validated.');
                          return 'Image must be selected.';
                        }

                        return null;
                      },
                      autovalidateMode: AutovalidateMode.disabled,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter a description',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Must enter a description!';
                        }

                        _newDescription = value;
                        return null;
                      },
                    ),
                    Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          child: const Text('Submit Report'),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var location =
                                  await widget._locationService.getLocation();
                              widget._incidentsService.createIncident(
                                  _newDescription,
                                  _currentAddress,
                                  location.latitude,
                                  location.longitude,
                                  _cameraImage!.path);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
