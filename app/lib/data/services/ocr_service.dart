import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// On-device OCR for receipts and screenshots.
///
/// The image never leaves the phone: ML Kit runs the recogniser locally, and
/// only the text is used. There is no upload path here and no "try again when
/// you are back" — it works on a plane.
///
/// The browser has no such recogniser, and saying so is better than pretending
/// a screenshot was read.
class OcrService {
  /// Null when OCR cannot run here (web, or the model refused to load).
  Future<String?> readText(File image) async {
    if (kIsWeb) return null;
    TextRecognizer? recognizer;
    try {
      recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final input = InputImage.fromFile(image);
      final result = await recognizer.processImage(input);
      return result.text;
    } catch (_) {
      return null;
    } finally {
      await recognizer?.close();
    }
  }
}
