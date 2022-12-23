import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './screens/camera_preview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (!dotenv.env.containsKey('SUPABASE_URL') ||
      !dotenv.env.containsKey('SUPABASE_ANON_KEY')) {
    return;
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  String newDescription = '';
  String newLocation = '';
  XFile? cameraImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
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

                      newDescription = value;
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter a location',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Must enter a location!';
                      }

                      newLocation = value;
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    child: const Text("TAKE PICTURE"),
                    onPressed: () {
                      Navigator.push<XFile>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CameraPreviewScreen(),
                        ),
                      ).then((file) {
                        setState(() {
                          cameraImage = file;
                        });
                      });
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  cameraImage != null
                      ? Image.file(File(cameraImage!.path))
                      : const Text('(No image taken)')
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            debugPrint('submit thingy.');

            final result = await supabase.from('incidents') //
                .insert({
              'description': newDescription,
              'location': newLocation
            }).select();
            debugPrint(result.length.toString());
          } else {
            debugPrint('Don\'t submit thingy.');
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
