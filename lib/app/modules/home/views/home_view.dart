import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_utils_project/flutter_utils_project.dart';
import 'package:get/get.dart';
import 'package:getx_template/app/modules/home/model/UploadData.dart';

import '../../../../utils/color_resources.dart';
import '../../../../utils/dimensions.dart';
import '../../../../utils/extensions.dart';
import '../DatabaseHelper.dart';
import '/app/core/base/base_view.dart';
import '/app/modules/home/controllers/home_controller.dart';

class HomeView extends BaseView<HomeController> {
  HomeView();

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return getAppBar(context, "GetX Template",
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
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(allowMultiple: true);

        if (result != null) {
          // files = List.generate(1, (index) => result.files.first.name.toString());
          for (var element in result.paths) {
            var data = UploadData(
                id: Random().nextInt(1000),
                filePath: element ?? "",
                fileName: element!.split("/").last);
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
      return ListView(
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
                          Text(controller.allFiles[index].fileName)
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
                          controller.allFiles
                              .remove(controller.allFiles[index]);
                          controller.databaseHelper
                              .delete(controller.allFiles[index].id);
                        }))
                  ],
                ).marginAll(Dimensions.marginSizeSmall)),
      );
    });
  }
}
