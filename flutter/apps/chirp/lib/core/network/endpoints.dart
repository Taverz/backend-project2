abstract final class Endpoints {
  static const _base = '/api/v1';

  // auth
  static const login = '$_base/auth/login';
  static const register = '$_base/auth/register';
  static const logout = '$_base/auth/logout';
  static const refresh = '$_base/auth/refresh';

  // users
  static const profile = '$_base/users/me';
  static String userById(String id) => '$_base/users/$id';

  // tweets
  static const tweets = '$_base/tweets';
  static String tweetById(String id) => '$_base/tweets/$id';
  static String likeTweet(String id) => '$_base/tweets/$id/like';
  static String unlikeTweet(String id) => '$_base/tweets/$id/like';

  // timeline
  static const timeline = '$_base/timeline';

  // follow
  static String follow(String userId) => '$_base/users/$userId/follow';
  static String unfollow(String userId) => '$_base/users/$userId/follow';
  static String followers(String userId) => '$_base/users/$userId/followers';
  static String following(String userId) => '$_base/users/$userId/following';

  // search
  static const search = '$_base/search';

  // notifications
  static const notifications = '$_base/notifications';
}
