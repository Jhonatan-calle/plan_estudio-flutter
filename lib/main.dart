import 'dart:core';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:plan_estudio/utils/firebase_options.dart';
import 'package:plan_estudio/screen/loggin.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plan de estudio',
      theme: ThemeData(),
      home: Loggin(),
    ));
}

