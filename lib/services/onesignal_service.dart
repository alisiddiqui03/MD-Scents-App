import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../core/constants/app_constants.dart';

/// Push registration + OneSignal REST notifications.
///
/// Admin new-order alerts use [admin_push_targets] because clients cannot
/// `where('role' == 'admin')` on [users] under current Firestore rules.
class OneSignalService {
  OneSignalService._();

  static const _adminTargetsCollection = 'admin_push_targets';

  /// Clear OneSignal user association when Firebase signs out.
  static Future<void> signOutCleanup() async {
    try {
      await OneSignal.logout();
    } catch (e, st) {
      debugPrint('OneSignal signOutCleanup: $e\n$st');
    }
  }

  /// Call after every successful login (email, Google, link).
  static Future<void> savePlayerIdToFirestore(String userId) async {
    try {
      final playerId = OneSignal.User.pushSubscription.id;
      if (playerId == null || playerId.isEmpty) {
        debugPrint('savePlayerId: subscription id not ready yet');
        return;
      }

      final fs = FirebaseFirestore.instance;
      final userRef = fs.collection('users').doc(userId);
      await userRef.set({
        'oneSignalPlayerId': playerId,
      }, SetOptions(merge: true));

      final snap = await userRef.get();
      final role = snap.data()?['role'] as String? ?? 'user';
      if (role == 'admin') {
        await fs.collection(_adminTargetsCollection).doc(userId).set({
          'oneSignalPlayerId': playerId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e, st) {
      debugPrint('savePlayerId error: $e\n$st');
    }
  }

  /// Notify all admins who have registered a player id (see [savePlayerIdToFirestore]).
  static Future<void> notifyAdmin(String orderId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(_adminTargetsCollection)
          .get();

      if (snap.docs.isEmpty) return;

      final short = orderId.length > 6 ? orderId.substring(0, 6) : orderId;
      for (final d in snap.docs) {
        final pid = d.data()['oneSignalPlayerId'] as String?;
        if (pid == null || pid.isEmpty) continue;
        await _sendNotification(
          playerId: pid,
          title: 'New Order Received!',
          body: 'A new order #$short has been placed',
          data: {'type': 'new_order', 'orderId': orderId},
        );
      }
    } catch (e, st) {
      debugPrint('notifyAdmin error: $e\n$st');
    }
  }

  /// Notify the customer when order status changes (admin).
  static Future<void> notifyUser({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final playerId = userDoc.data()?['oneSignalPlayerId'] as String?;
      if (playerId == null || playerId.isEmpty) return;

      var title = 'Order Update';
      var body = 'Your order status has been updated to: $status';

      switch (status) {
        case 'cancelled':
          title = 'Order Cancelled';
          body = 'Your order #$orderId has been cancelled';
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('orders')
              .doc(orderId)
              .update({'cancellationUnreadForUser': true});
          break;
        case 'delivered':
          title = 'Order Delivered!';
          body = 'Your order #$orderId has been delivered';
          _scheduleReviewReminder(playerId: playerId, orderId: orderId);
          break;
        case 'processing':
          title = 'Order Processing';
          body = 'Your order #$orderId is being processed';
          break;
        case 'packed':
          title = 'Order Packed';
          body = 'Your order #$orderId has been packed';
          break;
        case 'shipped':
          title = 'Order Shipped';
          body = 'Your order #$orderId is on the way';
          break;
        case 'pending':
          title = 'Order Received';
          body = 'Your order #$orderId is pending confirmation';
          break;
        default:
          break;
      }

      await _sendNotification(
        playerId: playerId,
        title: title,
        body: body,
        data: {'type': 'order_update', 'orderId': orderId, 'status': status},
      );
    } catch (e, st) {
      debugPrint('notifyUser error: $e\n$st');
    }
  }

  static Future<void> _scheduleReviewReminder({
    required String playerId,
    required String orderId,
  }) async {
    final expiryTime = DateTime.now().add(const Duration(days: 6, hours: 23));
    // OneSignal string format: "2015-09-24 14:00:00 GMT-0700"
    // We can use simple UTC string "2023-11-20 14:00:00 UTC"
    final sendAfterStr = '${expiryTime.toUtc().toString().split('.').first} UTC';

    await _sendNotification(
      playerId: playerId,
      title: 'Review Reward Expiring Soon! ⏳',
      body: 'You have only a few hours left to submit a picture review for order #$orderId and claim your 250 PKR wallet reward!',
      data: {'type': 'review_reminder', 'orderId': orderId},
      sendAfter: sendAfterStr,
    );
  }

  static Future<void> _sendNotification({
    required String playerId,
    required String title,
    required String body,
    required Map<String, String> data,
    String? sendAfter,
  }) async {
    try {
      final payload = <String, dynamic>{
        'app_id': oneSignalAppId,
        'include_player_ids': [playerId],
        'headings': {'en': title},
        'contents': {'en': body},
        'data': data,
      };

      if (sendAfter != null) {
        payload['send_after'] = sendAfter;
      }

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          // OneSignal REST API keys (os_v2_…) use the Key scheme.
          'Authorization': 'Key ${dotenv.env['ONESIGNAL_REST_API_KEY']}',
        },
        body: jsonEncode(payload),
      );
      debugPrint('OneSignal response: ${response.statusCode} ${response.body}');
    } catch (e, st) {
      debugPrint('_sendNotification error: $e\n$st');
    }
  }
}
