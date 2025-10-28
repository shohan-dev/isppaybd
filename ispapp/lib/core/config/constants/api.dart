// ignore_for_file: constant_identifier_names

class AppApi {
  static const String baseUrl = 'https://isppaybd.com/api/';

  // auth
  static const String login = '${baseUrl}validate';
  static const String dashboard = '${baseUrl}users';
  //   profile
  static const String profile =
      '${baseUrl}profile_update?name=Imam  Abu Sayid Tayebi updated&email=rajbari71@gmail.com&mobile=01715687024&address=1st floor, Staff quarter, Boropool, Rajbari Sadar, Rajbari.&user_id=21120';
  static const String rx_tx_data = '${baseUrl}users_load-traffic';
  static const String packages = '${baseUrl}packages?user_id=';
  static const String payment = '${baseUrl}payment_fetch?user_id=';
  // subscriptions
  static const String subscription =
      '${baseUrl}Subscription_index?role=user&user_id=';
  static const String subscriptionRenew =
      '${baseUrl}Subscription_renew/?role=user&package_id=41&customer=21120';

  // support tickets
  static const String supportTickets =
      '${baseUrl}Support_ticket_fetch?user_role=user&user_id=';
  static const String supportTicketDetails =
      '${baseUrl}ticket_details?user_role=user&ticket_id=';
  static const String supportTicketSendMessage =
      '${baseUrl}send_message?message=from api&current_user_id=806&ticket_id=20';
}
