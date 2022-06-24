import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/interact/widgets/map.dart';

class MapPage extends StatefulWidget {
  MapPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('interact.map.app_bar_title'.tr())),
        body: MapWidget()
    );
  }
}
