import 'package:get/get.dart';
import 'package:upload_manager/app/core/base/base_controller.dart';

import '../../home/DatabaseHelper.dart';
import '../../home/model/UploadData.dart';

class UploadHistoryController extends BaseController {
  final databaseHelper = DatabaseHelper();

  late List<UploadData> allFiles = <UploadData>[].obs;

  final count = 0.obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    final files = await databaseHelper.getAll();
    allFiles.clear();
    allFiles.addAll(files);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
