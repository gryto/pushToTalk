import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'src/preference.dart'; // Update with your preference import

class SoundRecorder extends StatefulWidget {
  final String userId;

  const SoundRecorder({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _SoundRecorderState createState() => _SoundRecorderState();
}

class _SoundRecorderState extends State<SoundRecorder> {
  final FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _soundPlayer = FlutterSoundPlayer();
  final stt.SpeechToText _speech = stt.SpeechToText();
  late IO.Socket socket;
  String _text = '';
  String _audioPath = '';
  bool _isRecording = false;
  bool _isPlaying = false;
  SharedPref sharedPref = SharedPref();

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initPlayer();
    initSocket();
    _initSpeechToText();
  }

  void _initRecorder() async {
    try {
      await _soundRecorder.openRecorder();
    } catch (e) {
      print('Failed to open audio session: $e');
    }
  }

  void _initPlayer() async {
    try {
      await _soundPlayer.openPlayer();
    } catch (e) {
      print('Failed to open audio session: $e');
    }
  }

  void _initSpeechToText() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (error) => print('onError: $error'),
    );

    if (!available) {
      print('Speech recognition unavailable');
    }
  }

  @override
  void dispose() {
    _soundRecorder.closeRecorder();
    _soundPlayer.closePlayer();
    _speech.cancel();
    socket.disconnect();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _audioPath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _soundRecorder.startRecorder(
        codec: Codec.pcm16WAV,
        toFile: _audioPath,
      );
      setState(() {
        _isRecording = true;
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
      );
    } catch (e) {
      print('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _soundRecorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      _speech.stop();
      await sendAudio(_audioPath);
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }

  Future<void> _playRecording() async {
    try {
      if (_isPlaying) {
        await _soundPlayer.stopPlayer();
      } else {
        await _soundPlayer.startPlayer(
          fromURI: _audioPath,
          codec: Codec.pcm16WAV,
          whenFinished: () {
            setState(() {
              _isPlaying = false;
            });
          },
        );
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      print('Failed to play recording: $e');
    }
  }

  void initSocket() async {
    try {
      String accessToken = await sharedPref.getPref("access_token");
      var bearerToken = 'Bearer $accessToken';

      socket = IO.io(
        'http://paket7.kejaksaan.info:3019',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': bearerToken})
            .build(),
      );

      socket.connect();

      socket.onConnect((_) {
        String userId = widget.userId.toString();
        socket.emit('Join_Room_Ptt', {'user_id': userId});
      });

      socket.onDisconnect((_) {
        print('Connection Disconnected');
      });

      socket.onConnectError((err) {
        print('Connection Error: $err');
      });

      socket.onError((err) {
        print('Socket Error: $err');
      });

      socket.on('audioDataReceived', (audioReceived) {
        String content = audioReceived['ptt']['content'];
        String audioUrl = 'http://paket7.kejaksaan.info:3019/$content';
        print('Audio URL: $audioUrl');
      });
    } catch (e) {
      print('Socket initialization error: $e');
    }
  }

  Future<void> sendAudio(String audioPath) async {
    final file = File(audioPath);

    if (!file.existsSync()) {
      print("File does not exist.");
      return;
    }

    try {
      List<int> audioBytes = await file.readAsBytes();
      Uint8List audioBlob = Uint8List.fromList(audioBytes);

      Map<String, dynamic> messageMap = {
        'audioBlob': audioBlob,
        'channel_id': 1,
        'voice_teks': _text,
      };

      socket.emit('audioData', messageMap);
      print("Data sent: $messageMap");
    } catch (e) {
      print("Error sending data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sound Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_isRecording ? 'Recording...' : 'Press button to start recording'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _playRecording,
              child: Text(_isPlaying ? 'Stop Playing' : 'Play Recording'),
            ),
            SizedBox(height: 20),
            Text('Recognized Text:'),
            Text(_text),
          ],
        ),
      ),
    );
  }
}
