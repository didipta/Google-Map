import 'package:flutter/material.dart';
import 'package:google_map/Homescreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController _googleMapController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],


      ),
      debugShowCheckedModeBanner: false,
      home:Homescreen()
    );
  }
}
