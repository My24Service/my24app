import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/inventory/models/models.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/inventory/api/inventory_api.dart';
import 'package:my24app/mobile/api/mobile_api.dart';

class MaterialWidget extends StatefulWidget {
  final AssignedOrderMaterials materials;
  final int assignedOrderPk;

  MaterialWidget({Key key, this.materials, this.assignedOrderPk})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new _MaterialWidgetState(
      materials: materials, assignedOrderPk: assignedOrderPk);
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
  int _selectedMaterialId;
  int _editId;
  String _editMaterialName;
  String _editMaterialIdentifier;

  var _materialIdentifierController = TextEditingController();
  var _materialNameController = TextEditingController();
  var _materialAmountController = TextEditingController();

  bool _inAsyncCall = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(child: _showMainView(), inAsyncCall: _inAsyncCall);
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
                      createHeader(
                          'assigned_orders.materials.header_new_material'.tr()),
                      _buildForm(),
                      Divider(),
                      createHeader(
                          'assigned_orders.materials.info_header_table'.tr()),
                      _buildMaterialsTable(),
                    ])))));
  }

  _doDelete(AssignedOrderMaterial material) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
    bloc.add(
        MaterialEvent(status: MaterialEventStatus.DELETE, value: material.id));
  }

  _showDeleteDialog(AssignedOrderMaterial material, BuildContext context) {
    showDeleteDialogWrapper(
        'assigned_orders.materials.delete_dialog_title'.tr(),
        'assigned_orders.materials.delete_dialog_content'.tr(),
        context,
        () => _doDelete(material));
  }

  _fillFormForEdit(AssignedOrderMaterial material, BuildContext context) {
    _selectedMaterial = null;
    _selectedMaterialId = material.material;
    _editId = material.id;
    _materialNameController.text = material.materialName;
    _materialIdentifierController.text = material.materialIdentifier;
    _materialAmountController.text = material.amount.toString();
    _editMaterialName = material.materialName;
    _editMaterialIdentifier = material.materialIdentifier;
    setState(() {});
  }

  Widget _buildMaterialsTable() {
    if (materials.results.length == 0) {
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
          createTableHeaderCell(
              'assigned_orders.materials.info_identifier'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.materials.info_amount'.tr())
        ]),
        Column(children: [createTableHeaderCell('generic.action_delete'.tr())]),
        Column(children: [createTableHeaderCell('generic.action_edit'.tr())])
      ],
    ));

    // materials
    for (int i = 0; i < materials.results.length; ++i) {
      AssignedOrderMaterial material = materials.results[i];

      rows.add(TableRow(children: [
        Column(children: [createTableColumnCell('${material.materialName}')]),
        Column(children: [
          createTableColumnCell('${material.materialIdentifier}')
        ]),
        Column(children: [createTableColumnCell('${material.amount}')]),
        Column(children: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteDialog(material, context);
            },
          )
        ]),
        Column(children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.green),
            onPressed: () {
              _fillFormForEdit(material, context);
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
                  labelText:
                      'assigned_orders.materials.typeahead_label_material'
                          .tr())),
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
            _materialNameController.text = _selectedMaterial.materialName;

            // rebuild widgets
            setState(() {});
          },
          validator: (value) {
            if (_editId == null && value.isEmpty) {
              return 'assigned_orders.materials.typeahead_validator_material'
                  .tr();
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
            }),
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
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('assigned_orders.materials.info_amount'.tr()),
        TextFormField(
            controller: _materialAmountController,
            keyboardType:
                TextInputType.numberWithOptions(signed: false, decimal: true),
            validator: (value) {
              if (value.isEmpty) {
                return 'assigned_orders.materials.validator_amount'.tr();
              }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
          ),
          child: Text(_editId == null
              ? 'assigned_orders.materials.button_add_material'.tr()
              : 'assigned_orders.materials.button_update_material'.tr()),
          onPressed: () async {
            if (this._formKey.currentState.validate()) {
              this._formKey.currentState.save();

              var amount = _materialAmountController.text;
              if (amount.contains(',')) {
                amount = amount.replaceAll(new RegExp(r','), '.');
              }

              int materialId;
              String materialName;
              String materialIdentifier;

              if (_editId != null) {
                if (_selectedMaterial != null) {
                  materialId = _selectedMaterial.id;
                  materialName = _selectedMaterial.materialName;
                  materialIdentifier = _selectedMaterial.materialIdentifier;
                } else {
                  materialId = _selectedMaterialId;
                  materialName = _editMaterialName;
                  materialIdentifier = _editMaterialIdentifier;
                }
              } else {
                materialId = _selectedMaterial.id;
                materialName = _selectedMaterial.materialName;
                materialIdentifier = _selectedMaterial.materialIdentifier;
              }

              AssignedOrderMaterial material = AssignedOrderMaterial(
                id: _editId,
                amount: double.parse(amount),
                material: materialId,
                materialName: materialName,
                materialIdentifier: materialIdentifier,
              );

              setState(() {
                _inAsyncCall = true;
              });

              final bloc = BlocProvider.of<MaterialBloc>(context);

              // insert?
              if (_editId == null) {
                final AssignedOrderMaterial newMaterial = await mobileApi
                    .insertAssignedOrderMaterial(material, assignedOrderPk);

                if (newMaterial == null) {
                  displayDialog(
                      context,
                      'generic.error_dialog_title'.tr(),
                      'assigned_orders.materials.error_dialog_content_add'
                          .tr());
                } else {
                  bloc.add(MaterialEvent(status: MaterialEventStatus.INSERTED));
                }
              } else {
                final bool result = await mobileApi.updateAssignedOrderMaterial(
                    material, assignedOrderPk);

                if (result) {
                  bloc.add(MaterialEvent(status: MaterialEventStatus.UPDATED));
                } else {
                  displayDialog(
                      context,
                      'generic.error_dialog_title'.tr(),
                      'assigned_orders.materials.error_dialog_content_update'
                          .tr());
                }
              }

              _editId = null;
              _inAsyncCall = false;
              setState(() {});
            }
          },
        ),
      ],
    );
  }
}
