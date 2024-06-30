import 'package:http/http.dart' as http;
import 'package:ventike/utils/vars.dart';

Future<http.Response> modifyOrganization(String userHash, String name, String? messageTitle, String? message, int? messageIcon) {
  final queryParameters = {
    'user_hash': userHash,
    'name': name,
    'message_title': messageTitle ?? "",
    'message': message ?? "",
    'message_icon': messageIcon == null ? "" : messageIcon.toString(),
  };

  final uri = Uri.https(domain, "${apiRoute}modify-organization/", queryParameters);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json",
      // "IMAGE": image ?? ""
    },
  );
}