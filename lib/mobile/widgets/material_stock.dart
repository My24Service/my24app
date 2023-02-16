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

class MaterialStockWidget extends StatefulWidget {
  final AssignedOrderMaterials materials;
  final int assignedOrderPk;

  MaterialStockWidget({Key key, this.materials, this.assignedOrderPk})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new _MaterialStockWidgetState(
      materials: materials, assignedOrderPk: assignedOrderPk);
}

class _MaterialStockWidgetState extends State<MaterialStockWidget> {
  final AssignedOrderMaterials materials;
  final int assignedOrderPk;

  _MaterialStockWidgetState({
    @required this.materials,
    @required this.assignedOrderPk,
  }) : super();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  LocationMaterialInventory _selectedMaterial;
  String _selectedMaterialName;
  int _selectedMaterialId;
  StockLocations _locations;
  String _location;
  int _locationId;
  int _editId;
  String _editMaterialName;
  String _editMaterialIdentifier;

  var _materialNameController = TextEditingController();
  var _materialAmountController = TextEditingController();

  bool _inAsyncCall = false;

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
    return ModalProgressHUD(
        child: _showMainView(context),
        inAsyncCall: _inAsyncCall
    );
  }

  Widget _showMainView(BuildContext context) {
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
                              'assigned_orders.materials.header_new_material'
                                  .tr()),
                          _buildForm(),
                          Divider(),
                          _buildMaterialsSection(context),
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
    bloc.add(
        MaterialEvent(status: MaterialEventStatus.DELETE, value: material.id));
  }

  _showDeleteDialog(AssignedOrderMaterial material, BuildContext context) {
    showDeleteDialogWrapper(
        'assigned_orders.materials.delete_dialog_title'.tr(),
        'assigned_orders.materials.delete_dialog_content'.tr(),
        () => _doDelete(material),
        context
    );
  }

  _locationId2location(int location) {
    for (var i = 0; i < _locations.results.length; i++) {
      if (_locations.results[i].id == location) {
        return _locations.results[i].name;
      }
    }
  }

  _fillFormForEdit(AssignedOrderMaterial material, BuildContext context) {
    _selectedMaterial = null;
    _selectedMaterialId = material.material;
    _editId = material.id;
    _materialNameController.text = material.materialName;
    _location = _locationId2location(material.location);
    _locationId = material.location;
    _materialAmountController.text = material.amount.toString();
    _editMaterialName = material.materialName;
    _editMaterialIdentifier = material.materialIdentifier;
    setState(() {});
  }

  Widget _buildMaterialsSection(BuildContext context) {
    return buildItemsSection(
        context,
        'assigned_orders.materials.info_header_table'.tr(),
        materials.results,
        (item) {
          return <Widget>[
            ...buildItemListKeyValueList(
                'assigned_orders.materials.info_material'.tr(),
                item.materialName
            ),
            ...buildItemListKeyValueList(
                'assigned_orders.materials.info_location'.tr(),
                item.locationName
            ),
            ...buildItemListKeyValueList(
                'assigned_orders.materials.info_amount'.tr(),
                item.amount
            )
          ];
        },
        (item) {
          return <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createDefaultElevatedButton(
                  "assigned_orders.materials.button_update_material".tr(),
                  () {
                    _fillFormForEdit(item, context);
                  }
                ),
                SizedBox(width: 10),
                createDeleteButton(
                  "assigned_orders.materials.button_delete_material".tr(),
                  () { _showDeleteDialog(item, context); }
                )
              ],
            )
          ];
        }
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('assigned_orders.materials.info_location'.tr()),
        DropdownButtonFormField<String>(
          value: _location,
          items: _locations == null || _locations.results == null
              ? []
              : _locations.results.map((StockLocation location) {
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
                  orElse: () => _locations.results.first);

              _locationId = location.id;
            });
          },
        ),
        SizedBox(
          height: 10.0,
        ),
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: _typeAheadController,
              decoration: InputDecoration(
                  labelText:
                  'assigned_orders.materials.typeahead_label_search_material'
                      .tr())),
          suggestionsCallback: (pattern) async {
            if (pattern.length < 1) return null;
            return await inventoryApi.searchLocationProducts(
                _locationId, pattern);
          },
          itemBuilder: (context, suggestion) {
            final String inStockText = 'assigned_orders.materials.in_stock'
                .tr();
            return ListTile(
              title: Text(
                  '${suggestion.materialName} ($inStockText: ${suggestion
                      .totalAmount})'),
            );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          onSuggestionSelected: (suggestion) {
            _selectedMaterial = suggestion;

            _typeAheadController.text = '';
            _materialNameController.text = _selectedMaterial.materialName;

            // rebuild widgets
            setState(() {});
          },
          validator: (value) {
            return null;
          },
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
        createDefaultElevatedButton(
            _editId == null ? 'assigned_orders.materials.button_add_material'.tr() :
              'assigned_orders.materials.button_update_material'.tr(),
            _handleSubmit
        )
      ],
    );
  }

  Future<void> _handleSubmit() async {
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
          materialId = _selectedMaterial.materialId;
          materialName = _selectedMaterial.materialName;
          materialIdentifier = _selectedMaterial.materialIdentifier;
        } else {
          materialId = _selectedMaterialId;
          materialName = _editMaterialName;
          materialIdentifier = _editMaterialIdentifier;
        }
      } else {
        materialId = _selectedMaterial.materialId;
        materialName = _selectedMaterial.materialName;
        materialIdentifier = _selectedMaterial.materialIdentifier;
      }

      AssignedOrderMaterial material = AssignedOrderMaterial(
        id: _editId,
        amount: double.parse(amount),
        material: materialId,
        location: _locationId,
        materialName: materialName,
        materialIdentifier: materialIdentifier,
      );

      final bloc = BlocProvider.of<MaterialBloc>(context);

      // insert?
      if (_editId == null) {
        final AssignedOrderMaterial newMaterial = await mobileApi
            .insertAssignedOrderMaterial(material, assignedOrderPk);

        if (newMaterial == null) {
          displayDialog(
              context,
              'generic.error_dialog_title'.tr(),
              'assigned_orders.materials.error_dialog_content_add'.tr()
          );
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
              'assigned_orders.materials.error_dialog_content_update'.tr()
          );
        }
      }

      _editId = null;
      _inAsyncCall = false;
      _materialAmountController.text = '1';
    }
  }
}
