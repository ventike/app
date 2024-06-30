import 'package:http/http.dart' as http;
import 'package:ventike/utils/vars.dart';

Future<http.Response> requestDashboardData(String userHash) {
  final queryParameters = {
    'user_hash': userHash,
  };

  final uri = Uri.https(domain, "${apiRoute}dashboard/", queryParameters);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json"
    }
  );
}