import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ventike/utils/vars.dart';

Future<http.Response> requestAPIKey(String userHash) {
  final queryParameters = {
    'user_hash': userHash,
  };

  final uri = Uri.https(domain, "${apiRoute}openai-key/", queryParameters);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json"
    }
  );
}

Future<http.Response> sendMessage(List<Map<String, String>> messages, String openAIKey) {
  final uri = Uri.https("api.openai.com", "/v1/chat/completions");

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json",
      "Authorization": "Bearer $openAIKey"
    },
    body: jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": messages
    })
  );
}