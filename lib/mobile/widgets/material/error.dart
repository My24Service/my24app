import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class MaterialListErrorWidget extends BaseErrorWidget with MaterialMixin, i18nMixin {
  final String basePath = "assigned_orders.materials";
  final String? error;
  final String? memberPicture;
  final CoreWidgets widgetsIn;

  MaterialListErrorWidget({
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
