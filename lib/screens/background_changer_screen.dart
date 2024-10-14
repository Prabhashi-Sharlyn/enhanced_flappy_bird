import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../custom_components/custom_button.dart';

class BackgroundChangerScreen extends StatefulWidget {
  final Function(File?) onBackgroundChanged; // Callback to notify background change
  final VoidCallback onStartGame; // Callback to start the game

  const BackgroundChangerScreen({
    Key? key,
    required this.onBackgroundChanged,
    required this.onStartGame, // Initialize onStartGame callback
  }) : super(key: key);

  @override
  _BackgroundChangerScreenState createState() => _BackgroundChangerScreenState();
}

class _BackgroundChangerScreenState extends State<BackgroundChangerScreen> {
  File? _backgroundImage;

  // Method to capture an image from the camera
  Future<void> _captureBackgroundImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      // Save the captured image as background.png
      final directory = await getApplicationDocumentsDirectory();
      final File newImage = await File(imageFile.path).copy('${directory.path}/background.png');

      setState(() {
        _backgroundImage = newImage; // Update the state with the new background image
      });

      // Notify the parent widget about the new background image
      widget.onBackgroundChanged(_backgroundImage);
      print("Image saved at: ${newImage.path}");
    }
  }

  // Method to set the background image in the game
  void _setBackground() {
    if (_backgroundImage != null) {
      // Notify the parent widget that the background should be set
      widget.onBackgroundChanged(_backgroundImage);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Background image set!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No background image selected!')),
      );
    }
  }

  // Method to start the game
  void _startGame() {
    widget.onStartGame(); // Call the callback to start the game
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen background image from assets
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'), // Set the background image
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content with AppBar and other widgets
          Column(
            children: [
              // Custom AppBar with transparent background
              AppBar(
                title: const Text(
                  'Change Background',
                  style: TextStyle(
                    fontFamily: 'Game', // Custom font
                  ),
                ),
                backgroundColor: Colors.transparent, // Make AppBar transparent
                elevation: 0, // Remove AppBar shadow
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _backgroundImage != null
                          ? Image.file(
                        _backgroundImage!,
                        fit: BoxFit.cover,
                        height: 400,
                      )
                          : const Text(
                        'No background selected',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontFamily: 'Game', // Custom font 'Game'
                        ),
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: _captureBackgroundImage,
                        child: const Icon(Icons.camera_alt),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'Set Background',
                        onPressed: _setBackground,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'Start Game',
                        onPressed: _startGame,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
