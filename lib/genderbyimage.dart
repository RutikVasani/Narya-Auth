import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:narya_auth/homepage.dart';

class GenderByImagePage extends StatefulWidget {
  const GenderByImagePage({super.key});

  @override
  State<GenderByImagePage> createState() => _GenderByImagePageState();
}

class _GenderByImagePageState extends State<GenderByImagePage> {
  late List _outputs;
  File? _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);
    setState(() {
      _loading = false;
      _outputs = output!;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  pickImage() async {
    // ignore: deprecated_member_use
    var imgCamera = await ImagePicker().getImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    setState(() {
      _loading = true;
      _image = File(imgCamera!.path);
    });
    classifyImage(_image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Gender Identifier",
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        backgroundColor: Colors.white,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _loading
                ? Container()
                : Container(
                    margin: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _image == null
                            ? Container()
                            : Image.file(
                                _image!,
                                height: MediaQuery.of(context).size.height / 2,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                              ),
                        SizedBox(
                          height: 20,
                        ),
                        _image == null
                            ? Container()
                            : _outputs != null
                                ? Column(
                                    children: <Widget>[
                                      Text(
                                        _outputs[0]["label"],
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 20),
                                      ),
                                      SizedBox(height: 10),
                                      InkWell(
                                        onTap: () {
                                          _outputs[0]["label"] == "female"
                                              ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const HomePage(),
                                                  ),
                                                )
                                              : pickImage();
                                        },
                                        child: Container(
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child:
                                                _outputs[0]["label"] == "female"
                                                    ? Text(
                                                        "Next",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 25,
                                                        ),
                                                      )
                                                    : Text(
                                                        "Try Again",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 25,
                                                        ),
                                                      ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : Container(child: Text(""))
                      ],
                    ),
                  ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
          ],
        ),
      ),
      floatingActionButton: _image != null
          ? Container()
          : FloatingActionButton(
              tooltip: 'Pick Image',
              onPressed: pickImage,
              child: Icon(
                Icons.camera,
                size: 20,
                color: Colors.white,
              ),
              backgroundColor: Colors.blue,
            ),
    );
  }
}
