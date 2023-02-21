import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:my24app/core/widgets/sliver_classes.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/models/material/form_data.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/models/material/models.dart';
import 'package:my24app/mobile/pages/material.dart';
import 'package:my24app/inventory/api/inventory_api.dart';
import 'package:my24app/inventory/models/models.dart';

import '../../core/models/models.dart';


class MaterialFormWidget extends BaseSliverStatelessWidget {
  final int assignedOrderId;
  final AssignedOrderMaterialFormData material;
  final MaterialPageData materialPageData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final InventoryMaterialTypeAheadModel selectedMaterial;

  MaterialFormWidget({
    Key key,
    this.assignedOrderId,
    this.material,
    this.selectedMaterial,
    this.materialPageData
  }) : super(key: key);

  @override
  SliverAppBar getAppBar(BuildContext context) {
    String title = material.id == null ? 'assigned_orders.materials.app_bar_title_new'.tr() :
      'assigned_orders.materials.app_bar_title_edit'.tr();
    GenericAppBarFactory factory = GenericAppBarFactory(
      context: context,
      title: title,
      subtitle: "",
    );
    return factory.createAppBar();
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Container(
        child: Form(
          key: _formKey,
          child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(    // new line
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: _buildForm(context),
                  ),
                ]
              )
            )
          )
        )
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('assigned_orders.materials.info_location'.tr()),
          DropdownButtonFormField<String>(
              value: "${material.location}",
              items: materialPageData == null || materialPageData.locations == null || materialPageData.locations.results == null
                  ? []
                  : materialPageData.locations.results.map((StockLocation location) {
                return new DropdownMenuItem<String>(
                  child: Text(location.name),
                  value: "${location.id}",
                );
              }).toList(),
              onChanged: (String locationId) {
                material.location = int.parse(locationId);
                _updateFormData(context);
              }
          ),
          Visibility(
            visible: material.stockMaterialFound,
            child: TypeAheadFormField<LocationMaterialInventory>(
              textFieldConfiguration: TextFieldConfiguration(
                  controller: material.typeAheadControllerStock,
                  decoration: InputDecoration(
                      labelText:
                      'assigned_orders.materials.typeahead_label_search_material_stock'.tr()
                  )
              ),
              suggestionsCallback: (String pattern) async {
                if (pattern.length < 1) return null;
                return await inventoryApi.searchLocationProducts(
                    material.location, pattern);
              },
              itemBuilder: (context, suggestion) {
                final String inStockText = 'assigned_orders.materials.in_stock'.tr();
                return ListTile(
                  title: Text(
                      '${suggestion.materialName} ($inStockText: ${suggestion.totalAmount})'
                  ),
                );
              },
              noItemsFoundBuilder: (_context) {
                return Container(
                      height: 66,
                      child: Column(
                          children: [
                            Text("Material not found in stock",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey
                                )
                            ),
                            TextButton(
                              child: Text(
                                  "Search all materials",
                                  style: TextStyle(
                                      fontSize: 12,
                                  )
                              ),
                              onPressed: () {
                                material.stockMaterialFound = false;
                                _updateFormData(context);
                              },
                            )
                          ]
                      )
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (LocationMaterialInventory suggestion) {
                material.material = suggestion.materialId;
                material.nameController.text = suggestion.materialName;
                material.identifierController.text = suggestion.materialIdentifier;
                _updateFormData(context);
              },
              validator: (value) {
                return null;
              },
            )
          ),

          Visibility(
            visible: !material.stockMaterialFound,
              child: Column(
                children: [
                  TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: material.typeAheadControllerAll,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText:
                              'assigned_orders.materials.typeahead_label_search_material_all'.tr()
                          )
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
                      onSuggestionSelected: (InventoryMaterialTypeAheadModel suggestion) {
                        material.material = suggestion.id;
                        material.typeAheadControllerAll.text = suggestion.materialName;
                        material.nameController.text = suggestion.materialName;
                        material.identifierController.text = suggestion.materialIdentifier;
                        _updateFormData(context);
                      },
                      validator: (value) {
                        if (material.id == null && value.isEmpty) {
                          return 'assigned_orders.materials.typeahead_validator_material'.tr();
                        }

                        return null;
                      },
                      onSaved: (value) => {
                        // this._selectedMaterialName = value,
                      }
                  )
                ],
              ),
          ),

          SizedBox(
            height: 10.0,
          ),
          Text('assigned_orders.materials.info_material'.tr()),
          TextFormField(
              readOnly: true,
              controller: material.nameController,
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

          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 240,
                child: Column(
                  children: [
                    Text('assigned_orders.materials.info_identifier'.tr()),
                    TextFormField(
                        readOnly: true,
                        controller: material.identifierController,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          return null;
                        }
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Container(
                width: 100,
                child: Column(
                  children: [
                    Text('assigned_orders.materials.info_amount'.tr()),
                    TextFormField(
                        controller: material.amountController,
                        keyboardType:
                        TextInputType.numberWithOptions(signed: false, decimal: true),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'assigned_orders.materials.validator_amount'.tr();
                          }
                          return null;
                        }
                    ),
                  ],
                ),
              )
            ],
          )
        ]
    );
  }

  void _navList(BuildContext context) {
    final page = AssignedOrderMaterialPage(assignedOrderId: assignedOrderId);
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      if (!material.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      String amount = material.amountController.text;
      if (amount.contains(',')) {
        amount = amount.replaceAll(new RegExp(r','), '.');
        material.amountController.text = amount;
      }

      final bloc = BlocProvider.of<MaterialBloc>(context);
      if (material.id != null) {
        AssignedOrderMaterial updatedMaterial = material.toModel();
        bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
        bloc.add(MaterialEvent(
            pk: updatedMaterial.id,
            status: MaterialEventStatus.UPDATE,
            material: updatedMaterial,
            assignedOrderId: updatedMaterial.assignedOrderId
        ));
      } else {
        AssignedOrderMaterial newMaterial = material.toModel();
        bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
        bloc.add(MaterialEvent(
            status: MaterialEventStatus.INSERT,
            material: newMaterial,
            assignedOrderId: newMaterial.assignedOrderId
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<MaterialBloc>(context);
    bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
    bloc.add(MaterialEvent(
        status: MaterialEventStatus.UPDATE_FORM_DATA,
        materialFormData: material
    ));
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createElevatedButtonColored(
            'generic.action_cancel'.tr(),
            () => { _navList(context) }
          ),
          SizedBox(width: 10),
          createDefaultElevatedButton(
            material.id == null ? 'assigned_orders.materials.button_add'.tr() :
              'assigned_orders.materials.button_edit'.tr(),
            () => { _submitForm(context) }
          ),
      ]
    );
  }

}
