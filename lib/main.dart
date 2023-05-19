
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:vgtstask/bloc/auth_bloc.dart';

import 'package:http/http.dart'as http;
import 'package:vgtstask/screen/home_screen.dart';
import 'package:vgtstask/screen/login_screen.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        title: 'Firebase GitHub Authentication',
        theme: ThemeData(
          // scaffoldBackgroundColor: const Color(0xff24292e),
          textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthCubit, User?>(
          builder: (context, user) {
            print("jana");

            return user != null ?  HomeScreen() : LoginPag();
          },
        ),
      ),
    );
  }
}



