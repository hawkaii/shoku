import 'dart:convert';

import 'package:image_picker/image_picker.dart';

/// A receipt photo, made small enough to be read by a model.
///
/// The picker does the decoding and re-encoding in the platform's own code, so
/// a 6 MB photograph becomes a few hundred KB and never makes a round trip
/// through Dart. The numbers are the contract's: 1600 px on the long edge,
/// JPEG at about 80.
class ReceiptImage {
  const ReceiptImage._();

  static const maxEdge = 1600;
  static const jpegQuality = 80;

  /// The one place those numbers live, so a test can pin them.
  static const pickOptions = (maxEdge: maxEdge, quality: jpegQuality);

  /// Picks [source] and returns the bytes, already downscaled.
  static Future<List<int>?> pickFrom(ImageSource source,
      {ImagePicker? picker}) async {
    final file = await (picker ?? ImagePicker()).pickImage(
      source: source,
      maxWidth: maxEdge.toDouble(),
      maxHeight: maxEdge.toDouble(),
      imageQuality: jpegQuality,
    );
    if (file == null) return null;
    return file.readAsBytes();
  }

  /// What we are actually sending. The picker asks for JPEG, but a screenshot
  /// comes back as PNG, and a web canvas may ignore the quality hint — so the
  /// bytes' own magic number decides, never the request we made.
  static String mimeTypeOf(List<int> bytes) {
    if (bytes.length > 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length > 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  static String base64Of(List<int> bytes) => base64Encode(bytes);
}
