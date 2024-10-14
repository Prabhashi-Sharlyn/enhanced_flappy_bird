import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:enhanced_flappy_bird/game/flappy_bird_game.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'dart:typed_data'; // Needed for Uint8List
import 'dart:ui' as ui; // Importing dart:ui to handle the image decoding
import 'package:path_provider/path_provider.dart';
import '../game/assets.dart';
import 'package:flutter/painting.dart';


class Background extends SpriteComponent with HasGameRef<FlappyBirdGame>{
  Background();

  @override
  Future<void> onLoad() async {
    // Load the background from documents directory
    final directory = await getApplicationDocumentsDirectory();
    final backgroundPath = '${directory.path}/background.png';
    final File backgroundFile = File(backgroundPath);

    if (await backgroundFile.exists()) {
      await backgroundFile.delete(); // Delete the existing background image
    }

    if (await backgroundFile.exists()) {
      await updateBackground(backgroundFile);
    } else {
      // Load a default image if no background image exists
      final background = await Flame.images.load(Assets.background);
      size = gameRef.size;
      sprite = Sprite(background);
    }
  }

// Method to update the background image
  Future<void> updateBackground(File imageFile) async {
    final bytes = await imageFile.readAsBytes(); // Read the image file as bytes
    final ui.Image uiImage = await decodeImageFromList(bytes); // Decode the image
    print('Image width: ${uiImage.width}, height: ${uiImage.height}');
    final image = await _fromUiImage(uiImage); // Convert to Flame image
    size = gameRef.size;
    sprite = Sprite(image); // Update the sprite
    markDirty(); // Mark the component as needing to be repainted
  }

  void markDirty() {
    removeFromParent(); // Removes the current component from the game tree
    add(this); // Re-add the updated component back to the game
  }


  // Helper method to decode image from byte list
  Future<ui.Image> decodeImageFromList(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  // Convert ui.Image to Flame-compatible Image
  Future<Image> _fromUiImage(ui.Image image) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception("Failed to convert ui.Image to ByteData.");
    }

    return Flame.images.decodeImageFromPixels(
      byteData.buffer.asUint8List(),
      image.width,
      image.height,
      PixelFormat.rgba8888,
    );
  }
}

extension on Images {
  // Decodes the pixel data into a Flame Image
  Future<ui.Image> decodeImageFromPixels(
      Uint8List pixelData,
      int width,
      int height,
      PixelFormat format,
      ) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromPixels(
      pixelData,
      width,
      height,
      format == PixelFormat.rgba8888 ? ui.PixelFormat.rgba8888 : ui.PixelFormat.rgba8888, // Handle pixel format
          (ui.Image img) {
        completer.complete(img);
      },
    );
    return completer.future;
  }
}