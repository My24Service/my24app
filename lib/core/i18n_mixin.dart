import 'package:easy_localization/easy_localization.dart';

mixin i18nMixin {
  final String basePath = "general";

  String $trans(String key, {Map<String, String> namedArgs, String pathOverride}) {
    if (pathOverride != null) {
      return "$pathOverride.$key".tr(namedArgs: namedArgs);
    }

    return "$basePath.$key".tr(namedArgs: namedArgs);
  }
}
