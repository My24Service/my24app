import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import '../mixins.dart';

class PastListErrorWidget extends BaseErrorWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.past";
  final String? error;
  final OrderPageMetaData orderPageMetaData;
  final OrderEventStatus fetchEvent;
  final CoreWidgets widgetsIn;

  PastListErrorWidget({
    Key? key,
    required this.error,
    required this.fetchEvent,
    required this.orderPageMetaData,
    required this.widgetsIn,
  }) : super(
    key: key,
    error: error,
    memberPicture: orderPageMetaData.memberPicture,
    widgetsIn: widgetsIn
  );
}
