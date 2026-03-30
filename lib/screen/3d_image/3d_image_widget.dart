// ignore: file_names
import 'dart:async' show Timer;
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  Object? door;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D Model Viewer')),
      body: Center(
        child:
            // Text(
            //   'Welcome to the Home Page',
            //   style: TextStyle(fontSize: 24),
            // ),
            Cube(
              onSceneCreated: (Scene scene) {
                door = Object(
                  fileName: 'assets/models/Door.obj',
                  scale: Vector3(10.0, 10.0, 10.0),
                );
                scene.world.add(door!);
                scene.camera.zoom = 10;

                // Rotate every 50ms
                Timer.periodic(Duration(milliseconds: 50), (timer) {
                  setState(() {
                    door!.rotation.y += 2;
                  });
                });
              },
            ),
      ),
    );
  }
}
