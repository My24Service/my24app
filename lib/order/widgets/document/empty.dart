import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class OrderDocumentListEmptyWidget extends BaseEmptyWidget with OrderDocumentMixin, i18nMixin {
  final String basePath = "orders.documents";
  final String memberPicture;

  OrderDocumentListEmptyWidget({
    Key key,
    @required this.memberPicture,
  }) : super(
    key: key,
    memberPicture: memberPicture
  );

  @override
  String getEmptyMessage() {
    return $trans('notice_no_results');
  }
}
