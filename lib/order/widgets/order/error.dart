import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class OrderListErrorWidget extends BaseErrorWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.list";
  final String error;

  OrderListErrorWidget({
    Key key,
    @required this.error
  }) : super(
      key: key,
      error: error
  );
}
