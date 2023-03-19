import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';
import '../mixins.dart';


class PastListErrorWidget extends BaseErrorWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.past";
  final String error;
  final OrderPageMetaData orderPageMetaData;

  PastListErrorWidget({
    Key key,
    @required this.error,
    @required this.orderPageMetaData,
  }) : super(
    key: key,
    error: error
  );
}
