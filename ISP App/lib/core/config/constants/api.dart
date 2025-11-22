// ignore_for_file: constant_identifier_names

class AppApi {
  static const String baseUrl = 'https://isppaybd.com/api/';

  // auth
  static const String login = '${baseUrl}validate';
  static const String dashboard = '${baseUrl}users';

  // profile
  static const String profileUpdate = '${baseUrl}profile_update';

  // traffic data
  static const String rx_tx_data = '${baseUrl}users_load-traffic';
  static const String packages = '${baseUrl}packages?user_id=';
  static const String payment = '${baseUrl}payment_fetch?user_id=';
  // subscriptions
  static const String subscription =
      '${baseUrl}subscription_index?role=user&user_id=';
  static const String subscriptionRenew = '${baseUrl}subscription_renew/';

  // support tickets
  static const String supportTickets =
      '${baseUrl}support_ticket_fetch?user_role=user&user_id=';
  static const String supportTicketDetails =
      '${baseUrl}ticket_details?user_role=user&ticket_id=';
  static const String supportTicketSendMessage =
      '${baseUrl}send_message?message=from api&current_user_id=806&ticket_id=20';
  static const String createTicket = '${baseUrl}create_ticket';

  // ping test
  static const String pingUser = '${baseUrl}pingUserApi';
  // user data usage
  static const String getUserDataUsage = '${baseUrl}get_user_data_usage';
}
