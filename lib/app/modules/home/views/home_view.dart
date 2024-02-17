import 'dart:io';
import 'dart:math';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils_project/flutter_utils_project.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_info/media_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:upload_manager/app/modules/home/model/UploadData.dart';
import 'package:upload_manager/app/modules/home/views/simple_recorder.dart';
import 'package:upload_manager/app/routes/app_pages.dart';

import '../../../../utils/color_resources.dart';
import '../../../../utils/dimensions.dart';
import '../../../../utils/extensions.dart';
import '../../../../utils/images.dart';
import '../../../core/values/text_styles.dart';
import '../DatabaseHelper.dart';
import '../model/Audio.dart';
import '/app/core/base/base_view.dart';
import '/app/modules/home/controllers/home_controller.dart';

class HomeView extends BaseView<HomeController> {
  final ImagePicker picker = ImagePicker();

  HomeView();

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return getAppBar(context, "Upload Manager",
        onBackPressed: null,
        enableBackButton: false,
        actions: [
          IconButton.outlined(
              onPressed: () {
                Get.toNamed(Routes.UPLOAD_HISTORY);
              },
              icon: const Icon(Icons.history))
        ]);
  }

  @override
  Widget? drawer() {
    return null;
  }

  @override
  Widget? floatingActionButton() {
    return null;
  }

  @override
  Widget body(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Text("${controller.currentJobLabel.value.id}"),
          Text(controller.label.value),
          const Divider(height: 20),
          ListView(
            children: [
              10.height,
              (controller.getDocFile().isNotEmpty)
                  ? buildPdfPreview()
                  : const SizedBox(),
              (controller.getImageFile().isNotEmpty)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Photos",
                          style: titleStyle,
                        ).paddingSymmetric(horizontal: 10),
                        const Divider(
                          thickness: 1,
                          height: 1,
                        ),
                        SizedBox(
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (var value in controller.getImageFile())
                                previewImageWidget(value, () {
                                  controller.removeFile(value);
                                }),
                            ],
                          ),
                        ).marginAll(Dimensions.marginSizeSmall),
                      ],
                    )
                  : const SizedBox(),
              (controller.getVideoFile().isNotEmpty)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Videos",
                          style: titleStyle,
                        ).paddingSymmetric(horizontal: 10),
                        const Divider(
                          thickness: 1,
                          height: 1,
                        ),
                        SizedBox(
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (var value in controller.getVideoFile())
                                previewVideoWidget(value, () {
                                  controller.removeFile(value);
                                }),
                            ],
                          ),
                        ).marginAll(Dimensions.marginSizeSmall),
                      ],
                    )
                  : const SizedBox(),
              (controller.getAudioFile().isNotEmpty == true)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Audio Record",
                          style: titleStyle,
                        ).paddingSymmetric(horizontal: 10),
                        const Divider(
                          thickness: 1,
                          height: 1,
                        ),
                        SizedBox(
                          child: Column(
                            children: [
                              for (var value in controller.getAudioFile())
                                previewAudioWidget(value, () {
                                  controller.removeFile(value);
                                }),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.1,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          image: Image.asset(ImagesAssets.pdf).image,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).onTap(() {
                    pickDocument();
                  }).expand(),
                  Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.1,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          image: Image.asset(ImagesAssets.camera).image,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).onTap(() {
                    _showPickerDialog(context, AttachmentType.image);
                  }).expand(),
                  Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.1,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          image: Image.asset(ImagesAssets.video).image,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).onTap(() {
                    _showPickerDialog(context, AttachmentType.video);
                  }).expand(),
                  Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.1,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          image: Image.asset(ImagesAssets.speaker).image,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).onTap(() {
                    _showAudioPickerDialog(context, AttachmentType.audio);
                  }).expand(),
                ],
              ).paddingSymmetric(horizontal: 10),
              10.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OutlinedButton(
                      onPressed: () {
                        controller.addAllQueue();
                      },
                      style: OutlinedButton.styleFrom(
                          backgroundColor: ColorResources.kPrimaryColor),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                          5.width,
                          Text(
                            "সাবমিট",
                            style: titleStyleWhite,
                          )
                        ],
                      )),
                  10.width,
                  OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF353333),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cancel,
                            color: Colors.white,
                          ),
                          5.width,
                          const Text(
                            "বাতিল",
                            style: titleStyleWhite,
                          )
                        ],
                      )),
                ],
              ),
              80.height
            ],
          ).expand(),
        ],
      );
    });
  }

  Widget previewImageWidget(UploadData value, Function onTap) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      child: Stack(
        children: [
          Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(
                  Radius.circular(Dimensions.radiusSmall)),
              border: Border.all(
                color: ColorResources.kPrimaryColor,
                width: 1.0,
              ),
            ),
            child: Image.file(
              File(value.filePath ?? ""),
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
              right: 1,
              child: Container(
                      color: ColorResources.RED,
                      child:
                          const Icon(Icons.delete_forever, color: Colors.white))
                  .onTap(() {
                //    controller.imageUploadStatus.value = UploadStatus.notStarted;
                //  controller.addImage(attachmentsType, index, "");
                // controller.fileList[index].imageFile = "";
                onTap();
                // controller.fileList[index] = controller.fileList[index].copyWith(imageFile: controller.fileList[index].imageFile);
              })).visible(true)
        ],
      ),
    );
  }

  Widget previewVideoWidget(UploadData value, Function onTap) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      child: Stack(
        children: [
          Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(
                  Radius.circular(Dimensions.radiusSmall)),
              border: Border.all(
                color: ColorResources.kPrimaryColor,
                width: 1.0,
              ),
            ),
            child: Stack(
              children: [
                Image.asset(
                  ImagesAssets.video,
                  fit: BoxFit.fill,
                ),
                const Icon(Icons.play_circle)
              ],
            ),
          ),
          Positioned(
              right: 1,
              child: Container(
                      color: ColorResources.RED,
                      child:
                          const Icon(Icons.delete_forever, color: Colors.white))
                  .onTap(() {
                //    controller.imageUploadStatus.value = UploadStatus.notStarted;
                //  controller.addImage(attachmentsType, index, "");
                // controller.fileList[index].imageFile = "";
                onTap();
                // controller.fileList[index] = controller.fileList[index].copyWith(imageFile: controller.fileList[index].imageFile);
              })).visible(true)
        ],
      ),
    );
  }

  previewAudioWidget(UploadData value, Function() onTap) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius:
                const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
            border: Border.all(
              color: ColorResources.kPrimaryColor,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 10.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: SizedBox(
                    width: 70.0,
                    height: 70.0,
                    child: ClipOval(
                      child: const Icon(Icons.mic_rounded)
                          .marginAll(5)
                          .fit(fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
              Text(value.fileName ?? "").flexible()
            ],
          ),
        ),
        Positioned(
            right: 1,
            child: Container(
                color: ColorResources.RED,
                child: const Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                )).onTap(() {
              onTap();
            })).visible(controller.getAudioFile().isNotEmpty == true)
      ],
    ).marginSymmetric(vertical: Dimensions.marginSizeSmall, horizontal: 15);
  }

  Widget buildPdfPreview() {
    if (controller.getDocFile().isEmpty) {
      return const SizedBox();
    } else {
      List<Widget> documentList = [];

      controller.getDocFile().forEach((element) {
        var name = element.fileName;
        Widget document = Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(
                    Radius.circular(Dimensions.radiusSmall)),
                border: Border.all(
                  color: ColorResources.kPrimaryColor,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 10.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: SizedBox(
                        width: 70.0,
                        height: 70.0,
                        child: ClipOval(
                          child: Icon(Icons.picture_as_pdf_outlined)
                              .marginAll(5)
                              .fit(fit: BoxFit.fill),
                        ),
                      ),
                    ),
                  ),
                  Text(name ?? "")
                ],
              ),
            ),
            Positioned(
                right: 1,
                child: Container(
                    color: ColorResources.RED,
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    )).onTap(() {
                  controller.removeFile(element);
                }))
          ],
        ).marginAll(Dimensions.marginSizeSmall);
        documentList.add(document);
      });

      /*    files?.forEach((e) => {
            extension = e.split("."),
            if (extension[extension.lastIndex] == "pdf")
              {list.add(Image.file(File(e)))}
            else
              {list.add(Image.file(File(e)))}
          });*/
      return Container(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [for (var value in documentList) value],
        ),
      );
    }
  }

  Future<void> _showPickerDialog(
      BuildContext context, AttachmentType attachmentType) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose an option"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text("Gallery"),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (attachmentType == AttachmentType.video) {
                      openCameraOrGalleryForVideo(ImageSource.gallery);
                    } else if (attachmentType == AttachmentType.image) {
                      openCameraOrGalleryForImage(ImageSource.gallery);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera),
                  title: Text("Camera"),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (attachmentType == AttachmentType.video) {
                      openCameraOrGalleryForVideo(ImageSource.camera);
                    } else if (attachmentType == AttachmentType.image) {
                      openCameraOrGalleryForImage(ImageSource.camera);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAudioPickerDialog(
      BuildContext context, AttachmentType attachmentType) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose an option"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text("Gallery"),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickAudioFile();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera),
                  title: Text("Record Audio"),
                  onTap: () {
                    Navigator.of(context).pop();
                    voiceRecordDialog("Input Voice", 350);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  openCameraOrGalleryForVideo(ImageSource source) async {
    final XFile? cameraOrGalleryVideo = await picker.pickVideo(source: source);
    if (cameraOrGalleryVideo?.path.isNotEmpty == true) {
      //  addFile(cameraOrGalleryVideo!.path, AttachmentType.video);

      controller.showLoading();

      await sliceVideo(cameraOrGalleryVideo!.path ?? "");
      controller.hideLoading();

      /*    var imageInt = await getThumbFile(cameraOrGalleryVideo!.path);
      if (imageInt != null) {
        controller.videoAttachmentStatus.value.files
            .add(cameraOrGalleryVideo.path);
        controller.updateVideoAttachmentStatus();
        controller.videoFilesThump.add(imageInt);
      }*/
    }
  }

  openCameraOrGalleryForImage(ImageSource source) async {
    final XFile? cameraOrGalleryImage = await picker.pickImage(source: source);
    if (cameraOrGalleryImage?.path.isNotEmpty == true) {
      addFile(cameraOrGalleryImage!.path, AttachmentType.image);
      /*    controller.imageAttachmentStatus.value.files
          .add(cameraOrGalleryImage!.path);
      controller.updateImageAttachmentStatus();*/
      //   controller.imageFiles.add(cameraOrGalleryImage!.path);
    }
  }

  Future<void> voiceRecordDialog(String title, double width) async {
    Audio m = await Get.generalDialog(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return ScaffoldMessenger(
            child: Builder(
                builder: (context) => Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        child: Container(
                            height: 300,
                            width: width,
                            margin: EdgeInsets.all(10),
                            color: Colors.white,
                            child: SimpleRecorder(
                                "controller.categoryModel.id.toString()")),
                      ),
                    ))));
      },
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    );
    if (!m.name.isEmptyOrNull) {
      addFile(m.name!, AttachmentType.audio);
    }
  }

  pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'WAV',
          'AIFF',
          'PCM',
          'FLAC',
          'ALAC',
          'WMA',
          'MP3',
          'AAC',
          'Ogg'
        ],
        allowMultiple: true);

    if (result != null) {
      for (var element in result.paths) {
        addFile(element ?? "", AttachmentType.audio);
      }
    } else {
      // User canceled the picker
    }
  }

  pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'TXT',
          'RTF',
          'DOC',
          'DOCX',
          'XLS',
          'XLSX',
          'ODS',
          'PPT',
          'PPTX',
          'ODP'
        ],
        allowMultiple: true);

    if (result != null) {
      for (var element in result.paths) {
        addFile(element ?? "", AttachmentType.file);
      }
    } else {
      // User canceled the picker
    }
  }

  addFile(String filePath, AttachmentType attachmentType) async {
    if (filePath.isNotEmpty) {
      final ifExisting = controller.allFiles
          .firstWhereOrNull((element) => element.filePath == filePath);
      if (ifExisting == null) {
        var data = UploadData(
            id: Random().nextInt(1000),
            complainID: 20,
            attachmentTypeID: attachmentType.number,
            filePath: filePath ?? "",
            fileName: filePath.split("/").last,
            status: "Pending");
        await DatabaseHelper().insert(data);
        controller.allFiles.add(data);
      }
    }
  }

  ///Executes the FFMPEG [command]
  ///Note: Green bar on the right is a Flutter issue. <https://github.com/flutter/engine/pull/24888>
  ///Should get fixed in a 3.1.0+ stable release <https://github.com/flutter/engine/pull/24888#issuecomment-1212374010>
  Future<ReturnCode?> ffmpegExecute(String command) async {
    final session = await FFmpegKit.execute(command);

    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      print("Success");
    } else if (ReturnCode.isCancel(returnCode)) {
      print("Cancel");
    } else {
      print("Error");
      final failStackTrace = await session.getFailStackTrace();
      print(failStackTrace);
      List<Log> logs = await session.getLogs();
      for (var element in logs) {
        print(element.getMessage());
      }
    }
    return returnCode;
  }

  final MediaInfo _mediaInfo = MediaInfo();

  Future<void> sliceVideo(String inputPath) async {
    final Map<String, dynamic> mediaInfo =
        await _mediaInfo.getMediaInfo(inputPath);
    int segmentDuration = 20;
    var totalDuration = mediaInfo["durationMs"] / 1000;
    if (kDebugMode) {
      print("Hello $totalDuration");
    }
    int numSegments = (totalDuration / segmentDuration).ceil();

    Directory directory = await getTemporaryDirectory();
    String outputDirectory = directory.path;
    List<String> trimmedFiles = [];

    for (int i = 0; i < numSegments; i++) {
      // String outputPath = '$outputDirectory-abcd.mp4';
      int startTime = i * segmentDuration;

      int endTime = startTime + segmentDuration;
      String outputPath =
          '$outputDirectory${Random.secure().nextInt(1000)}$startTime-$endTime.mp4';
      final returnCode = await ffmpegExecute(
          '-ss $startTime -to $endTime -y -i $inputPath -c:a copy $outputPath');
      if (ReturnCode.isSuccess(returnCode)) {
        trimmedFiles.add(outputPath);
        addFile(outputPath, AttachmentType.video);
      } else {
        addFile(inputPath, AttachmentType.video);
      }
    }
  }


}
