import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/inventory/models/models.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/inventory/api/inventory_api.dart';

class MaterialWidget extends StatefulWidget {
  final AssignedOrderMaterials materials;
  final int assignedOrderPk;

  MaterialWidget({
    Key key,
    this.materials,
    this.assignedOrderPk
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _MaterialWidgetState(
      materials: materials,
      assignedOrderPk: assignedOrderPk
  );
}

class _MaterialWidgetState extends State<MaterialWidget> {
  final AssignedOrderMaterials materials;
  final int assignedOrderPk;

  _MaterialWidgetState({
    @required this.materials,
    @required this.assignedOrderPk,
  }) : super();

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

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _onceGetLocations();
  }

  _onceGetLocations() async {
    _locations = await inventoryApi.fetchLocations();
    _location = _locations.results[0].name;
    _locationId = _locations.results[0].id;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _showMainView();
  }

  Widget _showMainView() {
    return Container(
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
                          createHeader('assigned_orders.materials.info_header_table'.tr()),
                          _buildMaterialsTable(),
                        ]
                    )
                )
            )
        )
    );
  }

  _doDelete(AssignedOrderMaterial material) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
    bloc.add(MaterialEvent(
        status: MaterialEventStatus.DELETE, value: material.id));
  }

  _showDeleteDialog(AssignedOrderMaterial material, BuildContext context) {
    showDeleteDialogWrapper(
        'assigned_orders.materials.delete_dialog_title'.tr(),
        'assigned_orders.materials.delete_dialog_content'.tr(),
        context, () => _doDelete(material));
  }

  Widget _buildMaterialsTable() {
    if(materials.results.length == 0) {
      return buildEmptyListFeedback();
    }

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
    for (int i = 0; i < materials.results.length; ++i) {
      AssignedOrderMaterial material = materials.results[i];

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
            return await inventoryApi.materialTypeAhead(pattern);
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

            // rebuild widgets
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
              // if (value.isEmpty) {
              //   return 'assigned_orders.materials.validator_material'.tr();
              // }
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

              dynamic materialPk;
              String materialName = '';
              String materialIdentifier = '';

              if (_selectedMaterial == null) {
                await displayDialog(
                  context,
                  'Material not found',
                  'This material will only be stored by it\'s name'
                );
                // create new material?
                materialName = this._typeAheadController.text;
                return;
              } else {
                materialPk = _selectedMaterial.id;
                materialName = _selectedMaterial.materialName;
                materialIdentifier = _selectedMaterial.materialIdentifier;
              }

              AssignedOrderMaterial material = AssignedOrderMaterial(
                amount: double.parse(amount),
                material: materialPk,
                location: _locationId,
                materialName: materialName,
                materialIdentifier: materialIdentifier,
              );

              final bloc = BlocProvider.of<MaterialBloc>(context);

              bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
              bloc.add(MaterialEvent(
                status: MaterialEventStatus.INSERT,
                value: assignedOrderPk,
                material: material,
              ));
            }
          },
        ),
      ],
    );
  }
}
