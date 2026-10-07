import 'package:get/get.dart';

class NotificationModel {
  final String title;
  final String description;
  final String time;
  final NotificationType type;

  NotificationModel({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
  });
}

enum NotificationType { support, safety }

class NotificationController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[
    NotificationModel(
      title: "Support Request Submitted",
      description: "Your request for family counseling resources has been received. A coordinator will contact you within 24 hours.",
      time: "2 hours ago",
      type: NotificationType.support,
    ),
    NotificationModel(
      title: "Safety Plan Updated",
      description: "Your personalized safety plan has been updated with new emergency contacts and resources.",
      time: "1 week ago",
      type: NotificationType.safety,
    ),
  ].obs;

  void markAllAsRead() {
    // Logic for marking all as read
    Get.snackbar("Success", "All notifications marked as read");
  }
}
