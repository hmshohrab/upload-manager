import 'package:flutter/material.dart';
import 'package:flutter_utils_project/flutter_utils_project.dart';
import 'package:get/get.dart';
import 'package:upload_manager/app/core/base/base_view.dart';
import 'package:upload_manager/utils/extensions.dart';

import '../../../../utils/color_resources.dart';
import '../../../../utils/dimensions.dart';
import '../controllers/upload_history_controller.dart';

class UploadHistoryView extends BaseView<UploadHistoryController> {
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return getAppBar(context, "History",
        enableBackButton: true, onBackPressed: () {Get.back();});
  }

  @override
  Widget body(BuildContext context) {
    return Obx(() {
      return ListView(children: [buildPdfPreview()]);
    });
  }

  Widget buildPdfPreview() {
    if (controller.allFiles.isEmpty) {
      return const SizedBox();
    } else {
      List<Widget> documentList = [];

      controller.allFiles.forEach((element) {
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
                          child: const Icon(Icons.file_download_done_outlined)
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
                child: (element.status == "Completed")
                    ? Container(
                        color: ColorResources.kPrimaryColor,
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                        ))
                    : Container(
                        color: ColorResources.RED,
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        )))
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
