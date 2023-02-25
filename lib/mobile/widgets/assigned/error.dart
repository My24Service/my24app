import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class AssignedOrderListErrorWidget extends BaseErrorWidget with AssignedListMixin, i18nMixin {
  final String basePath = "assigned_orders.list";
  final String error;

  AssignedOrderListErrorWidget({
    Key key,
    @required this.error
  }) : super(
      key: key,
      error: error
  );
}
