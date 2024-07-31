import 'dart:convert';
import 'dart:io';
import 'dart:io';
import 'dart:math';
import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:swipe_to/swipe_to.dart';
import 'package:widget_zoom/widget_zoom.dart';
import '../../../gen/assets.gen.dart';
import '../../src/api.dart';
import '../../src/constant.dart';
import '../../src/device_utils.dart';
import '../../src/dialog_info.dart';
import '../../src/preference.dart';
import '../../src/toast.dart';
import '../../src/utils.dart';
import '../../widgets/spacer/spacer_custom.dart';
import '../../widgets/received_message.dart';
import '../../widgets/sent_message.dart';
import 'camera_view.dart';

class ChatRoomPage extends StatefulWidget {
  final String id;
  // final String receiverId, receiverName, senderId, receiverImage;
  const ChatRoomPage({
    Key? key,
    required this.id,
    // required this.receiverName,
    // required this.senderId,
    // required this.receiverImage,
  }) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final DateFormat dmy = DateFormat("HH:mm");
  final DateFormat dm = DateFormat("HH:mm");
  final _formKey = GlobalKey<FormState>();
  final _keyword = TextEditingController();
  FocusNode inputNode = FocusNode();
  void openKeyboard() {
    FocusScope.of(context).requestFocus(inputNode);
  }

  File? _image;
  final picker = ImagePicker();
  String userpath = "";
  String photo = "";
  var imageData;
  var filename;
  FilePickerResult? result;
  String replyText = '';
  String messageReply = '';
  late final ValueChanged onSwipedMessage;
  bool recording = false;
  List chatMessages = [];

  String nomer = "", akun = "";

  SharedPref sharedPref = SharedPref();
  String accessToken = "";
  String userId = "";
  String chatId = "";
  // String senderId = "";

  String url = ApiService.chatRoom;
  String message = "";
  bool isProcess = true;
  List listData = [];

  // final TextEditingController _controller = TextEditingController();
  TextEditingController controller = TextEditingController();
  bool emojiShowing = false;

  processData(
    str,
    senderId,
    receiverId,
    // image
  ) async {
    setState(() {
      listData = [];
      isProcess = true;
    });

    try {
      var params = jsonEncode({
        "message_content": str.toString(),
        "sender_user_id": senderId,
        "receiver_user_id": receiverId,
        // "image": image,
      });

      url = ApiService.chatRoom;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": bearerToken.toString()
          },
          body: params);
      var content = json.decode(response.body);
      print(url);
      print(content['status']);

      if (content['status'].toString() == "Success") {
        _keyword.text = '';

        // getData(accessToken, 1, 1
        // widget.receiverId,
        // widget.senderId,
        // );
        // getData(accessToken, chatId);
      } else {
        // ignore: use_build_context_synchronously
        //onBasicAlertPressed(context, content['status'], content['message']);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      //onBasicAlertPressed(context, 400, e.toString());
    }

    setState(() {
      isProcess = false;
    });
  }

  // getData(
  //   accessToken,
  //   receiverId,
  //   senderId,
  // ) async {
  //   try {
  //     url = '${ApiService.chatHistory}/$senderId/$receiverId';

  //     var bearerToken = 'Bearer $accessToken';
  //     var response = await http.get(Uri.parse(url),
  //         headers: {"Authorization": bearerToken.toString()});
  //     var content = json.decode(response.body);
  //     print(url);
  //     print(content['status']);
  //     print(content);

  //     if (content['status'].toString() == "200") {
  //       print("datanya");
  //       for (int i = 0; i < content['data'].length; i++) {
  //         listData.add(content['data'][i]);
  //       }
  //       print(listData);
  //     } else {
  //       // ignore: use_build_context_synchronously
  //       onBasicAlertPressed(context, content['status'], content['message']);
  //     }
  //   } catch (e) {
  //     // ignore: use_build_context_synchronously
  //     onBasicAlertPressed(context, 400, e.toString());
  //   }

  //   setState(() {
  //     isProcess = false;
  //   });
  // }

  checkSession() async {
    var aToken = await sharedPref.getPref("access_token");

    setState(() {
      accessToken = aToken;
      // void openKeyboard() {
      //   FocusScope.of(context).requestFocus(inputNode);
      // }
    });

    // processData(widget.receiverId, widget.senderId, "coba");

    // getData(
    //   accessToken,
    //   "1",
    //   "2",
    // );
  }

  void moveToSecondPage() async {
    Get.to(() => CameraViewPage(
          path: _image,
          sender: "1",
          receiver: "2",
          receiverName: "rina",
          receiverImage: "widget.receiverImage",
        ));
  }

  Future downloadPdf(context, fileUrl, filename) async {
    final output = await getDownloadPath(context);
    final savePath = '$output/$filename';

    download2(context, fileUrl, savePath);
  }

  Future download2(context, fileUrl, savePath) async {
    try {
      Response response = await Dio().get(
        fileUrl,
        onReceiveProgress: showDownloadProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );

      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);

      raf.writeFromSync(response.data);
      await raf.close();

      _onAlertButtonPressed(context, true, "File PDF berhasil di download");
    } catch (e) {
      _onAlertButtonPressed(context, false, e.toString());
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      (received / total * 100).toStringAsFixed(0);
    }
  }

  Future<String?> getDownloadPath(context) async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      _onAlertButtonPressed(context, false, "Folder download tidak ditemukan");
    }

    return directory?.path;
  }

  _onAlertButtonPressed(context, status, message) {
    Alert(
      context: context,
      type: !status ? AlertType.error : AlertType.success,
      title: "",
      desc: message,
      buttons: [
        DialogButton(
          color: clrPrimary,
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

// Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageData = await pickedFile.readAsBytes();

      setState(() {
        _image = File(pickedFile.path);
        moveToSecondPage();
      });

      photo = pickedFile.name;

      userpath = _image as String;

      print(userpath);

      print(photo);
      print(_image);
    }
  }

// Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imageData = await pickedFile.readAsBytes();

      setState(() {
        _image = File(pickedFile.path);
        moveToSecondPage();
        // _image = pickedFile;
      });

      filename = pickedFile.name;
      print(filename);
      print(_image);
    }
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  // Function to pick multiple files
  void pickMultipleFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        moveToSecondPage();

        // Process the selected files
        for (File file in files) {
          print('Selected file: ${file.path}');
          // Add your file processing logic here
          _image = File(file.path);
        }
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  // IO.Socket socket;
  late IO.Socket socket;
  @override
  // void initState() {
  //   // print("senderid");
  //   // print(widget.senderId);
  //   // getDataRoom(widget.receiverId);
  //   initSocket();

  //   super.initState();
  // }

  // StreamSocket streamSocket = StreamSocket();

  initSocket() async {
    String accessToken = await sharedPref.getPref("access_token");
    print(accessToken);
    var bearerToken = 'Bearer $accessToken';

    // Initialize Socket.IO connection with accessToken in extraHeaders
    socket = IO.io(
      'http://paket7.kejaksaan.info:3019',
      IO.OptionBuilder()
          .setTransports(['websocket']).setAuth({'token': bearerToken}).build(),
    );

    socket.connect();
    socket.onConnect((_) {
      print('Connection established');
      // Join room with user ID after connection is established
      String userId = widget.id.toString(); //id yg login
      // String roomcode = dataRoomUserId.toString as String; //id yg dikirm
      // widget.roomId.toString();
      print(userId);
      // print(roomcode);
      socket.emit('Join_Room_Ptt', {'user_id': userId});
      print('Connection established22');
    });
    socket.onDisconnect((_) => print('Connection Disconnection'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));

    print("outputnya000");

    socket.on('sendChatToClient', (message) {
      print("object");
      print("Received Message: $message");
      chatMessages.add(message);

      if (message != null) {
        print("Received Message: $message");
        // Panggil fungsi untuk menampilkan pesan
        displayMessage(message);
        // chatMessagesString = message.toString();
      } else {
        print("Pesan yang diterima kosong.");
      }

      // print("Received Message: $message");
      // chatMessagesString = message.toString();

      //   print("chatmessagstring");

      //   print(chatMessagesString);

      // Memperbarui state widget dengan menambahkan pesan baru ke dalam chatMessages
      // setState(() {
      //   chatMessagesString = message.toString();

      //   print("chatmessagstring");

      //   print(chatMessagesString);
      //   isDataReceived =
      //       true; // Set variabel state isDataReceived menjadi true karena data diterima
      // });

      // Panggil fungsi untuk menampilkan pesan
      // displayMessage(message);
    });

    // Listen for acknowledgment from the server after sending the message
    socket.on('messageAcknowledgment', (ack) {
      if (ack == 'success') {
        print('Pesan berhasil dikirim ke server.');
      } else {
        print('Gagal mengirim pesan ke server.');
      }
    });
  }

  bool isDataReceived = false;

  void sendMessage(message) {
    message = controller.text.trim();
    if (message.isEmpty) return;
    Map messageMap = {
      'message_content': message.toString(),
      // 'sender_user_id': widget.senderId.toString(), //yg login
      // 'receiver_user_id': widget.receiverId.toString(), //yg dikirim
      'attachment': null,
      // 'roomcode': dataRoomId.toString(),
      // widget.roomId.toString(),
    };

    print("ini validasi data seblm kirim pesan");

    print(message);
    // print(widget.senderId);
    // print(widget.receiverId);
    print(photo);
    // print(dataRoomId.toString());

    try {
      socket.emit('sendChatToServer', messageMap);
      print("ini isian apakah data udh kekirim");
      print(messageMap);
    } catch (e) {
      print("data tidak kekirim");
      toastShort(context, e.toString());
    }

    // socket.on('sendChatToClient', (message) {
    //   print("Received Message: $message");
    //   displayMessage (message);
    //   chatMessages.add(message) ;
    //    print(chatMessages);
    //   // _streamController.add(message.toString());
    //   setState(() {
    //     chatMessages.add(message) ;
    //     // var content = json.decode(response.body);
    //     print("chatmessage setlh receid from server");
    //     print(chatMessages);
    //   });
    //   print("ini streamcontroller");
    //   // print(_streamController.toString());
    // });

    // socket.on('sendChatToClient', (message) {
    //   print("Received Message: $message");
    //   chatMessages.add(message);
    //   isDataReceived =
    //       true; // Set isDataReceived menjadi true ketika data diterima
    //   print(chatMessages);
    //   print("ini streamcontroller");
    // });

    print("sblmchat");

    print("stlhchat");
  }

  void displayMessage(message) {
    print("Received Message: $message");
  }

  @override
  void initState() {
    checkSession();
    initSocket();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.white,
        title: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Center(
              child: Text(
                'Channel 3',
                style: SafeGoogleFont(
                  'SF Pro Text',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.2575,
                  letterSpacing: 1,
                  color: Colors.black87,
                ),
              ),
            )),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: DeviceUtils.getScaledHeight(context, 1),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: clrBackgroundLight,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ChatRoomHeader(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  height: DeviceUtils.getScaledHeight(context, 0.87),
                  width: DeviceUtils.getScaledWidth(context, 1),
                  child: Stack(
                    children: <Widget>[
                      ListView(
                        children: [
                          const CustomHeightSpacer(
                            size: 0.03,
                          ),
                          SentMessage(
                            time: "01:15 PM",
                            onLongPress: null,
                            child: Text(
                              "What's your favorite type of movie?",
                              style: SafeGoogleFont(
                                'SF Pro Text',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.6428571429,
                                letterSpacing: 0.5,
                                color: const Color(0xffffffff),
                              ),
                            ),
                          ),
                          ReceivedMessage(
                            time: "01:15 PM",
                            child: Text(
                              "I don't have personal preferences like humans do, but I can appreciate all sorts of movies! From thought-provoking dramas to action-packed adventures, each genre offers something unique and interesting. If I had to choose, I'd say I'm particularly intrigued by movies with complex storylines and well-developed characters. What about you? What's your favorite type of movie?",
                              style: SafeGoogleFont(
                                'SF Pro Text',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.6428571429,
                                letterSpacing: 0.5,
                                color: const Color(0xff323643),
                              ),
                            ),
                          ),
                          SentMessage(
                            time: "01:15 PM", onLongPress: null,
                            child: Text(
                              "What's your favorite childhood memory?",
                              style: SafeGoogleFont(
                                'SF Pro Text',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.6428571429,
                                letterSpacing: 0.5,
                                color: const Color(0xffffffff),
                              ),
                            ),
                            // Row(
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   children: [
                            //     //
                            //     DummyWaveWithPlayIcon(),
                            //     //       ),
                            //   ],
                            // ),
                          ),
                          ReceivedMessage(
                            time: "01:15 PM",
                            child: Text(
                              "I don't have personal experiences or memories since I'm not a person, but I'm always here to hear about yours! What's one of your favorite memories from when you were younger?",
                              style: SafeGoogleFont(
                                'SF Pro Text',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.64,
                                letterSpacing: 0.5,
                                color: const Color(0xff323643),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 10, bottom: 10, top: 10),
                          height: 70,
                          // width: double.infinity,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  Assets.icons.icCameraIcon.path,
                                  width: 18,
                                  height: 18,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  width:
                                      DeviceUtils.getScaledWidth(context, 0.75),
                                  decoration: const BoxDecoration(
                                    color: clrBackgroundLight,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Type a Message',
                                          style: SafeGoogleFont(
                                            'SF Pro Text',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            height: 1.2575,
                                            letterSpacing: 0.174999997,
                                            color: const Color(0xffc1c0c8),
                                          ),
                                        ),

                                        // Expanded(
                                        //   child: TextField(
                                        //       style: SafeGoogleFont(
                                        //         'SF Pro Text',
                                        //         fontSize: 14,
                                        //         fontWeight: FontWeight.w400,
                                        //         height: 1.2575,
                                        //         letterSpacing: 0.174999997,
                                        //         color: Color(0xffc1c0c8),
                                        //       ),
                                        //     decoration: InputDecoration(
                                        //         hintText: 'Enter Your Name',
                                        //       border: InputBorder.none,
                                        //
                                        //     )
                                        //
                                        //     ),
                                        // )

                                        Image.asset(
                                          Assets.icons.icMic.path,
                                          width: 18,
                                          height: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Image.asset(
                                  Assets.icons.sendIcon.path,
                                  width: 18,
                                  height: 18,
                                  color: clrPrimary,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: SingleChildScrollView(
  //       child: Column(
  //         children: [
  //           // Align(
  //           //   alignment: Alignment.topCenter,
  //           //   child: ChatRoomHeader(
  //           //       no: "1", user:"rani"),
  //           // ),
  //           Container(
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             height: MediaQuery.of(context).size.height * 0.80,
  //             width: MediaQuery.of(context).size.width,
  //             child: SingleChildScrollView(
  //               child:
  //                   // !isProcess ?
  //                   listingData("1"),

  //               // : loaderDialog(context),
  //             ),
  //           ),
  //           Align(
  //             alignment: Alignment.bottomCenter,
  //             child: Row(
  //               children: [
  //                 Expanded(
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: kDefaultPadding * 0.68),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(40),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         GestureDetector(
  //                           onTap: () {
  //                             setState(() {
  //                               emojiShowing = !emojiShowing;
  //                             });
  //                           },
  //                           child: Icon(
  //                             Icons.emoji_emotions,
  //                             color: Theme.of(context)
  //                                 .textTheme
  //                                 .bodyText1
  //                                 ?.color
  //                                 ?.withOpacity(0.30),
  //                           ),
  //                         ),
  //                         Expanded(
  //                           child: Padding(
  //                             padding: const EdgeInsets.all(5),
  //                             child: Form(
  //                               key: _formKey,
  //                               child: TextFormField(
  //                                 focusNode: inputNode,
  //                                 style: const TextStyle(color: Colors.black),
  //                                 cursorColor: Colors.white54,
  //                                 controller: _keyword,
  //                                 keyboardType: TextInputType.text,
  //                                 autofocus: false,
  //                                 onFieldSubmitted: (value) {
  //                                   processData(value, "1",
  //                                       "2");
  //                                 },
  //                                 decoration: InputDecoration(
  //                                   suffixIconColor: Colors.white54,
  //                                   filled: true,
  //                                   fillColor: Colors.white,
  //                                   hintText: 'Isi pesan ...',
  //                                   hintStyle:
  //                                       const TextStyle(color: Colors.black26),
  //                                   border: OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(25.0),
  //                                     borderSide: BorderSide.none,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         GestureDetector(
  //                           onTap: () async {
  //                             pickMultipleFiles();
  //                           },
  //                           child: Icon(
  //                             Icons.attach_file,
  //                             color: Theme.of(context)
  //                                 .textTheme
  //                                 .bodyText1
  //                                 ?.color
  //                                 ?.withOpacity(0.40),
  //                           ),
  //                         ),
  //                         const SizedBox(width: kDefaultPadding / 4),
  //                         GestureDetector(
  //                           onTap: () {
  //                             showOptions();
  //                           },
  //                           child: Icon(
  //                             Icons.camera_alt_outlined,
  //                             color: Theme.of(context)
  //                                 .textTheme
  //                                 .bodyText1
  //                                 ?.color
  //                                 ?.withOpacity(0.40),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(width: kDefaultPadding / 35),
  //                 Padding(
  //                   padding: const EdgeInsets.all(1.5),
  //                   child: Container(
  //                     padding: const EdgeInsets.all(15),
  //                     decoration: BoxDecoration(
  //                       color: clrPrimary,
  //                       shape: BoxShape.circle,
  //                     ),
  //                     child: const Icon(Icons.mic, color: Colors.white),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget listingData(String senderId) {
    final widgetKey = GlobalKey();
    if (listData.isNotEmpty) {
      return ListView.separated(
        padding:
            const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, index) {
          var row = listData[index];
          var userChat = row['sender_user_id'].toString();
          var image = row['attachment'].toString();
          var fileUrl = "";
          String filename = "";
          // List of allowed file extensions
          List<String> allowedExtensions = [
            '.doc',
            '.docx',
            '.pdf',
            '.xlsx',
            '.json',
            '.xls', // Microsoft Excel Spreadsheet
            '.ppt', // Microsoft PowerPoint Presentation
            '.pptx', // Microsoft PowerPoint Open XML Presentation
            '.txt', // Plain Text
            '.csv', // Comma-Separated Values
            '.html', // Hypertext Markup Language
            '.xml', // eXtensible Markup Language
            '.zip', // ZIP Archive
            '.rar', // RAR Archive
            '.7z', // 7-Zip Archive
            '.tar', // Tape Archive
            '.gz', // Gzip Compressed File
            '.bz2', // Bzip2 Compressed File
            '.mp3', // MPEG Audio Layer 3
            '.wav', // Waveform Audio File
            '.mp4', // MPEG-4 Video File
            '.avi', // Audio Video Interleave
            '.mkv', // Matroska Video File
            '.jpg', // Joint Photographic Experts Group Image
            '.jpeg', // Joint Photographic Experts Group Image
            '.png', // Portable Network Graphics
            '.gif', // Graphics Interchange Format
            '.bmp', // Bitmap Image File
            '.tif', // Tagged Image File Format
            '.tiff', // Tagged Image File Format
            '.svg', // Scalable Vector Graphics
            '.eps', // Encapsulated PostScript File
            '.psd', // Adobe Photoshop Document
            '.ai', // Adobe Illustrator Artwork
            '.indd', // Adobe InDesign Document
            '.odt', // OpenDocument Text Document
            '.ott', // OpenDocument Text Template
            '.odp', // OpenDocument Presentation
            '.otp', // OpenDocument Presentation Template
            '.ods', // OpenDocument Spreadsheet
            '.ots', // OpenDocument Spreadsheet Template
            '.odg', // OpenDocument Graphics
            '.otg', // OpenDocument Graphics Template
            '.dart',
          ];

          if (image.isNotEmpty) {
            fileUrl = '${ApiService.folder}/$image';
            print(fileUrl);
            // Split string `image` berdasarkan "/"
            final nameList = image.split("/");

            // Ambil bagian terakhir dari list sebagai nama file
            String lastPart = nameList.isNotEmpty ? nameList.last : "-/-";

            // Split nama file berdasarkan karakter "_"
            List<String> parts = lastPart.split("_");

            // Hapus tanggal dari nama file dan gabungkan kembali
            filename = parts.skip(1).join("_");
          }

          var message = row['message_content'].toString();
          messageReply = row['id'].toString();

          print("strinanme");

          print(filename);

          var local = dmy.format(DateTime.parse(row['sent_at']).toLocal());
          // var localDate = dmy.format(DateTime.parse(row['sent_at']).toLocal());
          var datetime = local.toString();

          if (senderId == userChat) {
            if (message != "") {
              if (image != "null") {
                if (allowedExtensions.any((ext) => filename.endsWith(ext))) {
                  if (replyText == messageReply) {
                    return Container(
                      margin:
                          const EdgeInsets.only(right: 20, top: 5, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 66, top: 5),
                                child: Text(
                                  "You replied to ${messageReply}",
                                  style: const TextStyle(
                                    color: clrPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 0),
                                width: 50,
                                // height: screenheight * 0.06,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(18),
                                      bottomLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                      topLeft: Radius.circular(18),
                                    ),
                                    color: clrBackground),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    message,
                                    style: const TextStyle(
                                      color: clrPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Container(
                                  width: 1,
                                  height: 50,
                                  color: const Color(0xff918F8F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 17),
                                width: 50,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(18),
                                      bottomLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                      topLeft: Radius.circular(18),
                                    ),
                                    color: Colors.black),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    message,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Text(
                                  "04:35 PM",
                                  style: TextStyle(
                                    color: clrPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  return SentMessage(
                    onLongPress: () {
                      showMenu(
                        items: <PopupMenuEntry>[
                          const PopupMenuItem(
                            //value: this._index,
                            child: Row(
                              children: [Text("Context item 1")],
                            ),
                          )
                        ],
                        context: context,
                        position: _getRelativeRect(widgetKey),
                      );
                    },
                    time: datetime,
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: clrBackgroundLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 10.0),
                            child: Text(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              filename,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            downloadPdf(context, row['attachment'], filename);
                          },
                        ),
                        Text(
                          row['message_content'] ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.64,
                            letterSpacing: 0.5,
                            color: Color(0xffffffff),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SentMessage(
                  onLongPress: () {
                    showMenu(
                      items: <PopupMenuEntry>[
                        const PopupMenuItem(
                          //value: this._index,
                          child: Row(
                            children: [Text("Context item 1")],
                          ),
                        )
                      ],
                      context: context,
                      position: _getRelativeRect(widgetKey),
                    );
                  },
                  time: datetime,
                  child: Column(
                    children: [
                      WidgetZoom(
                        heroAnimationTag: 'tag',
                        zoomWidget: Image.network(
                          // ignore: prefer_interpolation_to_compose_strings
                          '${ApiService.folder}/' + row['attachment'],
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              // Image is fully loaded
                              return child;
                            } else {
                              // Display a loading indicator while the image is loading
                              return Center(
                                child: CircularProgressIndicator(
                                  color: clrPrimary,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                ),
                              );
                            }
                          },
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            // Display an error icon if the image fails to load
                            return const Icon(
                              Icons.error,
                              color: clrPrimary,
                            );
                          },
                        ),
                      ),
                      Text(
                        row['message_content'] ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.64,
                          letterSpacing: 0.5,
                          color: Color(0xffffffff),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return SentMessage(
                  onLongPress: () {
                    showMenu(
                      items: <PopupMenuEntry>[
                        const PopupMenuItem(
                          //value: this._index,
                          child: Row(
                            children: [Text("Context item 1")],
                          ),
                        )
                      ],
                      context: context,
                      position: _getRelativeRect(widgetKey),
                    );
                  },
                  time: datetime,
                  child: Text(
                    row['message_content'] ?? "",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.64,
                      letterSpacing: 0.5,
                      color: Color(0xffffffff),
                    ),
                  ),
                );
              }
            }
            return SentMessage(
              onLongPress: () {
                showMenu(
                  items: <PopupMenuEntry>[
                    const PopupMenuItem(
                      //value: this._index,
                      child: Row(
                        children: [Text("Context item 1")],
                      ),
                    )
                  ],
                  context: context,
                  position: _getRelativeRect(widgetKey),
                );
              },
              time: datetime,
              child: Text(
                row['message_content'] ?? "",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.64,
                  letterSpacing: 0.5,
                  color: Color(0xffffffff),
                ),
              ),
            );
          } else {
            if (image != "null") {
              if (allowedExtensions.any((ext) => filename.endsWith(ext))) {
                return SwipeTo(
                  // child: Dismissible(
                  //   confirmDismiss: (a) async {
                  //     replyText = messageReply;
                  //     await Future.delayed(Duration(seconds: 1));
                  //     openKeyboard();
                  //     return false;
                  //   },
                  //   key: UniqueKey(),
                  child: ReceivedMessage(
                    time: datetime,
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 10.0),
                            child: Text(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              filename,
                              style: const TextStyle(
                                color: Colors.black38,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            downloadPdf(context, fileUrl, filename);
                          },
                        ),
                        Text(
                          row['message_content'] ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.64,
                            letterSpacing: 0.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ),
                  onRightSwipe: (details) {
                    openKeyboard();
                    print('Callback from Swipe To Left');
                  },
                );
              }
              return SwipeTo(
                  // child: Dismissible(
                  //   confirmDismiss: (a) async {
                  //     replyText = message;
                  //     await Future.delayed(Duration(seconds: 1));
                  //     openKeyboard();
                  //     return false;
                  //   },
                  //   key: UniqueKey(),
                  child: ReceivedMessage(
                    time: datetime,
                    child: Column(
                      children: [
                        WidgetZoom(
                          heroAnimationTag: 'tag',
                          zoomWidget: Image.network(
                            // ignore: prefer_interpolation_to_compose_strings
                            '${ApiService.folder}/' + row['attachment'],
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                // Image is fully loaded
                                return child;
                              } else {
                                // Display a loading indicator while the image is loading
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: clrPrimary,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              }
                            },
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              // Display an error icon if the image fails to load
                              return const Icon(
                                Icons.error,
                                color: clrPrimary,
                              );
                            },
                          ),
                        ),
                        Text(
                          row['message_content'] ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.64,
                            letterSpacing: 0.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ),
                  onRightSwipe: (details) => onSwipedMessage(message)
                  // openKeyboard(),
                  // print('Callback from Swipe To Left');

                  );
            }
            return SwipeTo(
              child:
                  // Dismissible(
                  //   confirmDismiss: (a) async {
                  //     // replyText = message;
                  //     await Future.delayed(Duration(seconds: 1));
                  //     openKeyboard();
                  //     return false;
                  //   },
                  //   key: UniqueKey(),
                  //   child:
                  ReceivedMessage(
                time: datetime,
                child: Text(
                  row['message_content'] ?? "",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.64,
                    letterSpacing: 0.5,
                    color: Colors.black87,
                  ),
                ),
              ),
              // ),
              onRightSwipe: (details) {
                openKeyboard();
                print('Callback from Swipe To Left');
              },
            );
          }
        },
        separatorBuilder: (_, index) => const SizedBox(
          height: 5,
        ),
        itemCount: listData.isEmpty ? 0 : listData.length,
      );
    } else {
      return Center(
        child: Column(
          children: [
            const SizedBox(
              height: 200,
            ),
            Container(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: const Text("No data found"),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      );
    }
  }

  RelativeRect _getRelativeRect(GlobalKey key) {
    return RelativeRect.fromSize(
        _getWidgetGlobalRect(key), const Size(200, 200));
  }

  Rect _getWidgetGlobalRect(GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);
    debugPrint('Widget position: ${offset.dx} ${offset.dy}');
    return Rect.fromLTWH(offset.dx / 3.1, offset.dy * 1.05,
        renderBox.size.width, renderBox.size.height);
  }
}

class DummyWaveWithPlayIcon extends StatelessWidget {
  const DummyWaveWithPlayIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          // rectanglesHz (0:577)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleoSY (0:592)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglejqz (0:578)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangle5ex (0:581)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleRD2 (0:585)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        //     ],
        //   ),
        // ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglexye (0:590)
          width: 3,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const SizedBox(
          width: 2,
        ),

        Container(
          // rectangleSP2 (0:587)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleyNx (0:582)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleJg8 (0:579)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleEpg (0:593)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglez3A (0:586)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangle8QG (0:589)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleHHA (0:584)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangle2Ve (0:598)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglenUp (0:591)
          width: 3,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleGPz (0:588)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleoep (0:583)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangle9Tn (0:580)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleHZz (0:594)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleRw6 (0:595)
          width: 3,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglea3J (0:596)
          width: 3,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleifJ (0:597)
          width: 3,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const CustomWidthSpacer(
          size: 0.05,
        ),

        Text(
          '01:3',
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.2575,
            letterSpacing: 1,
            color: const Color(0xffffffff),
          ),
        ),

        const CustomWidthSpacer(
          size: 0.05,
        ),

        Image.asset(
          Assets.images.playIcon.path,
          width: 28,
          height: 28,
        )
      ],
    );
  }
}

class DateDevider extends StatelessWidget {
  const DateDevider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: 100, // OK
        height: 41, // OK
        decoration: const BoxDecoration(
          color: Color(0xffF2F3F6),
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: Center(
            child: Text(
          'Today',
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.193359375,
            letterSpacing: 1,
            color: const Color(0xff77838f),
          ),
        )),
      ),
    );
  }
}

class ChatRoomHeader extends StatelessWidget {
  final String no, user;
  const ChatRoomHeader({Key? key, required this.no, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, left: 15, top: 25, bottom: 5),
      // const EdgeInsets.fromLTRB(16, 48, 16, 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Image.asset(
              Assets.icons.leftIcon.path,
              width: 16,
              height: 16,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage('${ApiService.folder}/image-user/$no'),
                  fit: BoxFit.fill),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Text(
            user,
            textAlign: TextAlign.center,
            style: SafeGoogleFont(
              'SF Pro Text',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.2575,
              letterSpacing: 1,
              color: const Color(0xff3b566e),
            ),
          ),
        ],
      ),
    );
  }
}
