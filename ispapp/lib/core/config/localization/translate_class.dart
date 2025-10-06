// Translation class to manage languages
import 'package:get/get.dart';
import 'package:ispapp/core/config/localization/bd.dart';
import 'package:ispapp/core/config/localization/eng.dart';

class MyTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'English': enUS,
    'Bengal': bnBD,
  };
}
