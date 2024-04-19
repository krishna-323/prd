import 'dart:convert';

abstract class StaticData {
/// Production System
  static String username = 'INTEGRATION';
  static String password = 'rXnDqEpDv2WlWYahKnEGo)mwREoCafQNorwoDpLl';
  static String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
  static String apiURL ='Https://JMIApp-terrific-eland-ao.cfapps.in30.hana.ondemand.com/api/sap_odata_get/PRD';
  static String apiPostURL ='Https://JMIApp-terrific-eland-ao.cfapps.in30.hana.ondemand.com/api/sap_odata_post/PRD';
}