import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'mixins.dart';

class OrderDocumentListErrorWidget extends BaseErrorWidget with OrderDocumentMixin {
  final String? error;
  final String? memberPicture;
  final int? orderId;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  OrderDocumentListErrorWidget({
    Key? key,
    required this.error,
    required this.memberPicture,
    required this.orderId,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
      key: key,
      error: error,
      memberPicture: memberPicture,
      widgetsIn: widgetsIn,
      i18nIn: i18nIn
  );
}
