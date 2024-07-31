import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:widget_zoom/widget_zoom.dart';
import '../../../src/api.dart';
import '../../../src/constant.dart';
import '../../../src/preference.dart';
import '../../../src/toast.dart';

class MessageViewPage extends StatefulWidget {
  final File? path;
  final String longi, lati;
  const MessageViewPage({
    super.key,
    required this.path,
    required this.longi,
    required this.lati,
  });

  @override
  State<MessageViewPage> createState() => _MessageViewPageState();
}

class _MessageViewPageState extends State<MessageViewPage> {
  SharedPref sharedPref = SharedPref();
  String accessToken = "";
  String message = "";
  bool isProcess = false;
  final _formKey = GlobalKey<FormState>();
  final _keyword = TextEditingController();
  String pathName = "";
  var isi = "";

  processData(senderId, receiverId, image) async {
    final photo = widget.path;

    print(photo);

    var url = ApiService.sosCreate;
    var response = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );
    var accessToken = await sharedPref.getPref("access_token");
    var bearerToken = 'Bearer $accessToken';
    Map<String, String> headers = {
      "Authorization": bearerToken.toString(),
      // "Content-type": "multipart/form-data" // Not required since it's automatically added by http.MultipartRequest
    };

      response.headers.addAll(headers);
      response.fields.addAll({
        "latitude": "-6.2733006230992485",
        "longitude": "106.79730946615685",
      });

      final httpImage = http.MultipartFile.fromBytes(
        'attachment',
        File(photo!.path).readAsBytesSync(),
        filename: photo.path,
      );
      response.files.add(httpImage);

    // if (photo != null) {
    //   response.headers.addAll(headers);
    //   response.fields.addAll({
    //     "latitude": "-6.2733006230992485",
    //     "longitude": "106.79730946615685",
    //   });

    //   final httpImage = http.MultipartFile.fromBytes(
    //     'attachment',
    //     File(photo.path).readAsBytesSync(),
    //     filename: photo.path,
    //   );
    //   response.files.add(httpImage);
    //   // Use the URL directly
    // } else {
    //   response.headers.addAll(headers);
    //   response.fields.addAll({
    //     "latitude": "-6.2733006230992485",
    //     "longitude": "106.79730946615685",
    //   });
    // }

    var request = await response.send();
    var responsed = await http.Response.fromStream(request);
    var content = json.decode(responsed.body);

    print(request);
    print(responsed);
    print(content);

    if (content['status_code'] == 200) {
      setState(() {
        // ignore: use_build_context_synchronously
        toastShort(context, "SOS Berhasil Dikirim");
        isProcess = false;
        moveToSecondPage();
      });

      // finishSos(id);
    } else {
      // ignore: use_build_context_synchronously
      toastShort(context, "SOS Berhasil Dikirim");
    }

    setState(() {
      isProcess = false;
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    setState(() {});

    super.initState();
  }

  void moveToSecondPage() async {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => SosListPage()
    //   ),
    // );
  }

  _onAlertButtonPressed(context, status, message) {
    Alert(
      context: context,
      type: !status ? AlertType.error : AlertType.success,
      title: "",
      desc: message,
      buttons: [
        DialogButton(
          color: clrDone,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.white,
        shadowColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(
                Icons.crop_rotate,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: const Icon(
                Icons.emoji_emotions_outlined,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: const Icon(
                Icons.title,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: const Icon(
                Icons.edit,
                size: 27,
              ),
              onPressed: () {}),
        ],
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 150,
                child: widget.path != null &&
                        (pathName.endsWith('.docx') ||
                            pathName.endsWith('.doc') ||
                            pathName.endsWith('.pdf'))
                    ? WidgetZoom(
                        heroAnimationTag: 'tag',
                        zoomWidget: Image.network(
                          widget.path.toString(),
                          width: 200,
                          height: 150,
                        ),
                      )
                    : ColoredBox(
                        color: Colors.grey.shade600,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(50),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // Added this line
                              children: [
                                const Icon(
                                  Icons.file_open,
                                  color: Colors.black38,
                                  size: 50,
                                ),
                                // Spacer(
                                //   flex: 3,
                                // ),
                                Text(
                                  pathName,
                                  style: const TextStyle(
                                    color: Colors.black38,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign:
                                      TextAlign.center, // Added this line
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black38,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _keyword,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    maxLines: 6,
                    minLines: 1,
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    onFieldSubmitted: (value) {
                      setState(() {
                        isi = value;
                      });
                      // processData(
                      //     value, widget.sender, widget.receiver, widget.path);
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "IsiPesan....",
                      prefixIcon: const Icon(
                        Icons.add_photo_alternate,
                        color: Colors.white,
                        size: 27,
                      ),
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          processData("-6.2733006230992485",
                              "106.79730946615685", widget.path);
                        },
                        child: const CircleAvatar(
                          radius: 27,
                          backgroundColor: clrPrimary,
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
