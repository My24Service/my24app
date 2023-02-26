import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class MaterialListEmptyWidget extends BaseEmptyWidget with MaterialMixin, i18nMixin {
  final String basePath = "assigned_orders.materials";

  MaterialListEmptyWidget({
    Key key,
  }) : super(
    key: key,
  );

  @override
  String getEmptyMessage() {
    return $trans('notice_no_results');
  }
}