import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/inventory/models/models.dart';
import 'package:my24app/inventory/api/inventory_api.dart';
import 'package:my24app/core/widgets/widgets.dart';


class LocationInventoryWidget extends StatefulWidget {
  @override
  _LocationInventoryPageState createState() =>
      _LocationInventoryPageState();
}

class _LocationInventoryPageState extends State<LocationInventoryWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  StockLocations _locations;
  List<LocationMaterialInventory> _locationProducts;
  String _location;
  int _locationId;

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
    try {
      _locations = await inventoryApi.fetchLocations();
      _location = _locations.results[0].name;
      _locationId = _locations.results[0].id;
      setState(() {});
    } catch(e) {
      print('exception locations $e');
    }
  }

  _doFetchLocationProducts() async {
    try {
      _locationProducts = await inventoryApi.searchLocationProducts(_locationId, '');

      setState(() {});
    } catch(e) {
      print('exception location products $e');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Container(
            child: SingleChildScrollView(
                child: _showMainView()
            ),
          ),
        )
    );
  }

  Widget _showMainView() {
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

  Widget _buildProductsTable() {
    if(_locationProducts == null || _locationProducts.length == 0) {
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
          createTableHeaderCell('location_inventory.info_identifier'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('location_inventory.info_amount'.tr())
        ]),
      ],
    ));

    // products
    for (int i = 0; i < _locationProducts.length; ++i) {
      LocationMaterialInventory locationInventory = _locationProducts[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${locationInventory.materialName}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${locationInventory.materialIdentifier}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${locationInventory.totalAmount}')
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

            setState(() {});
          },
        ),
      ],
    );
  }
}
