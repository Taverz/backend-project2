abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';

  // Shell tabs
  static const home = '/home';
  static const search = '/search';
  static const notifications = '/notifications';
  static const profile = '/profile';

  // Full-screen over shell
  static const createTweet = '/create';
  static String tweetDetail(String id) => '/tweet/$id';
  static String userProfile(String id) => '/user/$id';
  static String userFollowers(String id) => '/user/$id/followers';
  static String userFollowing(String id) => '/user/$id/following';
}
