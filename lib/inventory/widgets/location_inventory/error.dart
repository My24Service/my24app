import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class LocationInventoryListErrorWidget extends BaseErrorWidget with LocationInventoryMixin, i18nMixin {
  final String basePath = "location_inventory";
  final String? error;
  final String? memberPicture;

  LocationInventoryListErrorWidget({
    Key? key,
    required this.error,
    required this.memberPicture,
  }) : super(
      key: key,
      error: error,
      memberPicture: memberPicture
  );
}
