import 'package:get/get.dart';

import '../controllers/upload_history_controller.dart';

class UploadHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UploadHistoryController>(
      () => UploadHistoryController(),
    );
  }
}
