import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'gen/assets.gen.dart';
import 'src/api.dart';
import 'src/constant.dart';
import 'src/preference.dart';
import 'src/toast.dart';
import 'package:googleapis/speech/v1.dart' as stt;

import 'src/utils.dart';

class RecordingScreen extends StatefulWidget {
  final String userId, channelId;
  final dataUser;
  const RecordingScreen({
    super.key,
    required this.userId,
    required this.channelId,
    required this.dataUser,
  });

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  // late Record audioRecord;
  // late AudioPlayer audioPlayer;
  SharedPref sharedPref = SharedPref();

  late Record audioRecord;
  late AudioPlayer audioPlayer;
  SpeechToText speechToText = SpeechToText();
  var text = "Hold the button and start speaking";
  late IO.Socket socket;
  String audioUrl = '';

  bool isRecording = false;
  bool isPlaying = false;
  bool isRecordingMode = true;
  String audioPath = "";
  List AudioList = [];
  List listData = [];
  String message = "";
  bool isProcess = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioRecord = Record();
    initSocket();
    checkMicrophoneAvailability();
    getData();
  }

  @override
  void dispose() {
    audioRecord.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  getData() async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.listChannel;
      var uri = url;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});

      if (response.statusCode == 200) {
        setState(() {
          print("isian listchannel");
          var content = json.decode(response.body);
          print(content);
          print("datanya");
          listData = content['data'];
          print(listData);
        });
      } else {
        toastShort(context, message);
      }
    } catch (e) {
      toastShort(context, e.toString());
    }

    setState(() {
      isProcess = true;
    });
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
          print("available nih");
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
                  print("text dari voice");
                  print(text);
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
          print("audiopath");
          print(audioPath);
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

  initSocket() async {
    // Fetch the access token
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
      String channelId = widget.channelId.toString();
      print("User ID: $userId");
      socket.emit('Join_Room_Ptt', {
        'user_id': userId,
        'channel_id': channelId,
      });
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

      // setState(() {
      //   String content = audioReceived['ptt']['content'];
      //   print("iniisikonten");
      //   print(content);
      //   audioUrl = 'http://paket7.kejaksaan.info:3019/$content';
      //   print("inisudiodriserver");
      //   print(audioUrl);
      // });
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
        'channel_id': widget.channelId,
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

  // var text = "Press the button to transcribe audio from the server";
  bool isTranscribing = false;
  static const _scopes = [stt.SpeechApi.cloudPlatformScope];

  Future<File> downloadAudioFile(String url, String filename) async {
    print("responsesblm");
    final response = await http.get(Uri.parse(url));
    print("responsedonlot");
    print(response);
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/$filename');
    print("filekedonlod");
    print(file);
    return file.writeAsBytes(response.bodyBytes);
  }

  Future<String> convertAudioToText(File audioFile) async {
    final _credentials = ServiceAccountCredentials.fromJson({
      // Your Google Cloud credentials JSON
    });

    final client = await clientViaServiceAccount(_credentials, _scopes);
    final speechApi = stt.SpeechApi(client);

    final bytes = await audioFile.readAsBytes();
    final base64Audio = base64Encode(bytes);

    final request = stt.RecognizeRequest(
      audio: stt.RecognitionAudio(content: base64Audio),
      config: stt.RecognitionConfig(
        encoding: 'LINEAR16',
        sampleRateHertz: 16000,
        languageCode: 'en-US',
      ),
    );

    final response = await speechApi.speech.recognize(request);

    if (response.results != null && response.results!.isNotEmpty) {
      return response.results!.first.alternatives!.first.transcript!;
    } else {
      return 'No text recognized';
    }
  }

  // Future<void> transcribeAudio() async {
  //   // if (audioUrl.isEmpty) {
  //   //   setState(() {
  //   //     text = 'No audio URL received.';
  //   //   });
  //   //   return;
  //   // }

  //   setState(() {
  //     isTranscribing = true;
  //   });

  //   try {
  //     final audioFile = await downloadAudioFile(
  //       audioUrl,
  //       'received_audio.wav',
  //     );
  //     print("sblmresult");
  //     final result = await convertAudioToText(audioFile);
  //     print("hasilsuara");
  //     print(result);
  //     setState(() {
  //       text = result;
  //       print("inittextsuara");
  //       print(text);
  //     });
  //   } catch (e) {
  //     setState(() {
  //       text = 'Error: ${e.toString()}';
  //     });
  //   } finally {
  //     setState(() {
  //       isTranscribing = false;
  //     });
  //   }
  // }

  // Future<void> transcribeAudio() async {
  //   setState(() {
  //     isTranscribing = true;
  //   });

  //   try {
  //     final audioFile = await downloadAudioFile(
  //       'http://paket7.kejaksaan.info:3019/voice-ptt/2024-07-23 03:26:52_audio.wav',
  //       '2024-07-23_audio.wav',
  //     );
  //     final result = await convertAudioToText(audioFile);
  //     setState(() {
  //       text = result;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       text = 'Error: ${e.toString()}';
  //     });
  //   } finally {
  //     setState(() {
  //       isTranscribing = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel 2'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.separated(
              padding: const EdgeInsets.only(
                  bottom: 5, top: 5, left: 5.0, right: 5.0),
              primary: true,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (_, index) {
                var row = widget.dataUser[index];

                print("listdatauser");
                print(row);

                return GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => ActivityDetail(
                    //       activityUser: row['username'] ?? "",
                    //       activityIp: row['ip_address'] ?? "",
                    //       activityBrowser: row['browser'] ?? "",
                    //       activityPlatform: row['platform'] ?? "",
                    //       activityDescription: row['activity'] ?? "",
                    //       activityCreated: row['created_at'] ?? "",
                    //       activityUpdated: row['updated_at'] ?? "",
                    //     ),
                    //   ),
                    // );
                  },
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 20,
                                  color: Colors.grey.shade200,
                                  spreadRadius: 2)
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 5, bottom: 8),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: const SizedBox(
                                    height: 20,
                                    width: 80,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.more_vert),
                                      ],
                                    ),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 5),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black45),
                                          color: Colors.black26,
                                          shape: BoxShape.circle),
                                      child: const Icon(Icons.mic),
                                    ),
                                  ),
                                ),
                                Text(
                                  row['fullname'] ?? '-',
                                  style: SafeGoogleFont(
                                    'SF Pro Text',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2575,
                                    letterSpacing: 1,
                                    color: clrPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, index) => const SizedBox(
                height: 5,
              ),
              itemCount: widget.dataUser.isEmpty ? 0 : widget.dataUser.length,
            ),

            // GestureDetector(
            //   onTap: () {},
            //   child: Column(
            //     children: [
            //       Container(
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           shape: BoxShape.rectangle,
            //           boxShadow: [
            //             BoxShadow(
            //                 blurRadius: 20,
            //                 color: Colors.grey.shade200,
            //                 spreadRadius: 2)
            //           ],
            //         ),
            //         child: Padding(
            //           padding: const EdgeInsets.all(15),
            //           child: Column(
            //             children: [
            //               CircleAvatar(
            //                 radius: 30.0,
            //                 backgroundColor: Colors.white,
            //                 child: Padding(
            //                   padding: const EdgeInsets.symmetric(
            //                       vertical: 5, horizontal: 5),
            //                   child: Container(
            //                     padding: const EdgeInsets.all(10),
            //                     decoration: BoxDecoration(
            //                         border: Border.all(color: Colors.black45),
            //                         color: Colors.black26,
            //                         shape: BoxShape.circle),
            //                     child: const Icon(Icons.mic),
            //                   ),
            //                 ),
            //               ),
            //               Text(
            //                 'Send Video',
            //                 style: SafeGoogleFont(
            //                   'SF Pro Text',
            //                   fontSize: 12,
            //                   fontWeight: FontWeight.w500,
            //                   height: 1.2575,
            //                   letterSpacing: 1,
            //                   color: clrBackground,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //       const SizedBox(
            //         height: 10,
            //       ),
            //     ],
            //   ),
            // ),
            Center(
              child: isRecordingMode
                  ? Column(
                      children: [
                        // SingleChildScrollView(
                        //   reverse: true,
                        //   physics: const BouncingScrollPhysics(),
                        //   child: Container(
                        //     // height: MediaQuery.of(context).size.height * 0.7,
                        //     width: MediaQuery.of(context).size.width,
                        //     alignment: Alignment.center,
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 24, vertical: 16),
                        //     margin: const EdgeInsets.only(bottom: 150),
                        //     child: SelectableText(
                        //       text,
                        //       style: TextStyle(
                        //           fontSize: 18,
                        //           color: isRecording
                        //               ? Colors.black87
                        //               : Colors.black54),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(
                          height: 85,
                        ),
                        IconButton(
                            icon: Icon(
                              isRecording
                                  ? Icons.fiber_manual_record
                                  : Icons.mic_none,
                              color: clrPrimary,
                              size: 50,
                            ),
                            onPressed:
                                isRecording ? stopRecording : startRecording),
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
                          onPressed: isPlaying
                              ? pauseRecording
                              :
                              // transcribeAudio
                              playRecording,
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
                          // uploadAndDeleteRecording,
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.transcribe,
                        //       color: Colors.blue, size: 50),
                        //   onPressed: transcribeAudio,
                        // ),
                      ],
                    ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(text,
                    style:
                        const TextStyle(fontSize: 18, color: Colors.black87)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
