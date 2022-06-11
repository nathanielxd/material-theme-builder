// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:material_theme_builder/material_theme_builder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: MaterialThemeBuilder(
          primary: Colors.blue,
          secondary: Colors.purple,
          tertiary: Colors.lightBlue
        ).toScheme()
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: MaterialThemeBuilder.tonalPalette(Color(0xff80BC95))
            .entries.map((e) => Container(
              height: 60,
              width: 200,
              color: e.value,
              child: Center(
                child: Text(e.key.toString(), 
                  style: TextStyle(
                    color: e.key < 60 ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700
                  )
                ),
              ),
            ))
            .toList()
        )
      )
    );
  }
}
