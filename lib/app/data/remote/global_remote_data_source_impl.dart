import 'dart:collection';

import 'package:dio/dio.dart';

import '../../../data/end_points.dart';
import '../../core/model/list_response.dart';
import '../model/Attachment.dart';
import '/app/core/base/base_remote_source.dart';
import '/app/core/model/github_search_query_param.dart';
import '/app/data/model/github_project_search_response.dart';
import '/app/data/remote/global_remote_data_source.dart';
import '/app/network/dio_provider.dart';

class GlobalRemoteDataSourceImpl extends BaseRemoteSource
    implements GlobalRemoteDataSource {
  @override
  Future<GithubProjectSearchResponse> searchGithubProject(
      GithubSearchQueryParam queryParam) {
    var endpoint = "${DioProvider.baseUrl}/search/repositories";
    var dioCall = dioClient.get(endpoint, queryParameters: queryParam.toJson());

    try {
      return callApiWithErrorParser(dioCall)
          .then((response) => _parseGithubProjectSearchResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  _parseGithubProjectSearchResponse(Response response) {}


  @override
  Future<ListResponse<Attachment>> saveAttachment(
      HashMap<String, dynamic> hashMap, Function uploadingCallback) {
    var endpoint = Endpoints.saveApplicationFileAttachmentsUrl;
    final formData = FormData.fromMap(hashMap);
    var dioCall = dioClient.post(
      endpoint,
      data: formData,
      onSendProgress: (int sent, int total) {
        double progress = sent / total * 100;
        uploadingCallback(progress);
      },
    );

    try {
      return callApiWithErrorParser(dioCall)
          .then((response) => ListResponse.fromJson(response.data, () {
        List<Attachment> items = [];
        if (response.data["responseObj"] != null) {
          response.data["responseObj"].forEach((v) {
            items.add(Attachment.fromJson(v));
          });
        }
        return items;
      }));
    } catch (e) {
      rethrow;
    }
  }

}
