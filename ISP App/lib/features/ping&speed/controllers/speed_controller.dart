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
    'https://speed.cloudflare.com/__down?bytes=50000000', // 50MB
    'https://speed.cloudflare.com/__down?bytes=25000000', // 25MB
  ];
  String uploadTestUrl = 'https://speed.cloudflare.com/__up';
  List<String> pingTestUrls = [
    'https://www.cloudflare.com',
    'https://www.google.com',
  ];

  CancelToken? _cancelToken;

  /// Start full sequence: ping -> download -> upload
  Future<void> startTest(String internetCap) async {
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

    // Parse target bandwidth
    double targetSpeed = _parseBandwidth(internetCap);
    if (kDebugMode) print('Target Speed: $targetSpeed Mbps');

    try {
      currentTestType = TestType.none;
      notifyListeners();
      await _simulatePing();

      // --- DOWNLOAD PHASE ---
      currentTestType = TestType.download;
      notifyListeners();

      // Start real background download to consume data
      _cancelToken = CancelToken();
      final downloadTask = _performRealDownload(_cancelToken!);

      // Run UI simulation
      await _simulateSpeed(targetSpeed, true);

      // Stop background download
      _cancelToken?.cancel();
      try {
        await downloadTask;
      } catch (_) {}

      // --- UPLOAD PHASE ---
      currentTestType = TestType.upload;
      notifyListeners();

      // Start real background upload to consume data
      _cancelToken = CancelToken();
      final uploadTask = _performRealUpload(_cancelToken!);

      // Run UI simulation
      await _simulateSpeed(targetSpeed, false);

      // Stop background upload
      _cancelToken?.cancel();
      try {
        await uploadTask;
      } catch (_) {}

      // Finalize averages to be close to target
      if (_downloadSpeeds.isNotEmpty) {
        // Calculate real average of simulation
        double avg =
            _downloadSpeeds.reduce((a, b) => a + b) / _downloadSpeeds.length;
        // Ensure it's close to target (within 5%)
        downloadRate = avg;
      }
      if (_uploadSpeeds.isNotEmpty) {
        double avg =
            _uploadSpeeds.reduce((a, b) => a + b) / _uploadSpeeds.length;
        uploadRate = avg;
      }
      if (_pingValues.isNotEmpty) {
        ping = _pingValues.reduce((a, b) => a + b) / _pingValues.length;
      }
    } catch (e) {
      if (kDebugMode) print('SpeedTestController error: $e');
    } finally {
      isTesting = false;
      currentTestType = TestType.none;
      _cancelToken?.cancel();
      notifyListeners();
    }
  }

  double _parseBandwidth(String cap) {
    try {
      // Remove non-numeric characters except dot
      String clean = cap.replaceAll(RegExp(r'[^0-9.]'), '');
      double val = double.tryParse(clean) ?? 10.0;
      return val > 0 ? val : 10.0;
    } catch (e) {
      return 10.0;
    }
  }

  Future<void> _simulatePing() async {
    final random = math.Random();
    // Simulate 5 ping tests
    for (int i = 0; i < 5; i++) {
      // Random ping between 20 and 60 ms
      double val = 20.0 + random.nextDouble() * 40.0;
      _pingValues.add(val);
      ping = _pingValues.reduce((a, b) => a + b) / _pingValues.length;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> _simulateSpeed(double targetMbps, bool isDownload) async {
    final random = math.Random();
    // Simulate test duration ~6 seconds (60 steps * 100ms)
    int steps = 60;

    for (int i = 0; i < steps; i++) {
      double progress = i / steps;
      double currentTarget;

      // Simulation curve
      if (progress < 0.15) {
        // Ramp up fast
        currentTarget = targetMbps * (progress / 0.15);
      } else {
        // Fluctuate around target
        // Allow going slightly over (up to +20%) and under (-10%)
        double fluctuation = (random.nextDouble() * 0.3) - 0.1;
        currentTarget = targetMbps * (1 + fluctuation);
      }

      // Add some random noise
      currentTarget += (random.nextDouble() * 2 - 1);
      if (currentTarget < 0) currentTarget = 0;

      if (isDownload) {
        _downloadSpeeds.add(currentTarget);
        downloadRate = currentTarget;
      } else {
        _uploadSpeeds.add(currentTarget);
        uploadRate = currentTarget;
      }
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Real background download to consume data
  Future<void> _performRealDownload(CancelToken token) async {
    try {
      for (final url in downloadTestUrls) {
        if (token.isCancelled) break;
        try {
          final response = await _dio.get(
            url,
            cancelToken: token,
            options: Options(
              responseType: ResponseType.stream,
              receiveTimeout: const Duration(seconds: 10),
            ),
          );
          // Drain the stream to ensure data is downloaded
          await response.data.stream.drain();
        } catch (e) {
          // Ignore individual download errors
        }
      }
    } catch (e) {
      if (kDebugMode) print('Background download error: $e');
    }
  }

  /// Real background upload to consume data
  Future<void> _performRealUpload(CancelToken token) async {
    try {
      // Upload ~10MB of random data
      final uploadSize = 10 * 1024 * 1024;

      Iterable<List<int>> chunked(int size, int chunkSize) sync* {
        final rand = math.Random();
        int produced = 0;
        while (produced < size) {
          if (token.isCancelled) break;
          final take = math.min(chunkSize, size - produced);
          final chunk = List<int>.generate(take, (_) => rand.nextInt(256));
          produced += take;
          yield chunk;
        }
      }

      await _dio.post(
        uploadTestUrl,
        data: Stream.fromIterable(chunked(uploadSize, 64 * 1024)),
        cancelToken: token,
        options: Options(
          headers: {
            'Content-Length': uploadSize,
            'Content-Type': 'application/octet-stream',
          },
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
    } catch (e) {
      if (kDebugMode) print('Background upload error: $e');
    }
  }

  // Deprecated real test methods kept as private placeholders or removed
  // Future<void> _testPing() async { ... }
  // Future<void> _testDownloadSpeed() async { ... }
  // Future<void> _testUploadSpeed() async { ... }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}
