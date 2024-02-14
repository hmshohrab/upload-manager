import 'dart:convert';
/// id : 1
/// ComplainID : 1
/// AttachmentTypeID : 2
/// filePath : ""
/// fileName : ""
/// status : "pending"

UploadData uploadDataFromJson(String str) => UploadData.fromJson(json.decode(str));
String uploadDataToJson(UploadData data) => json.encode(data.toJson());
class UploadData {
  UploadData({
      this.id, 
      this.complainID, 
      this.attachmentTypeID, 
      this.filePath, 
      this.fileName, 
      this.status,});

  UploadData.fromJson(dynamic json) {
    id = json['id'];
    complainID = json['ComplainID'];
    attachmentTypeID = json['AttachmentTypeID'];
    filePath = json['filePath'];
    fileName = json['fileName'];
    status = json['status'];
  }
  int? id;
  int? complainID;
  int? attachmentTypeID;
  String? filePath;
  String? fileName;
  String? status;
UploadData copyWith({  int? id,
  int? complainID,
  int? attachmentTypeID,
  String? filePath,
  String? fileName,
  String? status,
}) => UploadData(  id: id ?? this.id,
  complainID: complainID ?? this.complainID,
  attachmentTypeID: attachmentTypeID ?? this.attachmentTypeID,
  filePath: filePath ?? this.filePath,
  fileName: fileName ?? this.fileName,
  status: status ?? this.status,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['ComplainID'] = complainID;
    map['AttachmentTypeID'] = attachmentTypeID;
    map['filePath'] = filePath;
    map['fileName'] = fileName;
    map['status'] = status;
    return map;
  }

}