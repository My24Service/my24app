import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import "package:flutter/services.dart";
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';


Future<bool> deleteAssignedOrderMaterial(http.Client client, AssignedOrderMaterial material) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/mobile/assignedordermaterial/${material.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<AssignedOrderMaterials> fetchAssignedOrderMaterials(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedordermaterial/?assigned_order=$assignedorderPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return AssignedOrderMaterials.fromJson(json.decode(response.body));
  }

  throw Exception('assigned_orders.materials.exception_fetch'.tr());
}

Future<bool> storeAssignedOrderMaterial(http.Client client, AssignedOrderMaterial material) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final String token = newToken.token;
  final url = await getUrl('/mobile/assignedordermaterial/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'assigned_order': assignedorderPk,
    'material': material.material,
    'location': material.location,
    'material_name': material.materialName,
    'material_identifier': material.materialIdentifier,
    'amount': material.amount,
  };

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  if (response.statusCode == 201) {
    return true;
  }

  return false;
}

Future<StockLocations> fetchLocations(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/inventory/stock-location/');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return StockLocations.fromJson(json.decode(response.body));
  }

  throw Exception('assigned_orders.materials.exception_fetch_locations'.tr());
}


class AssignedOrderMaterialPage extends StatefulWidget {
  @override
  _AssignedOrderMaterialPageState createState() =>
      _AssignedOrderMaterialPageState();
}

class _AssignedOrderMaterialPageState extends State<AssignedOrderMaterialPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  InventoryMaterialTypeAheadModel _selectedMaterial;
  String _selectedMaterialName;
  StockLocations _locations;
  String _location;
  int _locationId;

  var _materialIdentifierController = TextEditingController();
  var _materialNameController = TextEditingController();
  var _materialAmountController = TextEditingController();

  AssignedOrderMaterials _assignedOrderMaterials;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _onceGetLocations();
  }

  _onceGetLocations() async {
    _locations = await fetchLocations(http.Client());
    _location = _locations.results[0].name;
    _locationId = _locations.results[0].id;
    setState(() {});
  }

  _doDelete(AssignedOrderMaterial material) async {
    setState(() {
      _saving = true;
    });

    bool result = await deleteAssignedOrderMaterial(http.Client(), material);

    // fetch and rebuild widgets
    if (result) {
      createSnackBar(context, 'assigned_orders.materials.snackbar_deleted'.tr());

      await fetchAssignedOrderMaterials(http.Client());
      setState(() {
        _saving = false;
      });
    }
  }

  _showDeleteDialog(AssignedOrderMaterial material, BuildContext context) {
    showDeleteDialog(
        'assigned_orders.materials.delete_dialog_title'.tr(),
        'assigned_orders.materials.delete_dialog_content'.tr(),
        context, () => _doDelete(material));
  }

  Widget _buildMaterialsTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('assigned_orders.materials.info_material'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.materials.info_identifier'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.materials.info_amount'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_delete'.tr())
        ])
      ],
    ));

    // materials
    for (int i = 0; i < _assignedOrderMaterials.results.length; ++i) {
      AssignedOrderMaterial material = _assignedOrderMaterials.results[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${material.materialName}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${material.materialIdentifier}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${material.amount}')
            ]
        ),
        Column(children: [
          IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(material, context);
              },
          )
        ]),
      ]));
    }

    return createTable(rows);
  }

  Widget _buildForm() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
                controller: this._typeAheadController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'assigned_orders.materials.typeahead_label_material'.tr())
                ),
            suggestionsCallback: (pattern) async {
              return await materialTypeAhead(http.Client(), pattern);
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion.value),
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (suggestion) {
              _selectedMaterial = suggestion;

              this._typeAheadController.text = _selectedMaterial.materialName;

              _materialIdentifierController.text =
                  _selectedMaterial.materialIdentifier;
              _materialNameController.text =
                  _selectedMaterial.materialName;

              // reload widgets
              setState(() {});
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'assigned_orders.materials.typeahead_validator_material'.tr();
              }

              return null;
            },
            onSaved: (value) => this._selectedMaterialName = value,
          ),

          SizedBox(
            height: 10.0,
          ),
          Text('assigned_orders.materials.info_material'.tr()),
          TextFormField(
              readOnly: true,
              controller: _materialNameController,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value.isEmpty) {
                  return 'assigned_orders.materials.validator_material'.tr();
                }
                return null;
              }
          ),

          SizedBox(
            height: 10.0,
          ),
          Text('assigned_orders.materials.info_location'.tr()),
          DropdownButtonFormField<String>(
            value: _location,
            items: _locations == null || _locations.results == null ? [] : _locations.results.map((
                StockLocation location) {
              return new DropdownMenuItem<String>(
                child: new Text(location.name),
                value: location.name,
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _location = newValue;

                StockLocation location = _locations.results.firstWhere(
                    (loc) => loc.name == newValue,
                    orElse: () => _locations.results.first
                );

                _locationId = location.id;
              });
            },
          ),

          SizedBox(
            height: 10.0,
          ),
          Text('assigned_orders.materials.info_identifier'.tr()),
          TextFormField(
              readOnly: true,
              controller: _materialIdentifierController,
              keyboardType: TextInputType.text,
              validator: (value) {
                return null;
              }
          ),

          SizedBox(
            height: 10.0,
          ),
          Text('assigned_orders.materials.info_amount'.tr()),
          TextFormField(
              controller: _materialAmountController,
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
              validator: (value) {
                if (value.isEmpty) {
                  return 'assigned_orders.materials.validator_amount'.tr();
                }
                return null;
              }
          ),

          SizedBox(
            height: 10.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
            child: Text('assigned_orders.materials.button_add_material'.tr()),
            onPressed: () async {
              if (this._formKey.currentState.validate()) {
                this._formKey.currentState.save();

                var amount = _materialAmountController.text;
                if (amount.contains(',')) {
                  amount = amount.replaceAll(new RegExp(r','), '.');
                }

                AssignedOrderMaterial material = AssignedOrderMaterial(
                    amount: double.parse(amount),
                    material: _selectedMaterial.id,
                    location: _locationId,
                    materialName: _selectedMaterial.materialName,
                    materialIdentifier: _selectedMaterial.materialIdentifier,
                );

                setState(() {
                  _saving = true;
                });

                bool result = await storeAssignedOrderMaterial(http.Client(), material);

                if (result) {
                  createSnackBar(context, 'assigned_orders.materials.snackbar_added'.tr());

                  // reset fields
                  _typeAheadController.text = '';
                  _materialAmountController.text = '';
                  _materialNameController.text = '';
                  _materialIdentifierController.text = '';

                  _assignedOrderMaterials = await fetchAssignedOrderMaterials(http.Client());

                  setState(() {
                    _saving = false;
                  });
                } else {
                  setState(() {
                    _saving = false;
                  });

                  displayDialog(context,
                    'generic.error_dialog_title'.tr(),
                    'assigned_orders.materials.error_dialog_content'.tr()
                  );
                }
              }
            },
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('assigned_orders.materials.app_bar_title'.tr()),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ModalProgressHUD(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      createHeader('assigned_orders.materials.header_new_material'.tr()),
                      _buildForm(),
                      Divider(),
                      FutureBuilder<AssignedOrderMaterials>(
                        future: fetchAssignedOrderMaterials(http.Client()),
                        // ignore: missing_return
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            Container(
                                child: Center(
                                    child: Text(
                                        'assigned_orders.materials.exception_fetch'.tr()
                                    )
                                )
                            );
                          }

                          if (snapshot.data == null) {
                            return Container(
                                child: Center(
                                    child: Text('generic.loading'.tr())
                                )
                            );
                          } else {
                            _assignedOrderMaterials = snapshot.data;
                            return _buildMaterialsTable();
                          }
                        }
                      ),
                    ],
                  ),
                ),
              ),
            )
          ), inAsyncCall: _saving)
        )
    );
  }
}
