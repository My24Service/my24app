import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import '../mixins.dart';

class PastListErrorWidget extends BaseErrorWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.past";
  final String? error;
  final OrderPageMetaData orderPageMetaData;
  final OrderEventStatus fetchEvent;

  PastListErrorWidget({
    Key? key,
    required this.error,
    required this.fetchEvent,
    required this.orderPageMetaData,
  }) : super(
    key: key,
    error: error,
    memberPicture: orderPageMetaData.memberPicture
  );
}
