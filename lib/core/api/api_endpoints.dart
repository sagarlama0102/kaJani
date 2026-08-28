class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrlOnly = 'http://192.168.101.13:4000';

  static const String baseUrl = '$baseUrlOnly/api/';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String googleSignIn = 'auth/google';
  static const String whoAmI = 'auth/whoami';
  static const String userUploadPhoto = 'auth/update-profile';

  static const String getAllPlans = 'plans';
  static const String myPlans = 'plans/user/my-plans';
  static const String joinedPlans = 'plans/user/joined';
  static const String savedPlans = 'plans/user/saved';

  static const String uploadPlanCover = 'plans/upload-cover';

  static const String notifications = 'notifications';
  static const String unreadCount = 'notifications/unread-count';
  static const String markAllRead = 'notifications/mark-all-read';
  static const String clearAllNotifications = 'notifications/clear-all';
}
