import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/inventory/widgets/location_inventory.dart';

class LocationInventoryPage extends StatefulWidget {
  LocationInventoryPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _LocationInventoryPageState();
}

class _LocationInventoryPageState extends State<LocationInventoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('location_inventory.app_bar_title'.tr())),
        body: LocationInventoryWidget()
    );
  }
}
