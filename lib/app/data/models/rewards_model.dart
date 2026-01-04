// To parse this JSON data, do
//
//     final reward = rewardFromJson(jsonString);

import 'dart:convert';

Reward rewardFromJson(String str) => Reward.fromJson(json.decode(str));

String rewardToJson(Reward data) => json.encode(data.toJson());

class Reward {
    int? status;
    String? message;
    dynamic errors;
    Data? data;

    Reward({
        this.status,
        this.message,
        this.errors,
        this.data,
    });

    factory Reward.fromJson(Map<String, dynamic> json) => Reward(
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
    List<dynamic>? activeRewards;
    List<dynamic>? usedExpiredRewards;

    Data({
        this.activeRewards,
        this.usedExpiredRewards,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        activeRewards: json["active_rewards"] == null ? [] : List<dynamic>.from(json["active_rewards"]!.map((x) => x)),
        usedExpiredRewards: json["used_expired_rewards"] == null ? [] : List<dynamic>.from(json["used_expired_rewards"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "active_rewards": activeRewards == null ? [] : List<dynamic>.from(activeRewards!.map((x) => x)),
        "used_expired_rewards": usedExpiredRewards == null ? [] : List<dynamic>.from(usedExpiredRewards!.map((x) => x)),
    };
}
