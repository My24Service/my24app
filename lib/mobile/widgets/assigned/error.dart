import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'mixins.dart';


class AssignedOrderListErrorWidget extends BaseErrorWidget with AssignedListMixin, i18nMixin {
  final String basePath = "assigned_orders.list";
  final String? error;
  final String? memberPicture;
  final CoreWidgets widgetsIn;

  AssignedOrderListErrorWidget({
    Key? key,
    required this.error,
    required this.memberPicture,
    required this.widgetsIn,
  }) : super(
      key: key,
      error: error,
      memberPicture: memberPicture,
      widgetsIn: widgetsIn
  );
}
