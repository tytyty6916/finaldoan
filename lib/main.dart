// import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImagePickerDemo(),
    );
  }
}

class ImagePickerDemo extends StatefulWidget {
  @override
  _ImagePickerDemoState createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";
  // var dataList = [];
  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _pickImage() async {

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
        file = File(image!.path);
      });
      detectimage(file!);
      Navigator.of(context).pop();

  }
  Future<void>_pickCam() async{
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
  setState(() {
    _image=image;
    file=File(image!.path);
  });

    detectimage(file!);
  Navigator.of(context).pop();
  }
  Future detectimage(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = recognitions;
      recognitions!.forEach(
            (prediction) {
          v +=
              prediction['label'].toString().substring(0, 1).toUpperCase() +
                  prediction['label'].toString().substring(1) +
                  " " +
                  (prediction['confidence'] as double).toStringAsFixed(3) +
                  '\n';
        },
      );;
      // dataList = List<Map<String, dynamic>>.from(jsonDecode(v));
    });
    print("//////////////////////////////////////////////////");
    print(_recognitions);
    // print(dataList);
    print("//////////////////////////////////////////////////");
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: const Text('App nhận diện biển báo giao thông'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 250,
                width: 250,
                fit: BoxFit.cover,
              )
            else

              const CircleAvatar(
                  radius: 150,
                  backgroundImage: AssetImage("assets/e1.jpg")

              ),
            const SizedBox(height: 20,),
            const SizedBox(
              width: 150,
              height: 40,
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: double.minPositive,),
                  child: Center(child: Text('KẾT QUẢ  '),)
              ),
            ),
            const SizedBox(height: 20),
            Card(child: Center(child: Text(v))),
            const SizedBox(height: 20),
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.white60,
                      context: context,
                      builder: (BuildContext content){
                        return Container(
                            height: 200,
                            padding: const EdgeInsets.symmetric(horizontal:100,),
                            child:Column(
                              children: [
                                const SizedBox(height: 15,),

                                SizedBox(
                                  height: 70,
                                  width: double.infinity,
                                  child :ElevatedButton(
                                    onPressed: _pickCam,
                                    child: const Text('Camera'),
                                  ),
                                ),
                                const SizedBox(height: 15,),

                                SizedBox(
                                  height: 70,
                                  width: double.infinity,
                                  child :ElevatedButton(
                                    onPressed: _pickImage,
                                    child: const Text('Gallery'),

                                  ),
                                ),

                              ],
                            )
                        );
                      }
                  );
                },
                child: const Text('Pick Image from Gallery'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}