import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upload_manager/app/modules/home/model/UploadData.dart';
import 'package:upload_manager/app/network/exceptions/app_exception.dart';

import '../../../core/model/list_response.dart';
import '../../../data/model/Attachment.dart';
import '../AsyncUploadService.dart';
import '../DatabaseHelper.dart';
import '/app/core/base/base_controller.dart';
import '/app/core/base/paging_controller.dart';
import '/app/data/model/github_project_search_response.dart';
import '/app/data/repository/global_repository.dart';
import '/app/modules/home/model/github_project_ui_data.dart';

enum AttachmentType {
  nothing,
  audio,
  image,
  video,
  map,
  file,
}

extension AttachmentTypeExtension on AttachmentType {
  int get number {
    switch (this) {
      case AttachmentType.audio:
        return 1;
      case AttachmentType.image:
        return 2;
      case AttachmentType.video:
        return 3;
      case AttachmentType.map:
        return 4;
      case AttachmentType.file:
        return 5;
      default:
        return 0;
    }
  }
}

class HomeController extends BaseController {
  final GlobalRepository _repository =
      Get.find(tag: (GlobalRepository).toString());

  final databaseHelper = DatabaseHelper();

  final RxList<GithubProjectUiData> _githubProjectListController =
      RxList.empty();

  List<GithubProjectUiData> get projectList =>
      _githubProjectListController.toList();

  final pagingController = PagingController<GithubProjectUiData>();

  late List<UploadData> allFiles = <UploadData>[].obs;
  Rx<UploadData> currentJobLabel = UploadData(filePath: "", fileName: "").obs;
  RxString label = "".obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.accessMediaLocation,
      Permission.manageExternalStorage,
      Permission.phone,
    ].request();
    print(statuses.toString());
    addAllQueue();
    aQ.addQueueListener((event) {
      final jobLabel = event.jobLabel as UploadData?;
      label.value = "running ${jobLabel?.id} - ${event.type}";
    });
    aQ.currentJobUpdate((jobLabel) {
      if (jobLabel != null) currentJobLabel.value = jobLabel as UploadData;
    });
  }

  List<UploadData> getAudioFile() {
    return allFiles
        .where((element) =>
            element.attachmentTypeID == AttachmentType.audio.number)
        .toList();
  }

  List<UploadData> getDocFile() {
    return allFiles
        .where(
            (element) => element.attachmentTypeID == AttachmentType.file.number)
        .toList();
  }

  List<UploadData> getImageFile() {
    return allFiles
        .where((element) =>
            element.attachmentTypeID == AttachmentType.image.number)
        .toList();
  }

  List<UploadData> getVideoFile() {
    return allFiles
        .where((element) =>
            element.attachmentTypeID == AttachmentType.video.number)
        .toList();
  }

  Future<void> saveAttachment(
      HashMap<String, dynamic> hashMap, Function callback) async {
    var a = await callDataService(
        _repository.saveAttachment(hashMap, (double value) {}),
        onSuccess: (ListResponse response) {
      if (response.statusCode == 1) {
        if (response is ListResponse<Attachment>) {
          //  attachmentsResult.add(response.responseObj as Attachment);
        }
        //  showSuccessMessage("Successfully uploaded");
      } else {
        showErrorMessage(response.message);
      }
      callback(response);
    }, onError: (e) {
      callback(e);
      // showSnackBar(Get.context!, (e as BaseApiException).message);
      Get.snackbar("Error", (e as AppException).message,
          snackPosition: SnackPosition.BOTTOM, colorText: Colors.red);
    });
    print(a);
    return a;
  }



  Future<void> addAllQueue() async {
    final files = await databaseHelper.getAllPending();
    allFiles.clear();
    allFiles.addAll(files);
    for (var element in files) {
      aQ.addJob((previousResult) async {
        HashMap<String, dynamic> hashmap = HashMap();
        hashmap['ComplainID'] = element.complainID;
        hashmap['AttachmentTypeID'] = element.attachmentTypeID;
        hashmap['Files'] = [
          await dio.MultipartFile.fromFile(element.filePath ?? "",
              filename: element.fileName)
        ];

        await saveAttachment(hashmap, (response) {
          if (response is ListResponse<Attachment>) {
            updateFile(element.copyWith(status: "Completed"));
          }
        });
      }, label: element);
    }
  }

  void updateFile(UploadData uploadData) {
    var data = allFiles.indexWhere((element) => element.id == uploadData.id);
    allFiles[data] = uploadData;
    databaseHelper.update(uploadData);
  }

  void removeFile(UploadData uploadData) {
      allFiles.remove(uploadData);
     databaseHelper.delete(uploadData.id ??0);
  }
}
