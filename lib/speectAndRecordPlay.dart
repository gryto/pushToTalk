import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:googleapis/speech/v1.dart' as speech;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';

class RecordingTextScreen extends StatefulWidget {
  final String userId;
  const RecordingTextScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _RecordingTextScreenState createState() => _RecordingTextScreenState();
}

class _RecordingTextScreenState extends State<RecordingTextScreen> {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String _text = "Hold the button and start speaking";
  String _audioPath = '';
  late Record audioRecord;

  @override
  void initState() {
    super.initState();
    audioRecord = Record();
    _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> startRecording() async {
    bool permissionGranted = await audioRecord.hasPermission();

    // _audioPath = '/path/to/audio.aac';

    if (permissionGranted) {
      await _recorder.startRecorder(toFile: _audioPath);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    await _transcribeAudio();
  }

  Future<void> _transcribeAudio() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(
      json.decode(await File('path/to/your/credentials.json').readAsString()),
    );

    final scopes = [speech.SpeechApi.cloudPlatformScope];
    final client = await clientViaServiceAccount(accountCredentials, scopes);

    final api = speech.SpeechApi(client);
    final request = speech.RecognizeRequest.fromJson({
      'config': {
        'encoding': 'LINEAR16',
        'sampleRateHertz': 16000,
        'languageCode': 'en-US',
      },
      'audio': {
        'content': base64Encode(File(_audioPath).readAsBytesSync()),
      },
    });

    final response = await api.speech.recognize(request);
    setState(() {
      _text = response.results?.first.alternatives?.first.transcript ??
          'No transcription';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel 3'),
      ),
      body: Center(
        child: Column(
          children: [
            SingleChildScrollView(
              reverse: true,
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                margin: const EdgeInsets.only(bottom: 150),
                child: SelectableText(
                  _text,
                  style: TextStyle(
                      fontSize: 18,
                      color: _isRecording ? Colors.black87 : Colors.black54),
                ),
              ),
            ),
            IconButton(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic,
                  color: Colors.red, size: 50),
              onPressed: _isRecording ? stopRecording : startRecording,
            ),
          ],
        ),
      ),
    );
  }
}
