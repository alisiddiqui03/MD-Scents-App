// To parse this JSON data, do
//
//     final authModel = authModelFromJson(jsonString);

import 'dart:convert';

AuthModel authModelFromJson(String str) => AuthModel.fromJson(json.decode(str));

String authModelToJson(AuthModel data) => json.encode(data.toJson());

class AuthModel {
  int? status;
  String? message;
  dynamic errors;
  Data? data;

  AuthModel({this.status, this.message, this.errors, this.data});

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    status: json["status"],
    message: json["message"],
    errors: json["errors"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "errors": errors,
    "data": data?.toJson(),
  };
}

class Data {
  UserData? userData;
  Token? token;

  Data({this.userData, this.token});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userData: json["user_data"] == null
        ? null
        : UserData.fromJson(json["user_data"]),
    token: json["token"] == null ? null : Token.fromJson(json["token"]),
  );

  Map<String, dynamic> toJson() => {
    "user_data": userData?.toJson(),
    "token": token?.toJson(),
  };
}

class Token {
  String? accessToken;
  String? refreshToken;

  Token({this.accessToken, this.refreshToken});

  factory Token.fromJson(Map<String, dynamic> json) => Token(
    accessToken: json["access_token"],
    refreshToken: json["refresh_token"],
  );

  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "refresh_token": refreshToken,
  };
}

class UserData {
  dynamic username;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? userRole;
  String? registrationMethod;
  bool? isActive;

  UserData({
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.userRole,
    this.registrationMethod,
    this.isActive,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    username: json["username"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    phoneNumber: json["phone_number"],
    userRole: json["user_role"],
    registrationMethod: json["registration_method"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone_number": phoneNumber,
    "user_role": userRole,
    "registration_method": registrationMethod,
    "is_active": isActive,
  };
}
