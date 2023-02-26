import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class MaterialListErrorWidget extends BaseErrorWidget with MaterialMixin, i18nMixin {
  final String basePath = "assigned_orders.materials";
  final String error;

  MaterialListErrorWidget({
    Key key,
    @required this.error
  }) : super(
      key: key,
      error: error
  );
}