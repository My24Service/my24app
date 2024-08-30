import 'package:flutter/material.dart';

import 'location/models.dart';

class LocationInventoryPageData {
  final StockLocations locations;
  final String? memberPicture;
  final Widget? drawer;

  LocationInventoryPageData({
    required this.locations,
    required this.memberPicture,
    required this.drawer,
  });
}


