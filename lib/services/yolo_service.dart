import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class YoloDetection {
  final String className;
  final double confidence;
  final int classId;

  final double xmin;
  final double ymin;
  final double xmax;
  final double ymax;

  const YoloDetection({
    required this.className,
    required this.confidence,
    required this.classId,
    required this.xmin,
    required this.ymin,
    required this.xmax,
    required this.ymax,
  });
}

class YoloResult {
  final String diseaseName;
  final double confidence;
  final int classId;

  final double imageWidth;
  final double imageHeight;

  final List<YoloDetection> detections;

  const YoloResult({
    required this.diseaseName,
    required this.confidence,
    required this.classId,
    required this.imageWidth,
    required this.imageHeight,
    required this.detections,
  });
}

class YoloService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  static Future<YoloResult?> predict(XFile image) async {
    final uri = Uri.parse('$baseUrl/predict');

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'YOLO API error ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    if (data['ok'] != true) {
      throw Exception(
        data['error'] ?? 'Prediction failed',
      );
    }

    final bestDetection = data['best_detection'];

    if (bestDetection == null) {
      return null;
    }

    final rawDetections = data['detections'] as List<dynamic>;

    final detections = rawDetections.map((item) {
      final bbox = item['bbox'] as List<dynamic>;

      return YoloDetection(
        className: item['class_name'].toString(),
        confidence:
            (item['confidence'] as num).toDouble() * 100,
        classId: (item['class_id'] as num).toInt(),
        xmin: (bbox[0] as num).toDouble(),
        ymin: (bbox[1] as num).toDouble(),
        xmax: (bbox[2] as num).toDouble(),
        ymax: (bbox[3] as num).toDouble(),
      );
    }).toList();

    return YoloResult(
      diseaseName: bestDetection['class_name'].toString(),
      confidence:
          (bestDetection['confidence'] as num).toDouble() * 100,
      classId: (bestDetection['class_id'] as num).toInt(),
      imageWidth: (data['meta']['width'] as num).toDouble(),
      imageHeight: (data['meta']['height'] as num).toDouble(),
      detections: detections,
    );
  }
}