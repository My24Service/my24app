import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';
import '../mixins.dart';


class SalesListErrorWidget extends BaseErrorWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.sales";
  final String error;
  final OrderPageMetaData orderPageMetaData;

  SalesListErrorWidget({
    Key key,
    @required this.error,
    @required this.orderPageMetaData,
  }) : super(
      key: key,
      error: error
  );
}
