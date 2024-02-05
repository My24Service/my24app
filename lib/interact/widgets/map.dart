import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/company/models/models.dart';
import 'package:my24app/company/api/company_api.dart';

class MapWidget extends StatefulWidget {
  @override
  _LocationInventoryPageState createState() =>
      _LocationInventoryPageState();
}

class _LocationInventoryPageState extends State<MapWidget> {
  List<Marker> allMarkers = [];
  LastLocations? lastLocations;
  LastLocation? selectedLocation;
  bool drawerOpen = false;
  final CoreWidgets widgets = CoreWidgets();

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _onceGetPositions();
  }

  _markerClicked(LastLocation location) {
    print('${location.name}: location: ${location.lastAssignedOrder!.orderName} clicked');
    drawerOpen = true;
    selectedLocation = location;
    setState(() {
    });
  }

  _onceGetPositions() async {
    lastLocations = await companyApi.fetchEngineersLastLocations();
    // } catch(e) {
    //   print('error fetching last locations: $e');
    // }

    if (lastLocations == null) {
      return;
    }

    for (int i=0; i<lastLocations!.locations!.length; i++) {
      if (lastLocations!.locations![i].latLon == null) {
        print('value null. continue');
        continue;
      }
      print('Adding marker');

      allMarkers.add(
        Marker(
          point: lastLocations!.locations![i].latLon!,
          builder: (context) => GestureDetector(
            onTap: () {
              _markerClicked(lastLocations!.locations![i]);
            },
            child: Icon(
              Icons.circle,
              color: Colors.red,
              size: 20.0,
            ),
          ),
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SingleChildScrollView(
              child: _showMainView()
          ),
        );
  }

  Widget _engineerInfo() {
    if (selectedLocation == null) {
      return SizedBox(width: 1);
    }

    return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          widgets.createHeader(selectedLocation!.name!),
          Table(
            children: [
              TableRow(
                children: [
                  Text('interact.map.last_order_name'.tr(),
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  Text(selectedLocation!.lastAssignedOrder!.orderName!),
                ]
              ),
              TableRow(
                  children: [
                    Text('interact.map.last_order_address'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text(selectedLocation!.lastAssignedOrder!.orderAddress!),
                  ]
              ),
              TableRow(
                  children: [
                    Text('interact.map.last_order_city'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text(selectedLocation!.lastAssignedOrder!.orderCity!),
                  ]
              ),
              TableRow(
                  children: [
                    Text('interact.map.last_order_status'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text(selectedLocation!.lastAssignedOrder!.lastStatusFull!),
                  ]
              ),
            ]
          )
        ]
    );

  }

  Widget _showMainView() {
    return Stack(
      children: [
        Positioned(
          child: Container(
                height: 680,
                // width: 100,
                child: FlutterMap(
                  // options: MapOptions(
                  //   bounds: LatLngBounds(lastLocations.locations[0].latLon, lastLocations.locations[1].latLon),
                  //   boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(8.0)),
                  // ),
                  options: MapOptions(
                    center: LatLng(52.092876, 5.104480),
                    zoom: 7.0,
                    minZoom: 3.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: allMarkers)
                  ],
            ),
          ),
        ),
        AnimatedPositioned(
          width: 400,
          // width: drawerOpen ? 200.0 : 50.0,
          height: drawerOpen ? 170.0 : 10.0,
          // top: drawerOpen ? 50.0 : 150.0,
          bottom: 0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.fastOutSlowIn,
          child: GestureDetector(
            onTap: () {
              setState(() {
                drawerOpen = !drawerOpen;
              });
            },
            child: Container(
              color: Colors.white,
              child: _engineerInfo(),
            ),
          ),
        ),

      ]
    );
  }
}
