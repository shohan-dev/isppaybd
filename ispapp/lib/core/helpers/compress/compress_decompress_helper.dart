import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class SCompressDecompressHelper {
  // 📦 Load and decompress a JSON file from assets
  static Future<dynamic> decompressJsonFromAsset(
    String assetPath, {
    String format = "gzip",
  }) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final compressedBytes = byteData.buffer.asUint8List();
      return decompressJson(compressedBytes, format: format);
    } catch (e) {
      print("Error decompressing JSON from asset: $e");
      rethrow;
    }
  }

  // 🗜️ Compress text data using the selected format
  static List<int> compressData(String data, {String format = "gzip"}) {
    try {
      List<int> inputBytes = utf8.encode(data);
      switch (format.toLowerCase()) {
        case "gzip":
          return GZipEncoder().encode(inputBytes);
        case "zlib":
          return ZLibEncoder().encode(inputBytes);
        case "zip":
          return _zipEncode(inputBytes);
        default:
          throw UnsupportedError("Unsupported compression format: $format");
      }
    } catch (e) {
      print("Error compressing data: $e");
      rethrow;
    }
  }

  // 🔓 Decompress byte data using the selected format
  static String decompressData(
    List<int> compressedData, {
    String format = "gzip",
  }) {
    try {
      List<int> decompressedBytes;
      switch (format.toLowerCase()) {
        case "gzip":
          decompressedBytes = GZipDecoder().decodeBytes(compressedData);
          break;
        case "zlib":
          decompressedBytes = ZLibDecoder().decodeBytes(compressedData);
          break;
        case "zip":
          decompressedBytes = _zipDecode(compressedData);
          break;
        default:
          throw UnsupportedError("Unsupported decompression format: $format");
      }
      return utf8.decode(Uint8List.fromList(decompressedBytes));
    } catch (e) {
      print("Error decompressing data: $e");
      rethrow;
    }
  }

  // 📂 Compress and save to a file
  static Future<void> compressToFile(
    String data,
    String filePath, {
    String format = "gzip",
  }) async {
    try {
      final compressedBytes = compressData(data, format: format);
      await File(filePath).writeAsBytes(compressedBytes);
      print("Data successfully compressed and saved to $filePath");
    } catch (e) {
      print("Error saving compressed file: $e");
      rethrow;
    }
  }

  // 📂 Decompress from a file
  static Future<String> decompressFromFile(
    String filePath, {
    String format = "gzip",
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileSystemException("File not found: $filePath");
      }

      final compressedBytes = await file.readAsBytes();
      return decompressData(compressedBytes, format: format);
    } catch (e) {
      print("Error reading and decompressing file: $e");
      rethrow;
    }
  }

  // 📦 Compress a JSON object into bytes
  static List<int> compressJson(
    List<dynamic> jsonData, {
    String format = "gzip",
  }) {
    return compressData(jsonEncode(jsonData), format: format);
  }

  // 📦 Decompress bytes into a JSON object
  static dynamic decompressJson(
    List<int> compressedData, {
    String format = "gzip",
  }) {
    return jsonDecode(decompressData(compressedData, format: format));
  }

  // // 📦 Load and decompress a JSON file from assets
  // static Future<dynamic> decompressJsonFromAsset(
  //   String assetPath, {
  //   String format = "gzip",
  // }) async {
  //   try {
  //     final byteData = await rootBundle.load(assetPath);
  //     final compressedBytes = byteData.buffer.asUint8List();
  //     return decompressJson(compressedBytes, format: format);
  //   } catch (e) {
  //     print("Error decompressing JSON from asset: $e");
  //     rethrow;
  //   }
  // }

  // 🔍 Check if file exists
  static Future<bool> fileExists(String path) async =>
      await File(path).exists();

  // 📌 Validate JSON format
  static bool isValidJson(String data) {
    try {
      jsonDecode(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 📌 Get temp directory path
  static Future<String> getTempDirectory() async =>
      (await getTemporaryDirectory()).path;

  // 🔵 Internal ZIP encoding
  static List<int> _zipEncode(List<int> data) {
    final archive = Archive();
    archive.addFile(ArchiveFile('data.txt', data.length, data));
    return ZipEncoder().encode(archive);
  }

  // 🔵 Internal ZIP decoding
  static List<int> _zipDecode(List<int> compressedData) {
    final archive = ZipDecoder().decodeBytes(compressedData);
    return archive.isNotEmpty ? archive.first.content as List<int> : [];
  }
}
