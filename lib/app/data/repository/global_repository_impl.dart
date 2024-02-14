import 'dart:collection';

import 'package:get/get.dart';
import 'package:get/get.dart' as get_x;
import 'package:upload_manager/app/core/model/list_response.dart';
import 'package:upload_manager/app/data/model/Attachment.dart';

import '/app/core/model/github_search_query_param.dart';
import '/app/data/model/github_project_search_response.dart';
import '/app/data/remote/global_remote_data_source.dart';
import '/app/data/repository/global_repository.dart';
import '../local/preference/preference_manager.dart';

class GlobalRepositoryImpl implements GlobalRepository {
  final GlobalRemoteDataSource _remoteSource =
      Get.find(tag: (GlobalRemoteDataSource).toString());

  final PreferenceManager _preferenceManager =
      get_x.Get.find(tag: (PreferenceManager).toString());

  @override
  Future<GithubProjectSearchResponse> searchProject(
      GithubSearchQueryParam queryParam) {
    return _remoteSource.searchGithubProject(queryParam);
  }

  @override
  Future<ListResponse<Attachment>> saveAttachment(HashMap<String, dynamic> hashMap, Function uploadingCallback) {
    return _remoteSource.saveAttachment(hashMap, uploadingCallback);
  }

}
