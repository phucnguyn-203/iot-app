import 'dart:async';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceControl extends StatefulWidget {
  const VoiceControl({super.key});

  @override
  State<VoiceControl> createState() => _VoiceControlState();
}

class _VoiceControlState extends State<VoiceControl> {
  bool isListening = false;
  bool isLoading = false;
  String text = 'Press the button and start speaking';
  String errorMessage = '';
  stt.SpeechToText? _speech;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<void> _handleVoiceResult(val) async {
    setState(() {
      text = val.recognizedWords;
      errorMessage = '';
    });
    if (val.finalResult == true) {
      setState(() => isLoading = true);
      try {
        final response = await http
            .post(
          Uri.parse('http://localhost:3000/api'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'instruction': val.recognizedWords}),
        )
            .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);
          String responseText = responseBody['message'];
          await _speak(responseText);
        } else {
          throw HttpException('Server error: ${response.statusCode}');
        }
      } catch (e) {
        String errorText = 'An error occurred';
        if (e is TimeoutException) {
          errorText = 'Connection timed out. Please try again.';
        } else if (e is HttpException) {
          errorText = e.message;
        }

        setState(() => errorMessage = errorText);
        await _speak('Sorry, there was an error: $errorText');
        print('Exception: $e');
      } finally {
        setState(() => isLoading = false);
      }
    }
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
          onResult: (val) async {
            print(val.recognizedWords);
            _handleVoiceResult(val);
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
