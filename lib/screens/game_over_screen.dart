import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enhanced_flappy_bird/game/flappy_bird_game.dart';
import 'package:enhanced_flappy_bird/screens/main_menu_screen.dart';
import 'package:flutter/material.dart';

import '../custom_components/custom_button.dart';
import '../game/assets.dart';
import '../services/ScoreSyncService.dart';
import 'background_changer_screen.dart';

class GameOverScreen extends StatefulWidget {
  final FlappyBirdGame game;
  static const String id = 'gameOver';

  const GameOverScreen({super.key, required this.game});

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {


  @override
  void initState() {
    super.initState();
    // Save the score as soon as the game over screen is displayed
    // saveScoreToFirebase(widget.game.bird.score);
    ScoreSyncService _scoreSyncService = ScoreSyncService();
    _scoreSyncService.saveScore(widget.game.bird.score);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: ${widget.game.bird.score}',
              style: const TextStyle(
                fontSize: 60,
                color: Colors.white,
                fontFamily: 'Game',
              ),
            ),
            Image.asset(Assets.gameOver),
            const SizedBox(height: 50),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                  text: 'Restart',
                  onPressed: onRestart,
                ),
                const SizedBox(height: 10), // Space between buttons
                CustomButton(
                  text: 'Show High Score',
                  onPressed: showHighScore,
                  color: Colors.green,// New method to show the high score
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Change Background',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BackgroundChangerScreen(
                          onBackgroundChanged: (File? image) { // Update the callback to accept ui.Image
                            if (image != null) {
                              widget.game.updateBackgroundImage(image);// Update this to accept ui.Image
                              widget.game.bird.reset();
                              widget.game.overlays.remove('gameOver');
                            }
                          },
                          onStartGame: () {
                            Navigator.of(context).pop(); // Close the background changer screen
                            widget.game.resumeEngine();
                          },
                        ),
                      ),
                    );
                  },
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onRestart() {
    widget.game.bird.reset();
    widget.game.overlays.remove('gameOver');
    widget.game.resumeEngine();
  }

  // // Method to save score to Firebase
  // void saveScoreToFirebase(int score) async {
  //   CollectionReference collectionReference = FirebaseFirestore.instance.collection("score");
  //   await collectionReference.add({
  //     'score': score,
  //     'timestamp': DateTime.now().millisecondsSinceEpoch,
  //   });
  // }


  // Method to retrieve the highest score from Firebase
  void showHighScore() async {
    // Get the highest score from Firestore
    CollectionReference collectionReference = FirebaseFirestore.instance.collection("score");
    QuerySnapshot querySnapshot = await collectionReference
        .orderBy('score', descending: true) // Order by highest score
        .limit(1) // Get only the top 1 result
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var highScore = querySnapshot.docs.first['score'];
      // Show high score in a dialog
      _showAlertDialog(highScore);
    } else {
      _showAlertDialog(0); // If no score is found, show 0
    }
  }

  // Method to show an alert dialog with the high score
  void _showAlertDialog(int highScore) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(  // Center-align the title without expanding the dialog
            child: Text(
              'High Score',
              style: TextStyle(
                fontSize: 35,             // Adjust size as needed
                fontFamily: 'Game',       // Use your custom font defined in pubspec.yaml
                color: Colors.white,      // Optional: Customize color
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,  // Prevent the dialog from expanding
            children: [
              const Text(
                'Your highest score is:',
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Game',
                  color: Colors.white,
                ),
              ),
              Text(
                '$highScore',
                style: const TextStyle(
                  fontSize: 30,  // Make the score slightly larger
                  fontFamily: 'Game',
                  color: Colors.white, // Customize the color of the score
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green, // Optional: Adjust background color
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Game',
                  color: Colors.orange, // Optional: Customize color
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}
