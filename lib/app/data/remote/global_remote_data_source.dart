import 'dart:collection';

import '../../core/model/list_response.dart';
import '../model/Attachment.dart';
import '/app/core/model/github_search_query_param.dart';
import '/app/data/model/github_project_search_response.dart';

abstract class GlobalRemoteDataSource {
  Future<GithubProjectSearchResponse> searchGithubProject(
      GithubSearchQueryParam queryParam);
  Future<ListResponse<Attachment>> saveAttachment(
      HashMap<String, dynamic> hashMap, Function uploadingCallback);
}
