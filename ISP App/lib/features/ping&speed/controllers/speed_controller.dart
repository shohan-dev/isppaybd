import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:math' as math;
import '../screen/speed/widgets/test_type.dart';

class SpeedTestController extends ChangeNotifier {
  final Dio _dio = Dio();
  double downloadRate = 0.0;
  double uploadRate = 0.0;
  double ping = 0.0;
  bool isTesting = false;
  TestType currentTestType = TestType.none;

  // Internal tracking
  final List<double> _downloadSpeeds = [];
  final List<double> _uploadSpeeds = [];
  final List<double> _pingValues = [];

  // Configurable endpoints (can be overridden by tests)
  List<String> downloadTestUrls = [
    'https://speed.cloudflare.com/__down?bytes=10000000',
    'https://proof.ovh.net/files/10Mb.dat',
    'https://ash-speed.hetzner.com/10MB.bin',
  ];
  String uploadTestUrl = 'https://speed.cloudflare.com/__up';
  List<String> pingTestUrls = [
    'https://www.google.com',
    'https://www.cloudflare.com',
    'https://www.amazon.com',
  ];

  /// Start full sequence: ping -> download -> upload
  Future<void> startTest() async {
    if (isTesting) return;
    isTesting = true;
    downloadRate = 0.0;
    uploadRate = 0.0;
    ping = 0.0;
    currentTestType = TestType.download;
    _downloadSpeeds.clear();
    _uploadSpeeds.clear();
    _pingValues.clear();
    notifyListeners();

    try {
      currentTestType = TestType.none;
      notifyListeners();
      await _testPing();

      currentTestType = TestType.download;
      notifyListeners();
      await _testDownloadSpeed();

      currentTestType = TestType.upload;
      notifyListeners();
      await _testUploadSpeed();

      // finalize averages
      if (_downloadSpeeds.isNotEmpty) {
        downloadRate =
            _downloadSpeeds.reduce((a, b) => a + b) / _downloadSpeeds.length;
      }
      if (_uploadSpeeds.isNotEmpty) {
        uploadRate =
            _uploadSpeeds.reduce((a, b) => a + b) / _uploadSpeeds.length;
      }
      if (_pingValues.isNotEmpty) {
        ping = _pingValues.reduce((a, b) => a + b) / _pingValues.length;
      }
    } catch (e) {
      if (kDebugMode) print('SpeedTestController error: $e');
    } finally {
      isTesting = false;
      currentTestType = TestType.none;
      notifyListeners();
    }
  }

  Future<void> _testPing() async {
    for (final url in pingTestUrls) {
      try {
        final sw = Stopwatch()..start();
        await _dio.head(
          url,
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        sw.stop();
        final pingMs = sw.elapsedMilliseconds.toDouble();
        if (pingMs > 0 && pingMs < 5000) {
          _pingValues.add(pingMs);
          ping = _pingValues.reduce((a, b) => a + b) / _pingValues.length;
          notifyListeners();
        }
      } catch (e) {
        if (kDebugMode) print('Ping error $url: $e');
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> _testDownloadSpeed() async {
    for (int i = 0; i < downloadTestUrls.length && i < 2; i++) {
      final url = downloadTestUrls[i];
      try {
        final sw = Stopwatch()..start();
        int totalBytes = 0;
        int lastBytes = 0;
        int lastTimestamp = 0;

        final response = await _dio.get(
          url,
          options: Options(
            responseType: ResponseType.stream,
            receiveTimeout: const Duration(seconds: 20),
          ),
          onReceiveProgress: (received, total) {
            totalBytes = received;
            final currentTime = sw.elapsedMilliseconds;
            if (currentTime - lastTimestamp >= 500) {
              final bytesInInterval = received - lastBytes;
              final timeInterval = (currentTime - lastTimestamp) / 1000;
              if (timeInterval > 0) {
                final speedMbps =
                    (bytesInInterval * 8 / 1000000) / timeInterval;
                if (speedMbps > 0 && speedMbps < 10000) {
                  _downloadSpeeds.add(speedMbps);
                  downloadRate = speedMbps;
                  notifyListeners();
                }
              }
              lastBytes = received;
              lastTimestamp = currentTime;
            }
          },
        );

        // drain
        await response.data.stream.drain();

        sw.stop();
        final elapsedSeconds = sw.elapsedMilliseconds / 1000;
        if (elapsedSeconds > 0 && totalBytes > 0) {
          final speedMbps = (totalBytes * 8 / 1000000) / elapsedSeconds;
          if (speedMbps > 0 && speedMbps < 10000) {
            _downloadSpeeds.add(speedMbps);
          }
        }

        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        if (kDebugMode) print('Download error $url: $e');
      }
    }

    if (_downloadSpeeds.isNotEmpty) {
      downloadRate =
          _downloadSpeeds.reduce((a, b) => a + b) / _downloadSpeeds.length;
      notifyListeners();
    }
  }

  Future<void> _testUploadSpeed() async {
    for (int run = 0; run < 2; run++) {
      try {
        final uploadSize = 3 * 1024 * 1024; // 3MB
        // generate on the fly to reduce memory peak
        Iterable<List<int>> chunked(int size, int chunkSize) sync* {
          final rand = math.Random();
          int produced = 0;
          while (produced < size) {
            final take = math.min(chunkSize, size - produced);
            final chunk = List<int>.generate(take, (_) => rand.nextInt(256));
            produced += take;
            yield chunk;
          }
        }

        final sw = Stopwatch()..start();
        int lastSent = 0;
        int lastStamp = 0;

        await _dio.post(
          uploadTestUrl,
          data: Stream.fromIterable(chunked(uploadSize, 64 * 1024)),
          options: Options(
            headers: {
              'Content-Length': uploadSize,
              'Content-Type': 'application/octet-stream',
            },
            sendTimeout: const Duration(seconds: 40),
            receiveTimeout: const Duration(seconds: 40),
          ),
          onSendProgress: (sent, total) {
            final currentTime = sw.elapsedMilliseconds;
            if (currentTime - lastStamp >= 500) {
              final bytesInInterval = sent - lastSent;
              final timeInterval = (currentTime - lastStamp) / 1000;
              if (timeInterval > 0) {
                final speedMbps =
                    (bytesInInterval * 8 / 1000000) / timeInterval;
                if (speedMbps > 0 && speedMbps < 10000) {
                  _uploadSpeeds.add(speedMbps);
                  uploadRate = speedMbps;
                  notifyListeners();
                }
              }
              lastSent = sent;
              lastStamp = currentTime;
            }
          },
        );

        sw.stop();
        final elapsedSeconds = sw.elapsedMilliseconds / 1000;
        if (elapsedSeconds > 0 && uploadSize > 0) {
          final speedMbps = (uploadSize * 8 / 1000000) / elapsedSeconds;
          if (speedMbps > 0 && speedMbps < 10000) {
            _uploadSpeeds.add(speedMbps);
          }
        }

        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        if (kDebugMode) print('Upload error: $e');
      }
    }

    if (_uploadSpeeds.isNotEmpty) {
      uploadRate = _uploadSpeeds.reduce((a, b) => a + b) / _uploadSpeeds.length;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}
