import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../core/api/api_urls.dart';
import '../../core/networkCaller/networkCaller.dart';
import '../../core/networkCaller/http_method.dart';

class WatchVideoController extends GetxController {
  VideoPlayerController? videoController;

  // ─────────────── UI States ───────────────
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // ─────────────── Video Metadata ───────────────
  final RxString videoTitle = ''.obs;
  final RxString videoDescription = ''.obs;
  final RxString videoThumbnail = ''.obs;
  final RxString videoId = ''.obs;

  // ─────────────── Data from previous screen ───────────────
  String email = '';

  // ─────────────── Progress & Time ───────────────
  final RxDouble progress = 0.0.obs;
  final RxBool isVideoFinished = false.obs;
  final RxBool hasStartedPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Read email passed from HomeScreen
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?['email']?.toString() ?? '';
    _fetchVideoData();
  }

  // ═══════════════════════════════════════════════
  //  API Fetch
  // ═══════════════════════════════════════════════

  Future<void> _fetchVideoData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final networkCaller = Get.find<NetworkCaller>();

      final response = await networkCaller.request(
        url: ApiUrls.video,
        method: HttpMethod.get,
      );

      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('📡 Video API raw response: $data');
        final videoData = data['data'] ?? data;
        debugPrint('🎬 Parsed video data: $videoData');
        _handleVideoResponse(
          videoData is Map<String, dynamic> ? videoData : data,
        );
      } else {
        debugPrint('❌ Video API failed: ${response.message}');
        _setError(response.message ?? 'No video available.');
      }
    } catch (e) {
      debugPrint('💥 Video API exception: $e');
      _setError('An unexpected error occurred: $e');
    }
  }

  void _handleVideoResponse(Map<String, dynamic> data) {
    videoTitle.value = data['title']?.toString() ?? '';
    videoDescription.value = data['description']?.toString() ?? '';
    videoThumbnail.value = data['thumbnail']?.toString() ?? '';
    videoId.value = data['_id']?.toString() ?? '';

    final videoUrl = data['url']?.toString() ?? '';

    if (videoUrl.isEmpty) {
      _setError('No video available.');
      return;
    }

    _initializeVideo(videoUrl);
  }

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    isLoading.value = false;
  }

  // ═══════════════════════════════════════════════
  //  Video Initialization & Playback
  // ═══════════════════════════════════════════════

  Future<void> _initializeVideo(String url) async {
    try {
      debugPrint('🎬 Initializing video from URL: $url');

      // Dispose existing controller if any
      if (videoController != null) {
        await videoController!.dispose();
        videoController = null;
      }

      videoController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      // Set a timeout for video initialization to prevent infinite loading
      await videoController!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Video initialization timed out after 30 seconds');
        },
      );

      videoController!.addListener(_videoListener);
      
      // Ensure the controller is ready and state is updated
      if (videoController!.value.hasError) {
        throw Exception(videoController!.value.errorDescription ?? 'Unknown video player error');
      }

      isLoading.value = false;
      hasError.value = false;
      update();
      debugPrint('✅ Video initialized successfully');
    } catch (e) {
      debugPrint('❌ Video initialization failed: $e');
      _setError('Could not load video. Please check your connection and try again.');
      
      // Clean up on error
      if (videoController != null) {
        videoController!.dispose();
        videoController = null;
      }
    }
  }

  void _videoListener() {
    final vc = videoController;
    if (vc == null) return;

    // Handle unexpected errors during playback
    if (vc.value.hasError) {
      debugPrint('❌ Video playback error: ${vc.value.errorDescription}');
      _setError('Video playback failed: ${vc.value.errorDescription}');
      vc.removeListener(_videoListener);
      return;
    }

    if (!vc.value.isInitialized) return;

    final position = vc.value.position;
    final duration = vc.value.duration;

    // Update progress
    if (duration.inMilliseconds > 0) {
      progress.value = (position.inMilliseconds / duration.inMilliseconds)
          .clamp(0.0, 1.0);
    }

    // Check if finished
    if (position >= duration && duration.inMilliseconds > 0 && !isVideoFinished.value) {
      isVideoFinished.value = true;
      debugPrint('🎉 Video playback finished');
    }

    update();
  }

  /// Retry fetching video data and initializing player.
  void retry() {
    debugPrint('🔄 Retrying video load...');
    _fetchVideoData();
  }

  void playPause() {
    final vc = videoController;
    if (vc == null) return;

    if (!hasStartedPlaying.value) {
      hasStartedPlaying.value = true;
      vc.play();
      update();
      return;
    }

    if (vc.value.isPlaying) {
      vc.pause();
    } else {
      vc.play();
    }
    update();
  }

  @override
  void onClose() {
    videoController?.removeListener(_videoListener);
    videoController?.dispose();
    super.onClose();
  }
}
