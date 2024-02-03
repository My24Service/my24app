import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class OrderDocumentListErrorWidget extends BaseErrorWidget with OrderDocumentMixin, i18nMixin {
  final String basePath = "orders.documents";
  final String? error;
  final String? memberPicture;
  final int? orderId;

  OrderDocumentListErrorWidget({
    Key? key,
    required this.error,
    required this.memberPicture,
    required this.orderId,
  }) : super(
      key: key,
      error: error,
      memberPicture: memberPicture
  );
}
