// ignore_for_file: constant_identifier_names

class AppApi {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  // static const String baseUrl = 'http://localhost:3000/api';

  // auth
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String validate_token = '/auth/validate-token';

  // user
  static const String user_profile = '/profile/me';

  // post
  static const String post = '/post';
  static const String post_Search = '/post/search';
  // post like
  static const String post_like = '/post/like';
  // post comment
  static const String post_comment = '/post/comment';

}
