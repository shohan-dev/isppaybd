// ignore_for_file: constant_identifier_names

class AppApi {
  static const String baseUrl = 'https://isppaybd.com/api/';

  // auth
  static const String login = '${baseUrl}validate';
  static const String dashboard = '${baseUrl}users';
  static const String rx_tx_data = '${baseUrl}users_load-traffic';
  static const String packages = '${baseUrl}packages?user_id=';
  static const String payment = '${baseUrl}payment_fetch?user_id=';
}
