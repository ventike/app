import 'package:http/http.dart' as http;
import 'package:ventike/utils/vars.dart';

Future<http.Response> requestPartners(String userHash) {
  final queryParameters = {
    'user_hash': userHash,
  };

  final uri = Uri.https(domain, "${apiRoute}partners/", queryParameters);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json"
    }
  );
}

Future<http.Response> addPartner(String userHash, String name, String description, String email, String phone, int type, String? image, String individualFirstName, String individualLastName, String individualEmail, String individualPhone, List<String> tags, List<String> resourceNames, List<int> resourceTypes, List<int> resourceAmounts) {
  final queryParameters = {
    'user_hash': userHash,
    'name': name,
    'description': description,
    'email': email,
    'phone': phone,
    'type': type.toString(),
    // 'image': image ?? "",
    'individual_first_name': individualFirstName,
    'individual_last_name': individualLastName,
    'individual_email': individualEmail,
    'individual_phone': individualPhone,
    'tags': tags.join(", "),
    'resource_names': resourceNames.join(", "),
    'resource_types': resourceTypes.join(", "),
    'resource_amounts': resourceAmounts.join(", ")
  };

  final uri = Uri.https(domain, "${apiRoute}create-partner/", queryParameters);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/x-www-form-urlencoded",
      // "IMAGE": image ?? ""
    },
    body: { "image" : image ?? "" }
  );
}

Future<http.Response> modifyPartner(String userHash, int id, String name, String description, String email, String phone, int type, String? image, String individualFirstName, String individualLastName, String individualEmail, String individualPhone, List<String> tags, List<String> resourceNames, List<int> resourceTypes, List<int> resourceAmounts) {
  final queryParameters = {
    'user_hash': userHash,
    'partner_id': id.toString(),
    'name': name,
    'description': description,
    'email': email,
    'phone': phone,
    'type': type.toString(),
    // 'image': image ?? "",
    'individual_first_name': individualFirstName,
    'individual_last_name': individualLastName,
    'individual_email': individualEmail,
    'individual_phone': individualPhone,
    'tags': tags.join(", "),
    'resource_names': resourceNames.join(", "),
    'resource_types': resourceTypes.join(", "),
    'resource_amounts': resourceAmounts.join(", ")
  };

  final uri = Uri.https(domain, "${apiRoute}modify-partner/", queryParameters);
  print(uri);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/x-www-form-urlencoded",
      // "IMAGE": image ?? ""
    },
    body: { "image" : image ?? "" }
  );
}

Future<http.Response> deletePartner(String userHash, int id) {
  final queryParameters = {
    'user_hash': userHash,
    'partner_id': id.toString()
  };

  final uri = Uri.https(domain, "${apiRoute}delete-partner/", queryParameters);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json"
    }
  );
}