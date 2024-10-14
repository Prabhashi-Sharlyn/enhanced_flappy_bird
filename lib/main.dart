import 'package:enhanced_flappy_bird/screens/game_over_screen.dart';
import 'package:enhanced_flappy_bird/screens/main_menu_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart'; // Use Material instead of Cupertino for Material design components

import 'game/flappy_bird_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final game = FlappyBirdGame();

  runApp(
    MaterialApp(  // Wrap GameWidget in MaterialApp
      home: Scaffold( // Add Scaffold for proper Material UI
        body: GameWidget(
          game: game,
          initialActiveOverlays: const [MainMenuScreen.id],
          overlayBuilderMap: {
            'mainMenu': (context,_) => MainMenuScreen(game: game),
            'gameOver': (context,_) => GameOverScreen(game: game),
          },
        ),
      ),
    ),
  );
}
