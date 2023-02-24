import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'mixins.dart';


class MaterialListErrorWidget extends BaseErrorWidget with MaterialMixin {
  final String error;

  MaterialListErrorWidget({
    Key key,
    @required this.error
  }) : super(
      key: key,
      error: error
  );

  @override
  String getAppBarSubtitle(BuildContext context) {
    return "";
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return 'assigned_orders.materials.app_bar_title'.tr();
  }
}
