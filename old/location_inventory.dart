import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';


Future<LocationInventoryResults> fetchLocationProducts(http.Client client, int locationPk) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/inventory/stock-location-inventory/list_full/?location=$locationPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return LocationInventoryResults.fromJson(json.decode(response.body));
  }

  throw Exception('location_inventory.exception_fetch_inventory'.tr());
}

Future<StockLocations> fetchLocations(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/inventory/stock-location/');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return StockLocations.fromJson(json.decode(response.body));
  }

  throw Exception('location_inventory.exception_fetch_locations'.tr());
}


class LocationInventoryPage extends StatefulWidget {
  @override
  _LocationInventoryPageState createState() =>
      _LocationInventoryPageState();
}

class _LocationInventoryPageState extends State<LocationInventoryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  StockLocations _locations;
  String _location;
  int _locationId;

  LocationInventoryResults _locationProducts;

  bool _inAsyncCall = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _onceGetLocations();
    await _doFetchLocationProducts();
  }

  _onceGetLocations() async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    try {
      _locations = await fetchLocations(http.Client());
      _location = _locations.results[0].name;
      _locationId = _locations.results[0].id;

      setState(() {
        _inAsyncCall = false;
      });
    } catch(e) {
      setState(() {
        _inAsyncCall = false;
        _error = true;
      });
    }
  }

  _doFetchLocationProducts() async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    try {
      _locationProducts = await fetchLocationProducts(http.Client(), _locationId);

      setState(() {
        _inAsyncCall = false;
      });
    } catch(e) {
      print('exception products $e');
      setState(() {
        _inAsyncCall = false;
        _error = true;
      });
    }
  }

  Widget _buildProductsTable() {
    if(_locationProducts.results.length == 0) {
      return buildEmptyListFeedback();
    }

    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('location_inventory.info_material'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('location_inventory.info_location'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('location_inventory.info_amount'.tr())
        ]),
      ],
    ));

    // products
    for (int i = 0; i < _locationProducts.results.length; ++i) {
      LocationInventory locationInventory = _locationProducts.results[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${locationInventory.material.name}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${locationInventory.material.identifier}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${locationInventory.amount}')
            ]
        ),
      ]));
    }

    return createTable(rows);
  }

  Widget _buildForm() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('location_inventory.info_location'.tr()),
          DropdownButtonFormField<String>(
            value: _location,
            items: _locations == null || _locations.results == null ? [] : _locations.results.map((
                StockLocation location) {
              return new DropdownMenuItem<String>(
                child: new Text(location.name),
                value: location.name,
              );
            }).toList(),
            onChanged: (newValue) async {
              StockLocation location = _locations.results.firstWhere(
                  (loc) => loc.name == newValue,
                  orElse: () => _locations.results.first
              );

              _location = newValue;
              _locationId = location.id;

              await _doFetchLocationProducts();

              setState(() {
              });
            },
          ),
        ],
      );
  }

  Widget _showMainView() {
    if (_error) {
      return RefreshIndicator(
        child: Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                Text('location_inventory.exception_fetch_locations'.tr())
              ],
            )
        ), onRefresh: () => _doFetchLocationProducts(),
      );
    }

    if (_locationProducts == null && _inAsyncCall) {
      return Center(child: CircularProgressIndicator());
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          createHeader('location_inventory.header_choose_location'.tr()),
          _buildForm(),
          Divider(),
          _buildProductsTable()
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('location_inventory.app_bar_title'.tr()),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Container(
              child: SingleChildScrollView(
                  child: _showMainView()
              ),
            ),
          )
        )
    );
  }
}
