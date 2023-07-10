import 'dart:io' show Platform;
import 'package:easy_localization/easy_localization.dart';

getTranslationTr(String path, Map<String, String>? namedArgs) {
  final Map<String, String> envVars = Platform.environment;
  if (envVars['TESTING'] != null) {
    return "bla";
  }

  if (namedArgs == null) {
    namedArgs = {};
  }

  return "$path".tr(namedArgs: namedArgs);
}

mixin i18nMixin {
  final String basePath = "generic";

  String $trans(String key, {Map<String, String>? namedArgs, String? pathOverride}) {
    if (pathOverride != null) {
      return getTranslationTr("$pathOverride.$key", namedArgs);
    }

    return getTranslationTr("$basePath.$key", namedArgs);
  }
}
