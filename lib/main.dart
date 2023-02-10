import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:road_alert/bloc/authentication/authentication_bloc.dart';
import 'package:road_alert/bloc/management/incidents_cubit.dart';
import 'package:road_alert/screens/home_screen.dart';
import 'package:road_alert/services/auth_service.dart';
import 'package:road_alert/services/google_maps_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:road_alert/services/incidents_service.dart';
import 'package:road_alert/services/location_service.dart';
import 'package:road_alert/widgets/loading_overlay.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final routeObserver = RouteObserver<ModalRoute<void>>();

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
      functionUrl: '${dotenv.env['SUPABASE_FUNCTIONS_URL']}/create-incident'));
  GetIt.I.registerFactory(() => HomeScreen(
        authService: GetIt.I.get<AuthService>(),
        locationService: GetIt.I.get<LocationService>(),
        googleMapsService: GetIt.I.get<GoogleMapsService>(),
        incidentsService: GetIt.I.get<IncidentsService>(),
      ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthenticationBloc(
            GetIt.I.get<AuthService>(),
          ),
        ),
        BlocProvider(
          create: (context) => IncidentsCubit(
            GetIt.I.get<AuthService>(),
            GetIt.I.get<IncidentsService>(),
            GetIt.I.get<LocationService>(),
            GetIt.I.get<GoogleMapsService>(),
          ),
        )
      ],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: LoadingOverlay(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Road Alert',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: GetIt.I.get<HomeScreen>(),
            navigatorObservers: [routeObserver],
          ),
        ),
      ),
    );
  }
}
