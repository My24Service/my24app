import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/models/material/form_data.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/models/material/models.dart';
import 'package:my24app/mobile/pages/material.dart';
import 'package:my24app/inventory/models/api.dart';
import 'package:my24app/inventory/models/models.dart';

import '../../../core/widgets/slivers/app_bars.dart';

class MaterialFormWidget extends StatefulWidget {
  final int? assignedOrderId;
  final AssignedOrderMaterialFormData? material;
  final MaterialPageData materialPageData;
  final InventoryMaterialTypeAheadModel? selectedMaterial;
  final InventoryApi inventoryApi = InventoryApi();
  final bool? newFromEmpty;

  MaterialFormWidget({
    Key? key,
    this.assignedOrderId,
    this.material,
    this.selectedMaterial,
    required this.materialPageData,
    required this.newFromEmpty,
  });

  @override
  _MaterialFormWidgetState createState() => _MaterialFormWidgetState();
}

class _MaterialFormWidgetState extends State<MaterialFormWidget> with i18nMixin, TextEditingControllerMixin {
  final String basePath = "assigned_orders.materials";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final InventoryApi inventoryApi = InventoryApi();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController typeAheadControllerStock = TextEditingController();
  final TextEditingController typeAheadControllerAll = TextEditingController();

  @override
  void initState() {
    addTextEditingController(nameController, widget.material!, 'name');
    addTextEditingController(identifierController, widget.material!, 'identifier');
    addTextEditingController(amountController, widget.material!, 'amount');
    addTextEditingController(typeAheadControllerStock, widget.material!, 'typeAheadStock');
    addTextEditingController(typeAheadControllerAll, widget.material!, 'typeAheadAll');
    super.initState();
  }

  void dispose() {
    disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
            slivers: <Widget>[
              getAppBar(context),
              SliverToBoxAdapter(child: getContent(context))
            ]
        )
    );
  }

  SliverAppBar getAppBar(BuildContext context) {
    SmallAppBarFactory factory = SmallAppBarFactory(context: context, title: getAppBarTitle(context));
    return factory.createAppBar();
  }

  Widget getContent(BuildContext context) {
    return Container(
        child: Form(
            key: _formKey,
            child: Container(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(    // new line
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 10),
                          Container(
                            alignment: Alignment.topCenter,
                            child: _buildForm(context),
                          ),
                          createSubmitSection(_getButtons(context) as Row)
                        ]
                    )
                )
            )
        )
    );
  }

  String getAppBarTitle(BuildContext context) {
    return widget.material!.id == null ? $trans('app_bar_title_new') : $trans('app_bar_title_edit');
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

  Widget _getNoItemsFoundWidget(BuildContext context, bool isEmptyResult) {
    final String mainText = isEmptyResult ? $trans('not_found_in_stock') : $trans('item_not_found_question');
    return Container(
        height: 66,
        child: Column(
            children: [
              Text(mainText,
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
                  widget.material!.stockMaterialFound = false;
                  typeAheadControllerAll.text = typeAheadControllerStock.text;
                  _updateFormData(context);
                },
              )
            ]
        )
    );
  }

  Widget _buildForm(BuildContext context) {
    int numResults = 0;
    int itemIndex = 0;
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          wrapGestureDetector(context, Text($trans('info_location'))),
          DropdownButtonFormField<String>(
              value: "${widget.material!.location}",
              items: widget.materialPageData.locations == null || widget.materialPageData.locations!.results == null
                  ? []
                  : widget.materialPageData.locations!.results!.map((StockLocation location) {
                return new DropdownMenuItem<String>(
                  child: Text(location.name!),
                  value: "${location.id}",
                );
              }).toList(),
              onChanged: (String? locationId) {
                widget.material!.location = int.parse(locationId!);
                _updateFormData(context);
              }
          ),
          Visibility(
              visible: widget.material!.stockMaterialFound!,
              child: TypeAheadFormField<LocationMaterialInventory>(
                textFieldConfiguration: TextFieldConfiguration(
                    controller: typeAheadControllerStock,
                    decoration: InputDecoration(
                        labelText:
                        $trans('typeahead_label_search_material_stock')
                    )
                ),
                suggestionsCallback: (String pattern) async {
                  final List<LocationMaterialInventory> result = await inventoryApi.searchLocationProducts(widget.material!.location, pattern);
                  numResults = result.length;
                  itemIndex = 0;
                  return result;
                },
                itemBuilder: (_context, suggestion) {
                  itemIndex++;
                  final String inStockText = $trans('in_stock');
                  if (itemIndex < numResults) {
                    return ListTile(
                      title: Text(
                          '${suggestion.materialName} ($inStockText: ${suggestion.totalAmount})'
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                            '${suggestion.materialName} ($inStockText: ${suggestion.totalAmount})'
                        ),
                      ),
                      Divider(),
                      // SizedBox(height: 10),
                      _getNoItemsFoundWidget(context, false)
                    ],
                  );
                },
                noItemsFoundBuilder: (_context) {
                  return Container(
                      height: 66,
                      child: _getNoItemsFoundWidget(context, true)
                  );
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (LocationMaterialInventory suggestion) {
                  widget.material!.material = suggestion.materialId;
                  nameController.text = suggestion.materialName!;
                  identifierController.text = suggestion.materialIdentifier!;
                  _updateFormData(context);
                },
                validator: (value) {
                  return null;
                },
              )
          ),

          Visibility(
            visible: !widget.material!.stockMaterialFound!,
            child: Column(
              children: [
                TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                        autofocus: true,
                        controller: typeAheadControllerAll,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText:
                            $trans('typeahead_label_search_material_all')
                        )
                    ),
                    suggestionsCallback: (pattern) async {
                      return await inventoryApi.materialTypeAhead(pattern);
                    },
                    itemBuilder: (context, dynamic suggestion) {
                      return ListTile(
                        title: Text(suggestion.value),
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    noItemsFoundBuilder: (_context) {
                      return Container(
                          child: ListTile(title: Text($trans('not_found_in_all')))
                      );
                    },
                    onSuggestionSelected: (InventoryMaterialTypeAheadModel suggestion) {
                      widget.material!.material = suggestion.id;
                      typeAheadControllerAll.text = suggestion.materialName!;
                      nameController.text = suggestion.materialName!;
                      identifierController.text = suggestion.materialIdentifier!;
                      _updateFormData(context);
                    },
                    validator: (value) {
                      if (widget.material!.id == null && value!.isEmpty) {
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
              controller: nameController,
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
                        controller: identifierController,
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
                        controller: amountController,
                        keyboardType:
                        TextInputType.numberWithOptions(signed: false, decimal: true),
                        validator: (value) {
                          if (value!.isEmpty) {
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
        assignedOrderId: widget.assignedOrderId,
        bloc: MaterialBloc(),
    );

    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState!.validate()) {
      this._formKey.currentState!.save();

      if (!widget.material!.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      String amount = amountController.text;
      if (amount.contains(',')) {
        amount = amount.replaceAll(new RegExp(r','), '.');
        amountController.text = amount;
      }

      final bloc = BlocProvider.of<MaterialBloc>(context);
      if (widget.material!.id != null) {
        AssignedOrderMaterial updatedMaterial = widget.material!.toModel();
        bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
        bloc.add(MaterialEvent(
            pk: updatedMaterial.id,
            status: MaterialEventStatus.UPDATE,
            material: updatedMaterial,
            assignedOrderId: updatedMaterial.assignedOrderId
        ));
      } else {
        AssignedOrderMaterial newMaterial = widget.material!.toModel();
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
        materialFormData: widget.material
    ));
  }
}
