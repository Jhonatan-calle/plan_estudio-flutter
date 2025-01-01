import 'dart:core';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan_estudio/utils/firebase_options.dart';
import 'package:plan_estudio/screen/loggin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plan de estudio',
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: GoogleFonts.nunitoSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
        ),
      ),
      home: const Loggin(),
    ));
}

