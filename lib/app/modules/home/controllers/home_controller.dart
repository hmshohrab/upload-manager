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
import '/app/core/model/github_search_query_param.dart';
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

  void getGithubGetxProjectList() {
    if (!pagingController.canLoadNextPage()) return;

    pagingController.isLoadingPage = true;

    var queryParam = GithubSearchQueryParam(
      searchKeyWord: 'flutter Upload Manager',
      pageNumber: pagingController.pageNumber,
    );

    var githubRepoSearchService = _repository.searchProject(queryParam);

    callDataService(
      githubRepoSearchService,
      onSuccess: _handleProjectListResponseSuccess,
    );

    pagingController.isLoadingPage = false;
  }

  onRefreshPage() {
    pagingController.initRefresh();
    getGithubGetxProjectList();
  }

  onLoadNextPage() {
    logger.i("On load next");

    getGithubGetxProjectList();
  }

  void _handleProjectListResponseSuccess(GithubProjectSearchResponse response) {
    List<GithubProjectUiData>? repoList = response.items
        ?.map((e) => GithubProjectUiData(
              repositoryName: e.name != null ? e.name! : "Null",
              ownerLoginName: e.owner != null ? e.owner!.login! : "Null",
              ownerAvatar: e.owner != null ? e.owner!.avatarUrl! : "",
              numberOfStar: e.stargazersCount ?? 0,
              numberOfFork: e.forks ?? 0,
              score: e.score ?? 0.0,
              watchers: e.watchers ?? 0,
              description: e.description ?? "",
            ))
        .toList();

    if (_isLastPage(repoList!.length, response.totalCount!)) {
      pagingController.appendLastPage(repoList);
    } else {
      pagingController.appendPage(repoList);
    }

    var newList = [...pagingController.listItems];

    _githubProjectListController(newList);
  }

  bool _isLastPage(int newListItemCount, int totalCount) {
    return (projectList.length + newListItemCount) >= totalCount;
  }

  performUpload(File file) {}

  Future<void> addAllQueue() async {
    final files = await databaseHelper.getAll();
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
            allFiles.remove(element);
            if (element.id != null) databaseHelper.delete(element.id!);
          }
        });
      }, label: element);
    }
  }

  void deleteFile(UploadData uploadData) {
    allFiles.remove(uploadData);
    databaseHelper.delete(uploadData.id ?? 0);
  }
}
