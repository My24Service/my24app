import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import '../mixins.dart';

class PastListEmptyWidget extends BaseEmptyWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.past";
  final String? memberPicture;
  final OrderEventStatus fetchEvent;

  PastListEmptyWidget({
    Key? key,
    required this.fetchEvent,
    required this.memberPicture,
  }) : super(
    key: key,
      memberPicture: memberPicture
  );

  @override
  String getEmptyMessage() {
    return $trans('notice_no_order');
  }
}
