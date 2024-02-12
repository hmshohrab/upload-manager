class UploadData {
  int id;
  String filePath;
  String fileName;
  String status; // e.g., "Queued", "Uploading", "Completed", "Failed"

  UploadData({
    required this.filePath,
    required this.fileName,
    this.id = 0,
    this.status = "Queued",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'status': status,
    };
  }

  factory UploadData.fromMap(Map<String, dynamic> map) {
    return UploadData(
      id: map['id'] as int,
      filePath: map['filePath'] as String,
      fileName: map['fileName'] as String,
      status: map['status'] as String,
    );
  }
}