import 'package:model_repository/model_repository.dart';
import 'package:pocketbase/pocketbase.dart';

const String baseUrl = "/api/ezbadminton/admin";

class ApiEndpointRepository<M> {
  ApiEndpointRepository({
    required String url,
    required this.pocketBase,
    this.modelRepository,
    this.unmarshaller,
  }) : url = Uri.parse(baseUrl + url);

  final Uri url;
  final PocketBase pocketBase;
  // Model repostiory for resolving IDs in the API responses
  final ModelRepository? modelRepository;
  final M Function(Map<String, dynamic> json)? unmarshaller;

  Uri parameterizeUrl(Map<String, String> params) {
    var segments = url.pathSegments.map((s) {
      return params.containsKey(s) ? params[s]! : s;
    });
    return url.replace(pathSegments: segments);
  }

  Future<M> get({
    Map<String, String>? pathParams,
  }) async {
    var url = (pathParams == null) ? this.url : parameterizeUrl(pathParams);
    Map<String, dynamic> result = await pocketBase.send(url.toString());
    M object = unmarshaller!(result);
    modelRepository!.expandRelations([object]);
    return object;
  }

  Future<void> post({
    Map<String, dynamic> body = const {},
    Map<String, String>? pathParams,
  }) async {
    return _request("POST", body: body, pathParams: pathParams);
  }

  Future<void> patch({
    Map<String, dynamic> body = const {},
    Map<String, String>? pathParams,
  }) async {
    return _request("PATCH", body: body, pathParams: pathParams);
  }

  Future<void> delete({
    Map<String, dynamic> body = const {},
    Map<String, String>? pathParams,
  }) async {
    return _request("DELETE", body: body, pathParams: pathParams);
  }

  Future<void> _request(
    String method, {
    Map<String, dynamic> body = const {},
    Map<String, String>? pathParams,
  }) async {
    var url = (pathParams == null) ? this.url : parameterizeUrl(pathParams);
    await pocketBase.send(url.toString(), body: body, method: method);
  }
}
