import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:road_alert/bloc/authentication/authentication_bloc.dart';
import 'package:road_alert/bloc/management/management_cubit.dart';
import 'package:road_alert/screens/camera_preview_screen.dart';
import 'package:road_alert/screens/login_screen.dart';
import 'package:road_alert/screens/management_screen.dart';
import 'package:road_alert/services/auth_service.dart';
import 'package:road_alert/services/google_maps_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:road_alert/services/incidents_service.dart';
import 'package:road_alert/services/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (!dotenv.env.containsKey('SUPABASE_URL') ||
      !dotenv.env.containsKey('SUPABASE_ANON_KEY')) {
    throw const AuthException(
        'Supabase URL and Supabase anon key must be present.');
  }

  Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  GetIt.I.registerFactory(() => GoogleMapsService(
      googleMapsUrl: "https://maps.googleapis.com/maps/api/geocode",
      apiKey: dotenv.env["GOOGLE_MAPS_API_KEY"]!));
  GetIt.I.registerSingleton(LocationService());
  GetIt.I.registerSingleton(AuthService());
  GetIt.I.registerSingleton(Supabase);
  GetIt.I.registerFactory(() => IncidentsService(GetIt.I.get<AuthService>(),
      functionUrl: '${dotenv.env['SUPABASE_FUNCTIONS_URL']}/hello-world'));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthenticationBloc(GetIt.I.get<AuthService>()),
        ),
        BlocProvider(
          create: (context) => ManagementCubit(
              GetIt.I.get<AuthService>(), GetIt.I.get<IncidentsService>()),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RouteAware {
  final _formKey = GlobalKey<FormState>();
  String _newDescription = '';
  String _currentAddress = '';
  XFile? _cameraImage;
  final _authService = GetIt.I.get<AuthService>();

  @override
  void initState() {
    super.initState();

    var locationService = GetIt.I.get<LocationService>();
    var googleMapsService = GetIt.I.get<GoogleMapsService>();

    locationService.getLocation().then((position) {
      googleMapsService
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
      if (!_authService.isSignedIn) {
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
        appBar: AppBar(title: Text(widget.title), actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                enabled: false,
                child: Text(_authService.userEmail!),
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const ManagementScreen(),
                    ),
                  );
                  break;

                case 2:
                  _authService.signOut();
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
                top: 45,
                left: 15,
                right: 15,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter a description',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Must enter a description!';
                        }

                        _newDescription = value;
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      _currentAddress.isNotEmpty
                          ? _currentAddress
                          : 'Loading address...',
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    ElevatedButton(
                      child: const Text("Take Picture"),
                      onPressed: () async {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) => const CameraPreviewScreen(),
                          ),
                        )
                            .then((image) {
                          setState(() {
                            _cameraImage = image;
                          });
                        });
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    _cameraImage == null
                        ? const Text("(No image taken.)")
                        : Column(
                            children: [
                              Image.file(File(_cameraImage!.path)),
                              const SizedBox(
                                height: 25,
                              ),
                              ElevatedButton(
                                child: const Text('Submit Report'),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    var incidentsService =
                                        GetIt.I.get<IncidentsService>();
                                    var locationService =
                                        GetIt.I.get<LocationService>();

                                    var location =
                                        await locationService.getLocation();
                                    incidentsService.createIncident(
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
