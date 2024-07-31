import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pushtotalk/gen/assets.gen.dart';
import '../../home.dart';
import '../../src/api.dart';
import '../../src/constant.dart';
import '../../src/device_utils.dart';
import '../../src/loader.dart';
import '../../src/preference.dart';
import '../../src/toast.dart';
import '../../src/utils.dart';
import 'package:http/http.dart' as http;
import 'component/message_view.dart';

class SosListPage extends StatefulWidget {
  SosListPage({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SosListPageState createState() => _SosListPageState();
}

class _SosListPageState extends State<SosListPage> {
  RxInt activeIndex = 1.obs;

  SharedPref sharedPref = SharedPref();
  String message = "";
  bool isProcess = true;
  List listData = [];
  List listChat = [];
  List<dynamic> sortedData = [];
  String sosId = "";
  String lastHistoryStatus = "";
  final cntrlNip = TextEditingController();

  String fullname = "";
  int userId = 0;
  var offset = 0;
  var limit = 10;
  String userpath = "";
  bool history = true;
  var idUser = '';
  String userrr = '';

  int pageIndex = 0;

  List pages = [
    // const CallViewWidget(),
  ];

  File? _image;
  final picker = ImagePicker();
  var imageData;
  var filename;
  var splitted;
  File? pathgambar;
  String photo = "";

  @override
  void initState() {
    sortedData.clear;
    historySos();
    history = lastHistoryStatus == 'Finish' ? true : false;

    super.initState();
  }

  // String? _currentAddress;

  // Future<void> _getAddressFromLatLng(Position position) async {
  //   try {
  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //       position.latitude,
  //       position.longitude,
  //     );
  //     Placemark place = placemarks[0];
  //     setState(() {
  //       _currentAddress =
  //           '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
  //     });
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  getData() async {
    try {
      final params = {
        // "latitude": "-6.2733006230992485",
        // "longitude": "106.79730946615685",
        "latitude": '${_currentPosition?.latitude ?? ""}',
        "longitude": '${_currentPosition?.longitude ?? ""}',
        // "attachment": receiverId,
      };
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.sosCreate;
      var uri = Uri.parse(url);
      print(uri);
      var bearerToken = 'Bearer $accessToken';
      var response = await http.post(uri,
          headers: {"Authorization": bearerToken.toString()}, body: params);
      var content = json.decode(response.body);
      print(response);
      print(response.statusCode.toString());
      print(content.toString());

      if (content['status_code'] == 200) {
        setState(() {
          // ignore: use_build_context_synchronously
          toastShort(context, "SOS Berhasil Dikirim");
          // sortedData.clear;
          // historySos();

          // isProcess = true;
        });
      } else {
        // ignore: use_build_context_synchronously
        toastShort(context, "SOS Berhasil Dikirim");
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      toastShort(context, "SOS Belum Berhasil Dikirim");
    }

    setState(() {
      // history = lastHistoryStatus == 'Finish' ? true : false;
      isProcess = false;
    });
  }

  Future<void> getDataFile() async {
    idUser = await sharedPref.getPref("id_usr");
    var url = ApiService.sosCreate;
    var uri = Uri.parse(url);

    var request = http.MultipartRequest('POST', uri);
    var accessToken = await sharedPref.getPref("access_token");
    var bearerToken = 'Bearer $accessToken';

    // Set headers
    request.headers['Authorization'] = bearerToken;
    request.headers['Content-Type'] = 'multipart/form-data';

    // Add fields to the request
    request.fields.addAll({
      "latitude": '${_currentPosition?.latitude ?? ""}',
      "longitude": '${_currentPosition?.longitude ?? ""}',
    });

    // Add image file if available
    if (_image != null) {
      var file = await http.MultipartFile.fromPath(
        'attachment',
        _image!.path,
      );
      request.files.add(file);
    }

    // Send the request
    var response = await request.send();
    print(uri);
    print(response.statusCode.toString());
    // print(content.toString());

    // Handle response
    if (response.statusCode == 200) {
      setState(() {
        toastShort(context, "SOS Berhasil Dikirim");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => MainTabBar(
                      page: 1,
                      id: idUser.toString(),
                    )),
            (Route<dynamic> route) => false);
        // goToHistory();
      });
    } else {
      // Handle error
      toastShort(
          context, "Failed to send SOS. Status code: ${response.statusCode}");
    }

    setState(() {
      isProcess = false;
    });
  }

  // getDataFile() async {
  //   // final photo2 = '${ApiService.folder}/$gambar';

  //   var url = ApiService.sosCreate;
  //   var uri = url;
  //   var response = http.MultipartRequest(
  //     'POST',
  //     Uri.parse(uri),
  //   );
  //   var accessToken = await sharedPref.getPref("access_token");
  //   var bearerToken = 'Bearer $accessToken';
  //   Map<String, String> headers = {
  //     "Authorization": bearerToken.toString(),
  //     // "Content-type": "multipart/form-data" // Not required since it's automatically added by http.MultipartRequest
  //   };

  //   if (_image != null) {
  //     response.headers.addAll(headers);
  //     response.fields.addAll({
  //       "latitude": '${_currentPosition?.latitude ?? ""}',
  //       "longitude": '${_currentPosition?.longitude ?? ""}',
  //     });

  //     final httpImage = http.MultipartFile.fromBytes(
  //       'attachment',
  //       File(_image!.path).readAsBytesSync(),
  //       filename: _image!.path,
  //     );
  //     response.files.add(httpImage);
  //     // Use the URL directly
  //   } else {
  //     response.headers.addAll(headers);
  //     response.fields.addAll({
  //       "latitude": '${_currentPosition?.latitude ?? ""}',
  //       "longitude": '${_currentPosition?.longitude ?? ""}',
  //     });
  //   }

  //   var request = await response.send();
  //   var responsed = await http.Response.fromStream(request);
  //   var content = json.decode(responsed.body);

  //   // print(request);
  //   // print(responsed);
  //   // print(content);

  //   if (content['status_code'] == 200) {
  //     setState(() {
  //       // ignore: use_build_context_synchronously
  //       toastShort(context, "SOS Berhasil Dikirim");
  //       // sortedData.clear;
  //       // historySos();
  //       // isProcess = false;
  //     });

  //     // finishSos(id);
  //   } else {
  //     // ignore: use_build_context_synchronously
  //     toastShort(context, "SOS Belum Berhasil Dikirim");
  //   }

  //   setState(() {
  //     // history = lastHistoryStatus == 'Finish' ? true : false;
  //     isProcess = false;
  //   });
  // }

  historySos() async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.sosHistory;
      var uri = url;
      // print(uri);
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});
      var content = json.decode(response.body);
      // print(response.statusCode.toString());
      // print(content.toString());

      if (content['status'] == '200') {
        setState(() {
          print("object");
          sortedData.clear;
          // sortedData.clear();
          // Urutkan data berdasarkan tanggal pembuatan secara menurun
          sortedData = List.from(content['data']);
          sortedData.sort((a, b) {
            DateTime dateA = DateTime.parse(a['created_at']);
            DateTime dateB = DateTime.parse(b['created_at']);
            return dateB.compareTo(dateA);
          });

          // Ambil sos_id dari entri pertama setelah pengurutan
          sosId = sortedData[0]['sos_id'].toString();
          lastHistoryStatus = sortedData[0]['status'].toString();
          history = lastHistoryStatus == 'Finish' ? true : false;
          print("Latest SOS ID: $sosId");
          // print(lastHistoryStatus);
          isProcess = false;
        });
      } else {
        // ignore: use_build_context_synchronously
        // onBasicAlertPressed(context, 'Error', content['message']);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      // onBasicAlertPressed(context, 'Error', e.toString());
      // toastShort(context, e.toString());
    }

    setState(() {
      history = lastHistoryStatus == 'Finish' ? true : false;
      isProcess = false;
    });
  }

  finishSos(id, note) async {
    try {
      idUser = await sharedPref.getPref("id_usr");
      final params = {
        "latitude": '${_currentPosition?.latitude ?? ""}',
        "longitude": '${_currentPosition?.longitude ?? ""}',
        "note_finish": note,
      };
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.sosFinish;
      var uri = "$url/$id";
      var bearerToken = 'Bearer $accessToken';
      var response = await http.post(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()}, body: params);
      var content = json.decode(response.body);
      // print(content.toString());

      if (content['status_code'] == 200) {
        setState(() {
          // ignore: use_build_context_synchronously
          toastShort(context, "SOS Telah Diselesaikan");
          sortedData.clear;
          historySos();
          userrr = idUser.toString();
          print("iseuserrrr");

          // print(userrr);
          isProcess = false;
        });
      } else {
        // ignore: use_build_context_synchronously
        // toastShort(context, "SOS Telah Diselesaikan");
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      // toastShort(context, "SOS Telah Diselesaikan");
    }

    setState(() {
      history = lastHistoryStatus == 'Finish' ? true : false;
      isProcess = false;
    });
  }

  void moveToSecondPage() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MessageViewPage(
          path: _image,
          longi: '106.79730946615685',
          lati: '-6.2733006230992485',
        ),
      ),
    );
  }

// Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageData = await pickedFile.readAsBytes();

      setState(() {
        _image = File(pickedFile.path);
        print(_image);
        _getCurrentPosition();
        // moveToSecondPage();
      });

      photo = pickedFile.name;

      userpath = _image as String;

      // print(userpath);

      // print(photo);
      // print(_image);
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
        _getCurrentPosition();
        // getDataFile();
        // historySos();
        // moveToSecondPage();
        // _image = pickedFile;
      });

      filename = pickedFile.name;
      // print(filename);
      // print(_image);
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

  Position? _currentPosition;

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      getDataFile();

      // goToHistory();
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  goToHistory() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MainTabBar(
                  page: 1,
                  id: idUser.toString(),
                )),
        (Route<dynamic> route) => false);
  }

  Widget customTextEditingController(
      String hintText, TextEditingController controllerName) {
    return TextFormField(
      controller: controllerName,
      maxLines: 3,
      validator: (value) {
        if (value!.isEmpty) {
          return "Please Enter Username";
        }
        return null;
      },
      style: const TextStyle(color: Colors.black),
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        fillColor: Colors.white,
        focusColor: Colors.white,
        hoverColor: Colors.white,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: DeviceUtils.getScaledHeight(context, 1),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: clrBackgroundLight,
        ),
        child: SingleChildScrollView(
            child:
                // lastHistoryStatus == 'Finish'
                //     ?
                Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10, right: 5, left: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 20,
                          color: Colors.grey.shade200,
                          spreadRadius: 2)
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 20,
                                  color: Colors.grey.shade200,
                                  spreadRadius: 2)
                            ],
                          ),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(Assets.images.user2.path),
                                  fit: BoxFit.fill),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Antok Wijoyo',
                          style: SafeGoogleFont(
                            'SF Pro Text',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.2575,
                            letterSpacing: 1,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 20,
                          color: Colors.grey.shade200,
                          spreadRadius: 2)
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      showOptions();
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 20,
                                  color: Colors.grey.shade200,
                                  spreadRadius: 2)
                            ],
                          ),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(Assets.images.user3.path),
                                  fit: BoxFit.fill),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Anda',
                          style: SafeGoogleFont(
                            'SF Pro Text',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.2575,
                            letterSpacing: 1,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 20,
                          color: Colors.grey.shade200,
                          spreadRadius: 2)
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 20,
                                  color: Colors.grey.shade200,
                                  spreadRadius: 2)
                            ],
                          ),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(Assets.images.user2.path),
                                  fit: BoxFit.fill),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Royyan Jovan',
                          style: SafeGoogleFont(
                            'SF Pro Text',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.2575,
                            letterSpacing: 1,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            // : lastHistoryStatus == 'Request'
            //     ? Center(
            //         child: Container(
            //           margin: const EdgeInsets.only(
            //               top: 400, right: 20, left: 20),
            //           child: Text(
            //             "Waiting For Handling...",
            //             style: SafeGoogleFont(
            //               'SF Pro Text',
            //               fontSize: 12,
            //               fontWeight: FontWeight.w500,
            //               height: 1.2575,
            //               letterSpacing: 1,
            //               color: clrPrimary,
            //             ),
            //           ),
            //         ),
            //       )
            //     : Center(
            //         child: Container(
            //           color: Colors.white,
            //           margin: const EdgeInsets.only(
            //               top: 400, right: 20, left: 20),
            //           child: customTextEditingController(
            //             'Note',
            //             cntrlNip,
            //           ),
            //         ),
            //       ),
            ),
      ),
      floatingActionButton:
          // !isProcess
          //     ? lastHistoryStatus == 'Finish'
          //         ?
          Center(
        child: SizedBox(
          width: 150,
          height: 150,
          child: FittedBox(
            child: FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: clrPrimary,
              shape: const CircleBorder(),
              onPressed: () {
                _getCurrentPosition();
                // getData();
                // sortedData.clear;
                // historySos();
                // Navigator.of(context).pushAndRemoveUntil(
                //     MaterialPageRoute(
                //         builder: (context) => MainTabBar(
                //               page: 1,
                //               id: idUser.toString(),
                //             )),
                //     (Route<dynamic> route) => false);
              },
              child: const Icon(Icons.mic),
            ),
          ),
        ),
      ),
      //     : lastHistoryStatus == 'Request'
      //         ? Center(
      //             child: SizedBox(
      //               width: 150,
      //               height: 150,
      //               child: FittedBox(
      //                 child: FloatingActionButton(
      //                   foregroundColor: Colors.white,
      //                   backgroundColor: clrBackground,
      //                   shape: const CircleBorder(),
      //                   onPressed: () {},
      //                   child: const Text(
      //                     'Request',
      //                     style: TextStyle(color: clrBackgroundLight),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           )
      //         : Center(
      //             child: SizedBox(
      //               width: 150,
      //               height: 150,
      //               child: FittedBox(
      //                 child: FloatingActionButton(
      //                   foregroundColor: Colors.white,
      //                   backgroundColor: clrDone,
      //                   shape: const CircleBorder(),
      //                   onPressed: () {
      //                     // var idUser = await sharedPref.getPref("id_usr");
      //                     finishSos(sosId, cntrlNip.text);
      //                     sortedData.clear;
      //                     historySos();
      //                     Navigator.of(context).pushAndRemoveUntil(
      //                         MaterialPageRoute(
      //                             builder: (context) => MainTabBar(
      //                                   page: 1,
      //                                   id: idUser.toString(),
      //                                 )),
      //                         (Route<dynamic> route) => false);
      //                   },
      //                   child: const Text('Done'),
      //                 ),
      //               ),
      //             ),
      //           )
      // : loaderDialog(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
