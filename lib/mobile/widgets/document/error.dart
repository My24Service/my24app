import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'mixins.dart';


class DocumentListErrorWidget extends BaseErrorWidget with DocumentMixin, i18nMixin {
  final String basePath = "assigned_orders.documents";
  final String? error;
  final String? memberPicture;
  final CoreWidgets widgetsIn;

  DocumentListErrorWidget({
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
