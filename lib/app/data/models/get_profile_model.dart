import 'dart:convert';

/// =====================
/// GetProfile Response
/// =====================
class GetProfile {
  int? status;
  String? message;
  Map<String, dynamic>? errors;
  Data? data;

  GetProfile({this.status, this.message, this.errors, this.data});

  factory GetProfile.fromRawJson(String str) =>
      GetProfile.fromJson(json.decode(str));

  factory GetProfile.fromJson(Map<String, dynamic> json) => GetProfile(
    status: json['status'],
    message: json['message'],
    errors: json['errors'] as Map<String, dynamic>?,
    data: json['data'] == null ? null : Data.fromJson(json['data']),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'errors': errors,
    'data': data?.toJson(),
  };
}

/// =====================
/// Data
/// =====================
class Data {
  User? user;
  Location? location;

  Data({this.user, this.location});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: json['user'] == null ? null : User.fromJson(json['user']),
    location: json['location'] == null
        ? null
        : Location.fromJson(json['location']),
  );

  Map<String, dynamic> toJson() => {
    'user': user?.toJson(),
    'location': location?.toJson(),
  };
}

/// =====================
/// Location
/// =====================
class Location {
  double? longitude;
  double? latitude;

  Location({this.longitude, this.latitude});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    longitude: (json['longitude'] as num?)?.toDouble(),
    latitude: (json['latitude'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'longitude': longitude,
    'latitude': latitude,
  };
}

/// =====================
/// User
/// =====================
class User {
  int? userId;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  DateTime? dateOfBirth;
  String? gender;
  String? city;
  String? userRole;
  String? registrationMethod;
  String? languagePreference;

  User({
    this.userId,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.userRole,
    this.registrationMethod,
    this.languagePreference,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json['user_id'],
    username: json['username'],
    firstName: json['first_name'],
    lastName: json['last_name'],
    email: json['email'],
    phoneNumber: json['phone_number'],
    dateOfBirth: json['date_of_birth'] == null
        ? null
        : DateTime.parse(json['date_of_birth']),
    gender: json['gender'],
    city: json['city'],
    userRole: json['user_role'],
    registrationMethod: json['registration_method'],
    languagePreference: json['language_preference'],
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'username': username,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone_number': phoneNumber,
    'date_of_birth': dateOfBirth?.toIso8601String(),
    'gender': gender,
    'city': city,
    'user_role': userRole,
    'registration_method': registrationMethod,
    'language_preference': languagePreference,
  };
}
