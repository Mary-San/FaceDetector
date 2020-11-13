import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:face_recognition/ExportVideoFrame.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:face_recognition/face_detector_controller.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          accentColor: Colors.amberAccent,
        ),
        home: FacePage(),
      ),
    );

class FacePage extends StatefulWidget {
  @override
  _FacePageState createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {
  File _videoFile;
  List<Face> _faces;
  bool isLoading = false;
  List<ui.Image> _images;
  Duration videoDuration = Duration(seconds: 5);
  FaceDetectorController faceDetec = FaceDetectorController();

  _getImageAndDetectFaces() async {
    /// Pega o arquivo, processa, e quebra em frames, nesse caso:
    /// frames = 10
    _faces = [];
    _images = [];
    faceDetec.eraseRotationMatrix();

    ExportVideoFrame exptVF = ExportVideoFrame();
    // ignore: deprecated_member_use
    _videoFile = await ImagePicker.pickVideo(
        source: ImageSource.gallery, maxDuration: videoDuration);
    final frames = await exptVF.exportImage(_videoFile.path, 10, 1); //caminho, total de frames, qualidade
    setState(() {
      isLoading = true;
      Text("Processando seu arquivo, aguarde", style: TextStyle(fontSize: 25));
    });
    frames.forEach((File frame) {
      faceDetec.extractFaces(frame).then((result) {
        _faces.addAll(result);

        if (result.length > 0) {
          setState(() {
            _loadImage(frame);
          });
        }
      });
    });
  }

  _loadImage(File file) async { 
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        _images.add(value);
        isLoading = false;
      }),
    );
  }

  /// Home _______________________________________________________________________
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        title: Text('Reconhecimento Facial', style: TextStyle(fontSize: 25)),
        elevation: 10,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ((_images ?? []).length == 0)
              ? Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nenhum video Selecionado',
                        style: TextStyle(fontSize: 17),
                      )
                    ],
                  ),
                )
              : Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Arquivo escaneado.",
                                  style: TextStyle(fontSize: 17),
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 600,
                        width: 450,
                        child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: _images.map((img) {
                              return Card(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: FittedBox(
                                    child: SizedBox(
                                      width: img.width.toDouble(),
                                      height: img.height.toDouble(),
                                      child: CustomPaint(
                                        painter: FacePainter(img, _faces),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList()),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectFaces,
        backgroundColor: Colors.orange,
        child: Icon(Icons.video_library),
      ),
    );
  }
}

/// canvas painter _______________________________________________________________________
/// Desenha um quadro, marcando o rosto escaneado, quando encontra um.
class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.orange;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}
