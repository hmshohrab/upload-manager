import 'dart:convert';

import 'package:upload_manager/app/core/core.dart';

/// attachmentID : 72
/// referenceType : 1
/// referenceID : 6
/// attachementTypeID : 1
/// fileFormat : ".PNG"
/// attachmentName : "Audio"
/// attachmentLink : null
/// fileContent : "2024_08022024184408812_test_png_0000000006.PNG"
/// notes : null
/// status : 1
/// createdBy : 0
/// createdDate : "2024-02-08T18:44:08.813"
/// updatedBy : 0
/// updatedDate : "2024-02-08T18:44:08.813"

Attachment attachmentFromJson(String str) =>
    Attachment.fromJson(json.decode(str));

String attachmentToJson(Attachment data) => json.encode(data.toJson());

class Attachment extends Serializable {
  Attachment({
    this.attachmentID,
    this.referenceType,
    this.referenceID,
    this.attachementTypeID,
    this.fileFormat,
    this.attachmentName,
    this.attachmentLink,
    this.fileContent,
    this.notes,
    this.status,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  Attachment.fromJson(dynamic json) {
    attachmentID = json['attachmentID'];
    referenceType = json['referenceType'];
    referenceID = json['referenceID'];
    attachementTypeID = json['attachementTypeID'];
    fileFormat = json['fileFormat'];
    attachmentName = json['attachmentName'];
    attachmentLink = json['attachmentLink'];
    fileContent = json['fileContent'];
    notes = json['notes'];
    status = json['status'];
    createdBy = json['createdBy'];
    createdDate = json['createdDate'];
    updatedBy = json['updatedBy'];
    updatedDate = json['updatedDate'];
  }

  int? attachmentID;
  int? referenceType;
  int? referenceID;
  int? attachementTypeID;
  String? fileFormat;
  String? attachmentName;
  dynamic attachmentLink;
  String? fileContent;
  dynamic notes;
  int? status;
  int? createdBy;
  String? createdDate;
  int? updatedBy;
  String? updatedDate;

  Attachment copyWith({
    int? attachmentID,
    int? referenceType,
    int? referenceID,
    int? attachementTypeID,
    String? fileFormat,
    String? attachmentName,
    dynamic attachmentLink,
    String? fileContent,
    dynamic notes,
    int? status,
    int? createdBy,
    String? createdDate,
    int? updatedBy,
    String? updatedDate,
  }) =>
      Attachment(
        attachmentID: attachmentID ?? this.attachmentID,
        referenceType: referenceType ?? this.referenceType,
        referenceID: referenceID ?? this.referenceID,
        attachementTypeID: attachementTypeID ?? this.attachementTypeID,
        fileFormat: fileFormat ?? this.fileFormat,
        attachmentName: attachmentName ?? this.attachmentName,
        attachmentLink: attachmentLink ?? this.attachmentLink,
        fileContent: fileContent ?? this.fileContent,
        notes: notes ?? this.notes,
        status: status ?? this.status,
        createdBy: createdBy ?? this.createdBy,
        createdDate: createdDate ?? this.createdDate,
        updatedBy: updatedBy ?? this.updatedBy,
        updatedDate: updatedDate ?? this.updatedDate,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['attachmentID'] = attachmentID;
    map['referenceType'] = referenceType;
    map['referenceID'] = referenceID;
    map['attachementTypeID'] = attachementTypeID;
    map['fileFormat'] = fileFormat;
    map['attachmentName'] = attachmentName;
    map['attachmentLink'] = attachmentLink;
    map['fileContent'] = fileContent;
    map['notes'] = notes;
    map['status'] = status;
    map['createdBy'] = createdBy;
    map['createdDate'] = createdDate;
    map['updatedBy'] = updatedBy;
    map['updatedDate'] = updatedDate;
    return map;
  }
}
