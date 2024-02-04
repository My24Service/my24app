import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/core/i18n_mixin.dart';

class SalesUserCustomerListErrorWidget extends BaseErrorWidget with i18nMixin {
  final String basePath = "company.salesuser_customer";
  final String? memberPicture;
  final String? error;
  final CoreWidgets widgetsIn;

  SalesUserCustomerListErrorWidget({
    Key? key,
    required this.error,
    required this.memberPicture,
    required this.widgetsIn
  }) : super(
      key: key,
      error: error,
      memberPicture: memberPicture,
      widgetsIn: widgetsIn
  );

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }
}
