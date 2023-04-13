import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class CustomerListErrorWidget extends BaseErrorWidget with CustomerMixin, i18nMixin {
  final String basePath = "assigned_orders.activity";
  final String memberPicture;
  final String error;

  CustomerListErrorWidget({
    Key key,
    @required this.error,
    @required this.memberPicture,
  }) : super(
      key: key,
      error: error,
      memberPicture: memberPicture
  );
}
