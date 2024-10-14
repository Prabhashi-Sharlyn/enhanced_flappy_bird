import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:enhanced_flappy_bird/components/background.dart';
import 'package:enhanced_flappy_bird/components/ground.dart';
import 'package:enhanced_flappy_bird/components/pipe_group.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

import '../components/bird.dart';
import 'configuration.dart';
import 'package:flutter/painting.dart';

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  FlappyBirdGame();

  late Bird bird;
  late TextComponent score;
  late TimerComponent interval;
  late Background backgroundComponent; // Store reference to the background
  bool isHit = false;

  @override
  Future<void> onLoad() async {

    backgroundComponent = Background();  // Initialize background component

    addAll([
      // Background(),
      backgroundComponent,  // Add the background
      Ground(),
      bird = Bird(),
      score = buildScore(),
      // PipeGroup(),
    ]);

    interval = TimerComponent(
      period: Config.pipeInterval,
      repeat: true,
      onTick: () => add(PipeGroup()),
    );

    // add(interval);
  }

// Method to update the background image
  Future<void> updateBackgroundImage(File image) async {
    await backgroundComponent.updateBackground(image); // Call the update method from the Background component
  }


  TextComponent buildScore() {
    return TextComponent(
        text: 'Score: 0',
        position: Vector2(size.x / 2, size.y / 2 * 0.2),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
              fontSize: 40, fontFamily: 'Game', fontWeight: FontWeight.bold),
        )
    );
  }


  @override
  void onTap() {
    super.onTap();
    bird.fly();
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);

    score.text = 'Score: ${bird.score}';
  }

}