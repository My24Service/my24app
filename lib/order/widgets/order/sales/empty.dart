import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import '../mixins.dart';


class SalesListEmptyWidget extends BaseEmptyWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.sales";
  final String memberPicture;

  SalesListEmptyWidget({
    Key key,
    @required this.memberPicture,
  }) : super(
    key: key,
    memberPicture: memberPicture
  );

  @override
  String getEmptyMessage() {
    return $trans('notice_no_order');
  }
}
