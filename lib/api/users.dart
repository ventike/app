import 'package:http/http.dart' as http;
import 'package:ventike/utils/vars.dart';

class User {
  final String userHash;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final int role;

  const User({
    required this.userHash,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'user_hash': String userHash,
        'username': String username,
        'email': String email,
        'first_name': String firstName,
        'last_name': String lastName,
        'role': int role,
      } =>
        User(
          userHash: userHash,
          username: username,
          email: email,
          firstName: firstName,
          lastName: lastName,
          role: role
        ),
      _ => throw const FormatException('Failed to load user.'),
    };
  }
}

Future<http.Response> requestLogin(String username, String password) {
  final queryParameters = {
    'username': username,
    'password': password,
  };

  final uri = Uri.https(domain, "${apiRoute}login/", queryParameters);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json"
    }
  );
}

Future<http.Response> createUser(String userHash, String username, String password, String email, String firstName, String lastName, int role) {
  final queryParameters = {
    'user_hash': userHash,
    'username': username,
    'password': password,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'role': role.toString()
  };

  final uri = Uri.https(domain, "${apiRoute}create-account/", queryParameters);
  print(uri);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json",
      // "IMAGE": image ?? ""
    }
  );
}

Future<http.Response> modifyUser(String userHash, int id, String username, String email, String firstName, String lastName, int role) {
  final queryParameters = {
    'user_hash': userHash,
    'user_id': id.toString(),
    'username': username,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'role': role.toString()
  };

  final uri = Uri.https(domain, "${apiRoute}modify-user/", queryParameters);
  print(uri);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json",
      // "IMAGE": image ?? ""
    }
  );
}

Future<http.Response> deleteUser(String userHash, int id) {
  final queryParameters = {
    'user_hash': userHash,
    'user_id': id.toString()
  };

  final uri = Uri.https(domain, "${apiRoute}delete-user/", queryParameters);

  return http.post(
    uri,
    headers: <String, String>{
      "Content-Type": "application/json"
    }
  );
}