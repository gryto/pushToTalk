// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_sound/flutter_sound.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

// class AudioToTextPage extends StatefulWidget {
//   @override
//   _AudioToTextPageState createState() => _AudioToTextPageState();
// }

// class _AudioToTextPageState extends State<AudioToTextPage> {
//   late stt.SpeechToText _speech;
//   FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
//   bool _isListening = false;
//   bool _isRecording = false;
//   String _text = "Press the button to start speaking";
//   late String _filePath;

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _initRecorder();
//   }

//   Future<void> _initRecorder() async {
//     Directory tempDir = await getTemporaryDirectory();
//     _filePath = '${tempDir.path}/audio_recording.wav';
//     print("filepathsuara");
//     print(_filePath);

//     await _audioRecorder.openRecorder();
//   }

//   Future<void> _startListening() async {
//     bool available = await _speech.initialize(
//       onStatus: (val) => print('onStatus: $val'),
//       onError: (val) => print('onError: $val'),
//     );

//     if (available) {
//       setState(() {
//         _isListening = true;
//         _isRecording = true;
//       });

//       await _audioRecorder.startRecorder(
//         toFile: _filePath,
//         codec: Codec.pcm16WAV,
//       );

//       _speech.listen(
//         onResult: (val) => setState(() {
//           _text = val.recognizedWords;
//           print("hasiltextsuara");
//           print(_text);
//         }),
//       );
//     }
//   }

//   Future<void> _stopListening() async {
//     setState(() {
//       _isListening = false;
//       _isRecording = false;
//     });

//     await _speech.stop();
//     await _audioRecorder.stopRecorder();
//   }

//   @override
//   void dispose() {
//     _speech.stop();
//     _audioRecorder.closeRecorder();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Audio to Text with Recording'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _isListening ? _stopListening : _startListening,
//               child: Text(_isListening ? 'Stop' : 'Start'),
//             ),
//             SizedBox(height: 20),
//             Text(_text),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pushtotalk/src/preference.dart';
import 'package:pushtotalk/src/toast.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:speech_to_text/speech_to_text.dart';

class AudioRecordingPageFix extends StatefulWidget {
  final String userId;
  const AudioRecordingPageFix({
    super.key,
    required this.userId,
  });

  @override
  _AudioRecordingPageFixState createState() => _AudioRecordingPageFixState();
}

class _AudioRecordingPageFixState extends State<AudioRecordingPageFix> {
  FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String _filePath = '';
  List AudioList = [];
  String audioPath = "";
  var text = "Hold the button and start speaking";
  TextEditingController controller = TextEditingController();
  late IO.Socket socket;
  String audioUrl = '';
  SharedPref sharedPref = SharedPref();
  SpeechToText speechToText = SpeechToText();

  // get sharedPref => null;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    initSocket();
  }

  Future<void> _initRecorder() async {
    await _audioRecorder.openRecorder();
    await _audioPlayer.openPlayer();
    Directory tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/audio_recording.wav';
    print("filepathdmn");
    print(_filePath);
  }

  Future<void> _startRecording() async {
    // bool available = await speechToText.initialize();
    var available = await speechToText.initialize();

    setState(() {
      _isRecording = true;
    });

    if (available) {
      setState(() {
        _isRecording = true;
      });
      speechToText.listen(
          listenFor: const Duration(days: 1),
          onResult: (result) {
            setState(() {
              text = result.recognizedWords;
              print("text");
              print(text);
            });
          });
    }

    await _audioRecorder.startRecorder(
      toFile: _filePath,
      codec: Codec.pcm16WAV,
    );
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
    });

    await _audioRecorder.stopRecorder();
  }

  initSocket() async {
    String accessToken = await sharedPref.getPref("access_token");
    print("Access token: $accessToken");
    var bearerToken = 'Bearer $accessToken';
    print("tokenserever");
    print(bearerToken);

    // Create the socket instance
    socket = IO.io(
      'http://paket7.kejaksaan.info:3019',
      IO.OptionBuilder()
          .setTransports(['websocket']).setAuth({'token': bearerToken}).build(),
    );

    // Connect the socket
    socket.connect();

    // Set up event listeners
    socket.onConnect((_) {
      print('Connection established22');
      String userId = widget.userId.toString();
      print("User ID: $userId");
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
      print("Chat history received:");
      print(audioReceived);
      AudioList.add((audioReceived));
      print("chatmessagehistory");
      print(AudioList);
      print("inisblmkontentsuata");

      String content = audioReceived['ptt']['content'];
      print("iniisikonten");
      print(content);
      audioUrl = 'http://paket7.kejaksaan.info:3019/$content';
      print("inisudiodriserver");
      print(audioUrl);
    });
  }

  Future<void> sendAudio(String audioPath) async {
    final file = File(audioPath);
    print("audiopathsendaudio");
    print(file);

    if (!file.existsSync()) {
      print("File does not exist.");
      return;
    }

    try {
      List<int> audioBytes = await file.readAsBytes();
      Uint8List audioBlob = Uint8List.fromList(audioBytes);
      print("audioBytes: $audioBlob");

      Map<String, dynamic> messageMap = {
        'audioBlob': audioBlob,
        'channel_id': 1,
        'voice_teks': text
      };

      print("ini validasi data sebelum kirim pesan");
      print(messageMap);

      socket.emit('audioData', messageMap);
      print("ini isian apakah data udah kekirim");
      print(messageMap);
      print("receiveenya");
      controller.clear();
    } catch (e) {
      print("data tidak kekirim");
      toastShort(context, e.toString());
    }
  }

  Future<void> _startPlaying() async {
    setState(() {
      _isPlaying = true;
    });

    await _audioPlayer.startPlayer(
      fromURI: _filePath,
      codec: Codec.pcm16WAV,
      whenFinished: () {
        setState(() {
          _isPlaying = false;
        });
      },
    );
  }

  Future<void> _stopPlaying() async {
    setState(() {
      _isPlaying = false;
    });

    await _audioPlayer.stopPlayer();
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Audio Recording'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isPlaying ? _stopPlaying : _startPlaying,
              child: Text(_isPlaying ? 'Stop Playing' : 'Start Playing'),
            ),
            IconButton(
              icon:
                  const Icon(Icons.cloud_upload, color: Colors.green, size: 50),
              onPressed: () => sendAudio(_filePath),
              // uploadAndDeleteRecording,
            ),
            SelectableText(text,
                style: TextStyle(
                    fontSize: 18,
                    color: _isRecording ? Colors.black87 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
