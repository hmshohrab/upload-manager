import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils_project/flutter_utils_project.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upload_manager/app/modules/home/model/UploadData.dart';

import '../../../../utils/color_resources.dart';
import '../../../../utils/dimensions.dart';
import '../../../../utils/extensions.dart';
import '../../../../utils/images.dart';
import '../../../core/values/text_styles.dart';
import '../DatabaseHelper.dart';
import '/app/core/base/base_view.dart';
import '/app/modules/home/controllers/home_controller.dart';

class HomeView extends BaseView<HomeController> {
  HomeView();

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return getAppBar(context, "Upload Manager",
        onBackPressed: null, enableBackButton: false);
  }

  @override
  Widget? drawer() {
    return null;
  }

  @override
  Widget? floatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () async {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.accessMediaLocation,
          Permission.manageExternalStorage,
          Permission.phone,
        ].request();
        print(statuses.toString());
        FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

        if (result != null) {
          // files = List.generate(1, (index) => result.files.first.name.toString());
          for (var element in result.paths) {
            var data = UploadData(
                id: Random().nextInt(1000),
                complainID: 20,
                attachmentTypeID: 2,
                filePath: element ?? "",
                fileName: element!.split("/").last,
                status: "Pending");
            await DatabaseHelper().insert(data);
            controller.allFiles.add(data);
          }
        } else {
          // User canceled the picker
        }
      },
      tooltip: 'Add',
      label: Text("Add"),
      icon: Icon(Icons.add),
    );
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
            children: List.generate(
                controller.allFiles.length,
                (index) => Stack(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeSmall),
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
                              Text(controller.allFiles[index].fileName ?? "")
                                  .flexible()
                            ],
                          ),
                        ),
                        Positioned(
                            right: 1,
                            child: Container(
                                color: ColorResources.kPrimaryColor,
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                )).onTap(() {
                              controller.deleteFile(controller.allFiles[index]);
                            }))
                      ],
                    ).marginAll(Dimensions.marginSizeSmall)),
          ).expand(),
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
                        controller.getImageFile().remove(value);
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
                        controller.getVideoFile().remove(value);
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
                        controller.allFiles.remove(value);
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
                // pickDocument();
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
                //_showPickerDialog(context, AttachmentType.Image);
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
                //_showImagePickerDialog(context);
                //_showPickerDialog(context, AttachmentType.Video);
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
                //_showAudioPickerDialog(context, AttachmentType.Audio);
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
                  onPressed: () {
                  },
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
              File(value.filePath??""),
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
              right: 1,
              child: Container(
                  color: ColorResources.kPrimaryColor,
                  child: const Icon(Icons.close, color: Colors.white))
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
                  color: ColorResources.kPrimaryColor,
                  child: const Icon(Icons.close, color: Colors.white))
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
              Text(value.fileName ?? "")
            ],
          ),
        ),
        Positioned(
            right: 1,
            child: Container(
                color: ColorResources.kPrimaryColor,
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                )).onTap(() {
              onTap();
            }))
            .visible(controller.getAudioFile().isNotEmpty == true)
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
                  Text(name ??"")
                ],
              ),
            ),
            Positioned(
                right: 1,
                child: Container(
                    color: ColorResources.kPrimaryColor,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    )).onTap(() {
                  controller.getDocFile().remove(element);
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
}
