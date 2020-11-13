import 'dart:convert';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class FaceDetectorController {
  List<dynamic> rotationMatrix = [];

  void eraseRotationMatrix() {
    rotationMatrix = [];
  }

  void printRotationMatrix() {
    print("****** ROTATION MATRIX ${json.encode(rotationMatrix)}\n");
  }

  Future<List<Face>> extractFaces(File image) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    print('VisionImage: $image');

    final FaceDetectorOptions faceDetectorOptions = FaceDetectorOptions(enableTracking: true, enableLandmarks: true, enableContours: false, enableClassification: true, minFaceSize: 0.1,mode: FaceDetectorMode.accurate);

    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(faceDetectorOptions);

    faceDetector.processImage(visionImage);

    final List<Face> faces = await faceDetector.processImage(visionImage);
    print('Quantidade de Faces: ${faces.length}');

    for (Face face in faces) {
      var boundingBox = face.boundingBox;
      final double rotY = face.headEulerAngleY;
      final double rotZ = face.headEulerAngleZ;
      print('Rotação do Rosto: $rotY, $rotZ');

      rotationMatrix.add([rotY, rotZ]);

      if (rotationMatrix.length >= 9) {
        printRotationMatrix();
      }

      if (face.trackingId != null) {
        final int id = face.trackingId;
        print('Rosto: $id');
      }

      final FaceLandmark leftEar = face.getLandmark(FaceLandmarkType.leftEar);
      if (leftEar != null) {
        var leftEarPos = leftEar.position;
        print('posição da orelha esquerda: $leftEarPos');
      }

      if (face.smilingProbability != null) {
        var smileProb = face.smilingProbability;
        print('Sorrindo: $smileProb');
      }

      if (face.leftEyeOpenProbability != null){
        var leftEyeOpen = face.leftEyeOpenProbability;
        print('Olho Esquerdo aberto: $leftEyeOpen');
      }
      if (face.rightEyeOpenProbability != null){
        var rightEyeOpen = face.rightEyeOpenProbability;
        print('Olho Direito aberto: $rightEyeOpen');
      }
    }

    return faces ?? [];
  }
}
