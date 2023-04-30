import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/models/material/form_data.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/models/material/models.dart';
import 'package:my24app/mobile/pages/material.dart';
import 'package:my24app/inventory/models/api.dart';
import 'package:my24app/inventory/models/models.dart';


class MaterialFormWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "assigned_orders.materials";
  final int assignedOrderId;
  final AssignedOrderMaterialFormData material;
  final MaterialPageData materialPageData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final InventoryMaterialTypeAheadModel selectedMaterial;
  final InventoryApi inventoryApi = InventoryApi();
  final bool newFromEmpty;

  MaterialFormWidget({
    Key key,
    this.assignedOrderId,
    this.material,
    this.selectedMaterial,
    this.materialPageData,
    @required this.newFromEmpty,
  }) : super(
      key: key,
      memberPicture: materialPageData.memberPicture
  );

  @override
  void doRefresh(BuildContext context) {
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return material.id == null ? $trans('app_bar_title_new') : $trans('app_bar_title_edit');
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
                          createSubmitSection(_getButtons(context))
                        ]
                    )
                )
            )
        )
    );
  }

  // private methods
  Widget _getButtons(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createCancelButton(() => _navList(context)),
          SizedBox(width: 10),
          createSubmitButton(() => _submitForm(context)),
        ]
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          wrapGestureDetector(context, Text($trans('info_location'))),
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
                        $trans('typeahead_label_search_material_stock')
                    )
                ),
                suggestionsCallback: (String pattern) async {
                  if (pattern.length < 1) return null;
                  return await inventoryApi.searchLocationProducts(
                      material.location, pattern);
                },
                itemBuilder: (context, suggestion) {
                  final String inStockText = $trans('in_stock');
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
                            Text($trans('not_found_in_stock'),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey
                                )
                            ),
                            TextButton(
                              child: Text(
                                  $trans('search_all_materials'),
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
                            $trans('typeahead_label_search_material_all')
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
                        return $trans('typeahead_validator_material');
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

          wrapGestureDetector(context, SizedBox(
            height: 10.0,
          )),
          wrapGestureDetector(context, Text($trans('info_material'))),
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

          wrapGestureDetector(context, SizedBox(
            height: 10.0,
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 240,
                child: Column(
                  children: [
                    wrapGestureDetector(context, Text($trans('info_identifier'))),
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
              wrapGestureDetector(context, SizedBox(width: 10)),
              Container(
                width: 100,
                child: Column(
                  children: [
                    wrapGestureDetector(context, Text($trans('info_amount'))),
                    TextFormField(
                        controller: material.amountController,
                        keyboardType:
                        TextInputType.numberWithOptions(signed: false, decimal: true),
                        validator: (value) {
                          if (value.isEmpty) {
                            return $trans('validator_amount');
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
    final page = AssignedOrderMaterialPage(
        assignedOrderId: assignedOrderId,
        bloc: MaterialBloc(),
    );

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
}
