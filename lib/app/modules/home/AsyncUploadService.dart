import 'dart:collection';

import 'package:async_queue/async_queue.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'DatabaseHelper.dart';
import 'model/UploadData.dart';

final queue = Queue<UploadData>();
final aQ = AsyncQueue.autoStart(
  // allowDuplicate: false,
);
class AsyncUploadService {
  static const _uploadUrl =
      "http://182.160.105.228:8018/Attachments/saveApplicationFileAttachments"; // Replace with your actual endpoint

  Future<void> startUpload() async {
    while (queue.isNotEmpty) {
      var uploadData = queue.removeFirst();

      try {
        final connectivityResult = await (Connectivity().checkConnectivity());

        // Check internet connectivity before starting upload
        if (connectivityResult != ConnectivityResult.none) {
          throw Exception("No internet connection");
        }

        // Perform the upload
        await _uploadFile(uploadData.filePath ??"", uploadData.fileName??"");

        // Update upload status
        uploadData.status = "Completed";
      } catch (error) {
        // Handle upload failure
        uploadData.status = "Failed";
        print("Error uploading ${uploadData.fileName}: $error");

        // Optionally implement retry logic:
        // - Add uploadData back to the queue with a delay or exponential backoff
        // - Limit the number of retries to avoid infinite loops
      } finally {
        // Update status in database regardless of success or failure
        await DatabaseHelper().update(uploadData);
      }
    }
  }

  Future<void> _uploadFile(String filePath, String fileName) async {
    // Replace with your actual upload logic using Dio or Flutter_http
    // Consider including progress reporting and cancellation support
    final response = await Dio().post(
      _uploadUrl,
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed with status code: ${response.statusCode}');
    }
  }
}
