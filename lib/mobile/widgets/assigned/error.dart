import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'mixins.dart';


class AssignedOrderListErrorWidget extends BaseErrorWidget with AssignedListMixin {
  final String error;

  AssignedOrderListErrorWidget({
    Key key,
    @required this.error
  }) : super(
      key: key,
      error: error
  );
}
