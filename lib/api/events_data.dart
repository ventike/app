import 'package:http/http.dart' as http;
import 'package:ventike/utils/vars.dart';

Future<http.Response> requestEvents(String userHash) {
  final queryParameters = {
    'user_hash': userHash,
  };

  final uri = Uri.https(domain, "${apiRoute}events/", queryParameters);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json"
    }
  );
}

Future<http.Response> addEvent(String userHash, String name, String description, String date, String startTime, String endTime, List<int> partners) {
  final queryParameters = {
    'user_hash': userHash,
    'name': name,
    'description': description,
    'date': date,
    'start_time': startTime,
    'end_time': endTime,
    'partners': partners.join(", ")
  };

  final uri = Uri.https(domain, "${apiRoute}create-event/", queryParameters);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json",
      // "IMAGE": image ?? ""
    },
  );
}

Future<http.Response> modifyEvent(String userHash, int id, String name, String description, String date, String startTime, String endTime, List<int> partners) {
  final queryParameters = {
    'user_hash': userHash,
    'event_id': id.toString(),
    'name': name,
    'description': description,
    'date': date,
    'start_time': startTime,
    'end_time': endTime,
    'partners': partners.join(", ")
  };
  print(queryParameters.toString());


  final uri = Uri.https(domain, "${apiRoute}modify-event/", queryParameters);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json",
      // "IMAGE": image ?? ""
    },
  );
}

Future<http.Response> deleteEvent(String userHash, int id) {
  final queryParameters = {
    'user_hash': userHash,
    'event_id': id.toString()
  };

  final uri = Uri.https(domain, "${apiRoute}delete-event/", queryParameters);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json"
    }
  );
}