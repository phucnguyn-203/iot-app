import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoiceControl extends StatefulWidget {
  const VoiceControl({super.key});

  @override
  State<VoiceControl> createState() => _VoiceControlState();
}

class _VoiceControlState extends State<VoiceControl> {
  bool isListening = false;
  String text = 'Press the button and start speaking';
  stt.SpeechToText? _speech;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void listen() async {
    if (!isListening) {
      bool available = await _speech!.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          isListening = true;
          text = 'Listening...';
        });
        _speech!.listen(
          pauseFor: const Duration(seconds: 3),
          onResult: (val) async {
            print(val.recognizedWords);

            setState(() {
              text = val.recognizedWords;
            });

            if (val.finalResult == true) {
              print("Final result " + val.recognizedWords);

              final response = await http.post(
                Uri.parse('https://cb96-113-23-109-117.ngrok-free.app/api'),
                headers: {
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'instruction': val.recognizedWords,
                }),
              );
              print(response.body);
            }
          },
        );
      }
    } else {
      if (!mounted) return;
      setState(() => isListening = false);
      text = 'Press the button and start speaking';
      _speech!.stop();
    }
  }

  @override
  void dispose() {
    _speech?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        glowColor: Colors.deepPurpleAccent,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          onPressed: () {
            listen();
          },
          backgroundColor: Colors.deepPurple,
          shape: const CircleBorder(),
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            size: 35,
          ),
        ),
      ),
      appBar: AppBar(
        title: GradientText(
          'Voice Control',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
          colors: const [
            Colors.deepPurpleAccent,
            Colors.deepPurple,
            Colors.purple,
          ],
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 75),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
