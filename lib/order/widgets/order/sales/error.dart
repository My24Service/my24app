import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/order/models/order/models.dart';
import '../mixins.dart';

class SalesListErrorWidget extends BaseErrorWidget with OrderListMixin {
  final String? error;
  final OrderPageMetaData orderPageMetaData;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  SalesListErrorWidget({
    Key? key,
    required this.error,
    required this.orderPageMetaData,
    required this.widgetsIn,
    required this.i18nIn
  }) : super(
      key: key,
      error: error,
      memberPicture: orderPageMetaData.memberPicture,
      widgetsIn: widgetsIn,
      i18nIn: i18nIn
  );
}
