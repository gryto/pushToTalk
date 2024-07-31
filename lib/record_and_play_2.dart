import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'src/preference.dart';
import 'src/toast.dart';
import 'package:googleapis/speech/v1.dart' as stt;

class RecordingScreenSecond extends StatefulWidget {
  final String userId;
  const RecordingScreenSecond({
    super.key,
    required this.userId,
  });

  @override
  _RecordingScreenSecondState createState() => _RecordingScreenSecondState();
}

class _RecordingScreenSecondState extends State<RecordingScreenSecond> {
  SharedPref sharedPref = SharedPref();
    // var text = "Press the button to transcribe audio from the server";
  bool isTranscribing = false;
  static const _scopes = [stt.SpeechApi.cloudPlatformScope];

  late Record audioRecord;
  late AudioPlayer audioPlayer;
  SpeechToText speechToText = SpeechToText();
  var text = "Hold the button and start speaking";
  late IO.Socket socket;

  bool isRecording = false;
  bool isPlaying = false;
  bool isRecordingMode = true;
  String audioPath = "";
  String audioUrl = '';
  List AudioList = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioRecord = Record();
    initSocket();
    checkMicrophoneAvailability();
  }

  @override
  void dispose() {
    audioRecord.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  void checkMicrophoneAvailability() async {
    bool available = await speechToText.initialize();
    if (available) {
      setState(() {
        if (kDebugMode) {
          print('Microphone available: $available');
        }
      });
    } else {
      if (kDebugMode) {
        print("The user has denied the use of speech recognition.");
      }
    }
  }

  Future<void> startRecording() async {
    try {
      var available = await speechToText.initialize();

      if (await audioRecord.hasPermission() && !isRecording) {
        await audioRecord.start();
        if (available) {
          setState(() {
            isRecording = true;
            if (kDebugMode) {
              print('Microphone available: $available');
            }
          });
          speechToText.listen(
              listenFor: const Duration(days: 1),
              onResult: (result) {
                setState(() {
                  text = result.recognizedWords;
                });
              });
        }
      } else {
        setState(() {
          isRecording = false;
        });
        speechToText.stop();
      }
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      if (path != null) {
        setState(() {
          isRecording = false;
          isRecordingMode = false;
          audioPath = path;
        });
      }
    } catch (e) {
      print("Error stopping recording: $e");
    }
  }

  Future<void> playRecording() async {
    try {
      setState(() {
        isPlaying = true;
      });

      await audioPlayer.play(DeviceFileSource(audioPath));

      audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          isPlaying = false;
        });
      });
    } catch (e) {
      print("Error playing recording: $e");
    }
  }

  Future<void> pauseRecording() async {
    try {
      await audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } catch (e) {
      print("Error pausing recording: $e");
    }
  }

  Future<void> uploadAndDeleteRecording() async {
    try {
      final url = Uri.parse(
          'http://paket7.kejaksaan.info:3019'); // Replace with your server's upload URL
      final file = File(audioPath);

      if (!file.existsSync()) {
        print("File does not exist.");
        return;
      }

      final request = http.MultipartRequest('POST', url)
        ..files.add(
          http.MultipartFile(
            'audio',
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: 'audio.mp3',
          ),
        );

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio uploaded.')),
        );

        setState(() {
          audioPath = "";
          isRecordingMode = true;
        });
      } else {
        print('Failed to upload audio. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading audio: $e');
    }
  }

  Future<void> deleteRecording() async {
    try {
      if (audioPath.isNotEmpty) {
        final file = File(audioPath);
        if (file.existsSync()) {
          file.deleteSync();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recording deleted')),
          );

          setState(() {
            audioPath = "";
            isRecordingMode = true;
          });
        }
      }
    } catch (e) {
      print("Error deleting file: $e");
    }
  }

  void initSocket() async {
    String accessToken = await sharedPref.getPref("access_token");
    var bearerToken = 'Bearer $accessToken';

    socket = IO.io(
      'http://paket7.kejaksaan.info:3019',
      IO.OptionBuilder()
          .setTransports(['websocket']).setAuth({'token': bearerToken}).build(),
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
      print("Chat history received:");
      print(audioReceived);
      AudioList.add((audioReceived));
      print("chatmessagehistory");
      print(AudioList);

      // Assuming audioReceived contains the URL
      if (audioReceived.containsKey('audioUrl')) {
        setState(() {
          audioUrl = audioReceived['audioUrl'];
        });
      }
    });
  }

  Future<void> sendAudio(String audioPath) async {
    final file = File(audioPath);

    if (!file.existsSync()) {
      print("File does not exist.");
      return;
    }

    try {
      List<int> audioBytes = await file.readAsBytes();
      String audioBase64 = base64Encode(audioBytes);

      String userId = widget.userId.toString();
      socket.emit('Send_Audio_Ptt', {
        'audio': audioBase64,
        'user_id': userId,
        'name': 'audio.mp3',
      });

      print('Audio sent');
    } catch (e) {
      print("Error sending audio: $e");
    }
  }

  Future<File> downloadAudioFile(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      return file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download audio file');
    }
  }

  Future<String> convertAudioToText(File audioFile) async {
    const _scopes = [stt.SpeechApi.cloudPlatformScope];
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
      jsonEncode({
        "private_key": "YOUR_PRIVATE_KEY",
        "client_email": "YOUR_CLIENT_EMAIL",
      }),
    );
    final httpClient = await clientViaServiceAccount(serviceAccountCredentials, _scopes);

    final speechApi = stt.SpeechApi(httpClient);
    final request = stt.RecognizeRequest.fromJson({
      'config': {
        'encoding': 'LINEAR16',
        'sampleRateHertz': 16000,
        'languageCode': 'en-US',
      },
      'audio': {
        'content': base64Encode(audioFile.readAsBytesSync()),
      },
    });

    final response = await speechApi.speech.recognize(request);

    return response.results!
        .map((result) => result.alternatives?.first.transcript)
        .join('\n');
  }

  Future<void> transcribeAudio() async {
    if (audioUrl.isEmpty) {
      setState(() {
        text = 'No audio URL received.';
      });
      return;
    }

    setState(() {
      isTranscribing = true;
    });

    try {
      final audioFile = await downloadAudioFile(
        audioUrl,
        'received_audio.wav',
      );
      final result = await convertAudioToText(audioFile);
      setState(() {
        text = result;
      });
    } catch (e) {
      setState(() {
        text = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isTranscribing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel 1'),
      ),
      body: Column(
        children: [
          Center(
            child: isRecordingMode
                ? Column(
                    children: [
                      SingleChildScrollView(
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          margin: const EdgeInsets.only(bottom: 150),
                          child: SelectableText(
                            text,
                            style: TextStyle(
                                fontSize: 18,
                                color: isRecording
                                    ? Colors.black87
                                    : Colors.black54),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isRecording
                              ? Icons.fiber_manual_record
                              : Icons.mic_none,
                          color: Colors.red,
                          size: 50,
                        ),
                        onPressed: isRecording ? stopRecording : startRecording,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause_circle : Icons.play_circle,
                          color: Colors.green,
                          size: 50,
                        ),
                        onPressed: isPlaying ? pauseRecording : playRecording,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 50),
                        onPressed: deleteRecording,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cloud_upload,
                            color: Colors.green, size: 50),
                        onPressed: () => sendAudio(audioPath),
                      ),
                      IconButton(
                        icon: const Icon(Icons.transcribe,
                            color: Colors.blue, size: 50),
                        onPressed: transcribeAudio,
                      ),
                    ],
                  ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(
                text,
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'dart:io';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import 'package:record/record.dart';
// import 'package:http/http.dart' as http;

// class RecordingScreenSecond extends StatefulWidget {
//   const RecordingScreenSecond({super.key});

//   @override
//   _RecordingScreenSecondState createState() => _RecordingScreenSecondState();
// }

// class _RecordingScreenSecondState extends State<RecordingScreenSecond> {
//   // late Record audioRecord;
//   // late AudioPlayer audioPlayer;

//   late Record audioRecord;
//   late AudioPlayer audioPlayer;


//   bool isRecording = false;
//   bool isPlaying = false;
//   bool isRecordingMode = true;
//   String audioPath = "";

//   @override
//   void initState() {
//     super.initState();
//     audioPlayer = AudioPlayer();
//     audioRecord = Record();
//   }

//   @override
//   void dispose() {
//     audioRecord.dispose();
//     audioPlayer.dispose();
//     super.dispose();
//   }

//   Future<void> startRecording() async {
//     try {
//       if (await audioRecord.hasPermission()) {
//         await audioRecord.start();
//         setState(() {
//           isRecording = true;
//         });
//       }
//     } catch (e) {
//       print("Error starting recording: $e");
//     }
//   }

//   Future<void> stopRecording() async {
//     try {
//       String? path = await audioRecord.stop();
//       if (path != null) {
//         setState(() {
//           isRecording = false;
//           isRecordingMode = false;
//           audioPath = path;
//         });
//       }
//     } catch (e) {
//       print("Error stopping recording: $e");
//     }
//   }

//   Future<void> playRecording() async {
//     try {
//       setState(() {
//         isPlaying = true;
//       });

//       await audioPlayer.play(DeviceFileSource(audioPath));

//       audioPlayer.onPlayerComplete.listen((event) {
//         setState(() {
//           isPlaying = false;
//         });
//       });
//     } catch (e) {
//       print("Error playing recording: $e");
//     }
//   }

//   Future<void> pauseRecording() async {
//     try {
//       await audioPlayer.pause();
//       setState(() {
//         isPlaying = false;
//       });
//     } catch (e) {
//       print("Error pausing recording: $e");
//     }
//   }
  

//   Future<void> uploadAndDeleteRecording() async {
//     try {
//       final url = Uri.parse('http://paket7.kejaksaan.info:3019'); // Replace with your server's upload URL
//       final file = File(audioPath);

//       if (!file.existsSync()) {
//         print("File does not exist.");
//         return;
//       }

//       final request = http.MultipartRequest('POST', url)
//         ..files.add(
//           http.MultipartFile(
//             'audio',
//             file.readAsBytes().asStream(),
//             file.lengthSync(),
//             filename: 'audio.mp3',
//           ),
//         );

//       final response = await http.Response.fromStream(await request.send());

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Audio uploaded.')),
//         );

//         setState(() {
//           audioPath = "";
//           isRecordingMode = true;
//         });
//       } else {
//         print('Failed to upload audio. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error uploading audio: $e');
//     }
//   }

//   Future<void> deleteRecording() async {
//     try {
//       if (audioPath.isNotEmpty) {
//         final file = File(audioPath);
//         if (file.existsSync()) {
//           file.deleteSync();
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Recording deleted')),
//           );

//           setState(() {
//             audioPath = "";
//             isRecordingMode = true;
//           });
//         }
//       }
//     } catch (e) {
//       print("Error deleting file: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Voice Recorder'),
//       ),
//       body: Center(
//         child: isRecordingMode
//             ? 
//             IconButton(
//                 icon: Icon(
//                   isRecording ? Icons.fiber_manual_record : Icons.mic_none,
//                   color: Colors.red,
//                   size: 50,
//                 ),
//                 onPressed: isRecording ? stopRecording : startRecording,
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     icon: Icon(
//                       isPlaying ? Icons.pause_circle : Icons.play_circle,
//                       color: Colors.green,
//                       size: 50,
//                     ),
//                     onPressed: isPlaying ? pauseRecording : playRecording,
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.delete, color: Colors.red, size: 50),
//                     onPressed: deleteRecording,
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.cloud_upload, color: Colors.green, size: 50),
//                     onPressed: uploadAndDeleteRecording,
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
