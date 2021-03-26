import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import "package:flutter/services.dart";

import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'models.dart';
import 'utils.dart';


Future<LocationInventoryResults> fetchLocationProducts(http.Client client, int locationPk) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final url = await getUrl('/inventory/stock-location-inventory/list_full/?location=$locationPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return LocationInventoryResults.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load assigned order products');
}

Future<StockLocations> fetchLocations(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  final url = await getUrl('/inventory/stock-location/');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return StockLocations.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load locations');
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

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _onceGetLocations();
    await _fetchLocationProducts();
  }

  _onceGetLocations() async {
    _locations = await fetchLocations(http.Client());
    _location = _locations.results[0].name;
    _locationId = _locations.results[0].id;
    setState(() {});
  }

  _fetchLocationProducts() async {
    try {
      _locationProducts = await fetchLocationProducts(http.Client(), _locationId);
    } catch(e) {
      displayDialog(context, 'Error', 'Error fetching products');
    }
  }
  
  Widget _buildProductsTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('Product')
        ]),
        Column(children: [
          createTableHeaderCell('Identifier')
        ]),
        Column(children: [
          createTableHeaderCell('Amount')
        ]),
      ],
    ));

    // products
    for (int i = 0; i < _locationProducts.results.length; ++i) {
      LocationInventory locationInventory = _locationProducts.results[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${locationInventory.product.name}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${locationInventory.product.identifier}')
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
          Text('Location'),
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

              await _fetchLocationProducts();

              setState(() {
              });
            },
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Location inventory'),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    createHeader('Choose location'),
                    _buildForm(),
                    Divider(),
                    FutureBuilder<LocationInventoryResults>(
                      future: fetchLocationProducts(http.Client(), _locationId),
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return Container(
                              child: Center(
                                  child: Text("Loading...")
                              )
                          );
                        } else {
                          _locationProducts = snapshot.data;
                          return _buildProductsTable();
                        }
                      }
                    ),
                  ],
                ),
              ),
            ),
          )
        )
    );
  }
}