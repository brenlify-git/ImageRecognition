import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:image_picker/image_picker.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
 @override
 Widget build (BuildContext context){
  return MaterialApp(
    title: 'Flutter with Machine Learning',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const MLDemo(title: 'Car, Airplane, and Motor'),
  );
 }
}

class MLDemo extends StatefulWidget{
  const MLDemo ({super.key, required this.title});
  final String title;
  @override
  State<MLDemo> createState() => _MLDemo();
}

class _MLDemo extends State<MLDemo> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";

  @override
  void initState() {
    super.initState();
    loadmodel().then((value){
      setState(() {});
    });
  }

loadmodel() async {
  await Tflite.loadModel(
    model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
}

Future<void> _pickImage() async {
  try {
    final XFile? image = await _picker.pickImage (source: ImageSource.gallery);
    setState((){
      _image = image;
      file = File(image!.path);
    });
    detectimage(file!);
  } catch (e) {
    print('Error picking image');
  }
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

    setState((){
      _recognitions = recognitions;
      v = recognitions.toString();
    });
    print("///////////////////////////////////////////////////////");
    print(_recognitions);
    print("///////////////////////////////////////////////////////");
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print ("Inference took ${endTime - startTime}ms");
}

@override
Widget build (BuildContext context){
  return Scaffold(
    appBar: AppBar(
      title: Text('Flutter TFLite'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment:MainAxisAlignment.center,
        children: <Widget>[
          if (_image != null)
          Image.file(
            File(_image!.path),
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          )
          else
            Text('No image selected'),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _pickImage, child: Text('Select Image from Gallery')),
            SizedBox(height: 20),
            Text(v)
        ],
      )),
  );
}
}