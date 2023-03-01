import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class PastListErrorWidget extends BaseErrorWidget with PastListMixin, i18nMixin {
  final String basePath = "orders.past";
  final String error;

  PastListErrorWidget({
    Key key,
    @required this.error,
  }) : super(
    key: key,
    error: error
  );
}
