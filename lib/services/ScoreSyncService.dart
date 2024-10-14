import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _connectivitySubscription;

  ScoreSyncService() {
    // Listen for network changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Loop through the list of results
      for (var result in results) {
        if (result != ConnectivityResult.none) {
          _syncScoresToFirebase();  // Sync when the network is restored
        }
      }
    });
  }


  // Save the score to local storage when offline
  Future<void> saveScoreLocally(int score) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedScores = prefs.getStringList('unsyncedScores') ?? [];
    savedScores.add(score.toString());
    await prefs.setStringList('unsyncedScores', savedScores);
  }

  // Sync all locally stored scores to Firebase when online
  Future<void> _syncScoresToFirebase() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? unsyncedScores = prefs.getStringList('unsyncedScores');

    if (unsyncedScores != null && unsyncedScores.isNotEmpty) {
      for (String scoreString in unsyncedScores) {
        int score = int.parse(scoreString);
        await _saveScoreToFirebase(score);  // Save each score to Firebase
      }

      // Clear the locally stored scores after syncing
      await prefs.remove('unsyncedScores');
    }
  }

  // Save score directly to Firebase
  Future<void> _saveScoreToFirebase(int score) async {
    try {
      CollectionReference collectionReference = _firestore.collection("score");
      await collectionReference.add({
        'score': score,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Failed to sync score to Firebase: $e');
    }
  }

  // Call this function when a score is recorded in the game
  Future<void> saveScore(int score) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No connection, save score locally
      await saveScoreLocally(score);
    } else {
      // Online, save directly to Firebase
      await _saveScoreToFirebase(score);
    }
  }

  // Dispose the connectivity subscription when done
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
