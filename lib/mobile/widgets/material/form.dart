import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:my24_flutter_core/models/base_models.dart';

import 'package:my24_flutter_core/widgets/slivers/app_bars.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/mobile/models/material/form_data.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/models/material/models.dart';
import 'package:my24app/mobile/pages/material.dart';
import 'package:my24app/inventory/models/location/api.dart';
import 'package:my24app/inventory/models/material/models.dart';
import 'package:my24app/inventory/models/material/api.dart';
import 'package:my24app/inventory/models/location/models.dart';

import '../../../inventory/blocs/material_bloc.dart';
import '../../../inventory/blocs/material_states.dart';
import '../../../inventory/widgets/material/form.dart';

class MaterialFormWidget extends StatefulWidget {
  final int? assignedOrderId;
  final AssignedOrderMaterialFormData? material;
  final MaterialPageData materialPageData;
  final MaterialTypeAheadModel? selectedMaterial;
  final bool? newFromEmpty;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  MaterialFormWidget({
    Key? key,
    this.assignedOrderId,
    this.material,
    this.selectedMaterial,
    required this.materialPageData,
    required this.newFromEmpty,
    required this.widgetsIn,
    required this.i18nIn,
  });

  @override
  _MaterialFormWidgetState createState() => _MaterialFormWidgetState();
}

class _MaterialFormWidgetState extends State<MaterialFormWidget> with TextEditingControllerMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MaterialApi materialApi = MaterialApi();
  final LocationApi locationApi = LocationApi();
  bool isDoCreate = false;

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
        padding: const EdgeInsets.all(14),
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
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(5),
                                )
                            ),
                            padding: const EdgeInsets.all(14),
                            alignment: Alignment.topCenter,
                            child: _buildForm(context),
                          ),
                          widget.widgetsIn.createSubmitSection(_getButtons(context) as Row)
                        ]
                    )
                )
            )
        )
    );
  }

  String getAppBarTitle(BuildContext context) {
    return widget.material!.id == null ? widget.i18nIn.$trans('app_bar_title_new') :widget.i18nIn.$trans('app_bar_title_edit');
  }

  // private methods
  Widget _getButtons(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.widgetsIn.createCancelButton(() => _navList(context)),
          SizedBox(width: 10),
          widget.widgetsIn.createSubmitButton(context, () => _submitForm(context)),
        ]
    );
  }

  Widget _getNoItemsFoundWidget(BuildContext context, bool isEmptyResult) {
    final String mainText = isEmptyResult ? widget.i18nIn.$trans('not_found_in_stock') : widget.i18nIn.$trans('item_not_found_question');
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
                   widget.i18nIn.$trans('search_all_materials'),
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
          widget.widgetsIn.wrapGestureDetector(context, Text(widget.i18nIn.$trans('info_location'))),
          DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
              ),
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
              child: Column(
                children: [
                  SizedBox(height: 14),
                  widget.widgetsIn.wrapGestureDetector(
                      context,
                      Text(widget.i18nIn.$trans('info_material_stock'))
                  ),
                  TypeAheadFormField<LocationMaterialInventory>(
                    textFieldConfiguration: TextFieldConfiguration(
                        controller: typeAheadControllerStock,
                        decoration: InputDecoration(
                          labelText: widget.i18nIn.$trans('typeahead_label_search_material_stock'),
                          filled: true,
                          fillColor: Colors.white,
                        )
                    ),
                    suggestionsCallback: (String pattern) async {
                      final List<LocationMaterialInventory> result = await locationApi.searchLocationProducts(widget.material!.location, pattern);
                      numResults = result.length;
                      itemIndex = 0;
                      return result;
                    },
                    itemBuilder: (_context, suggestion) {
                      itemIndex++;
                      final String inStockText =widget.i18nIn.$trans('in_stock');
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
                ],
              )
          ),

          Visibility(
            visible: !widget.material!.stockMaterialFound!,
            child: Column(
              children: [
                SizedBox(height: 14),
                widget.widgetsIn.wrapGestureDetector(
                    context,
                    Text(widget.i18nIn.$trans('info_material_all'))
                ),
                TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                        autofocus: true,
                        controller: typeAheadControllerAll,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: widget.i18nIn.$trans(
                              'typeahead_label_search_material_all'),
                          filled: true,
                          fillColor: Colors.white,
                        )
                    ),
                    suggestionsCallback: (pattern) async {
                      return await materialApi.typeAhead(pattern);
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
                          child: Column(
                            children: [
                              ListTile(
                                  title: Text(
                                      widget.i18nIn.$trans('not_found_in_all')
                                  )
                              ),
                              Text("info_create_new_material")
                            ],
                          )
                      );
                    },
                    onSuggestionSelected: (MaterialTypeAheadModel suggestion) {
                      widget.material!.material = suggestion.id;
                      typeAheadControllerAll.text = suggestion.materialName!;
                      nameController.text = suggestion.materialName!;
                      identifierController.text = suggestion.materialIdentifier!;
                      _updateFormData(context);
                    },
                    validator: (value) {
                      if (widget.material!.id == null && value!.isEmpty) {
                        return widget.i18nIn.$trans(
                            'typeahead_validator_material');
                      }

                      return null;
                    }
                )
              ]
            )
          ),

          Visibility(
            visible: isDoCreate,
            child: MaterialCreateFormContainerWidget(
              materialCreatedCallBack: (MaterialModel material) =>
                  _materialCreatedCallBack(context, material),
              materialCancelCreateCallBack: _materialCancelCreateCallBack,
            )
          ),

          widget.widgetsIn.wrapGestureDetector(context, SizedBox(
            height: 10.0,
          )),
          widget.widgetsIn.wrapGestureDetector(
              context,
              Text(widget.i18nIn.$trans('info_material'))
          ),
          TextFormField(
              readOnly: true,
              controller: nameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                return null;
              }
          ),

          widget.widgetsIn.wrapGestureDetector(context, SizedBox(
            height: 10.0,
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 240,
                child: Column(
                  children: [
                    widget.widgetsIn.wrapGestureDetector(
                        context,
                        Text(widget.i18nIn.$trans('info_identifier'))
                    ),
                    TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
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
              widget.widgetsIn.wrapGestureDetector(
                  context, SizedBox(width: 10)
              ),
              Container(
                width: 100,
                child: Column(
                  children: [
                    widget.widgetsIn.wrapGestureDetector(
                        context,
                        Text(widget.i18nIn.$trans('info_amount'))
                    ),
                    TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        controller: amountController,
                        keyboardType:
                        TextInputType.numberWithOptions(
                            signed: false,
                            decimal: true
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return widget.i18nIn.$trans('validator_amount');
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

  _materialCreatedCallBack(BuildContext context, MaterialModel material) {
    widget.material!.material = material.id;
    typeAheadControllerAll.text = checkNull(material.name);
    nameController.text = checkNull(material.name);
    identifierController.text = checkNull(material.identifier);
    isDoCreate = false;
    _updateFormData(context);
  }

  _materialCancelCreateCallBack() {
    setState(() {
      isDoCreate = false;
    });
  }

  void _navList(BuildContext context) {
    final page = AssignedOrderMaterialPage(
        assignedOrderId: widget.assignedOrderId,
        bloc: AssignedOrderMaterialBloc(),
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

      final bloc = BlocProvider.of<AssignedOrderMaterialBloc>(context);
      if (widget.material!.id != null) {
        AssignedOrderMaterial updatedMaterial = widget.material!.toModel();
        bloc.add(AssignedOrderMaterialEvent(
            status: AssignedOrderMaterialEventStatus.DO_ASYNC
        ));
        bloc.add(AssignedOrderMaterialEvent(
            pk: updatedMaterial.id,
            status: AssignedOrderMaterialEventStatus.UPDATE,
            material: updatedMaterial,
            assignedOrderId: updatedMaterial.assignedOrderId
        ));
      } else {
        AssignedOrderMaterial newMaterial = widget.material!.toModel();
        bloc.add(AssignedOrderMaterialEvent(
            status: AssignedOrderMaterialEventStatus.DO_ASYNC
        ));
        bloc.add(AssignedOrderMaterialEvent(
            status: AssignedOrderMaterialEventStatus.INSERT,
            material: newMaterial,
            assignedOrderId: newMaterial.assignedOrderId
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderMaterialBloc>(context);
    bloc.add(AssignedOrderMaterialEvent(
        status: AssignedOrderMaterialEventStatus.DO_ASYNC
    ));
    bloc.add(AssignedOrderMaterialEvent(
        status: AssignedOrderMaterialEventStatus.UPDATE_FORM_DATA,
        materialFormData: widget.material
    ));
  }
}

// container widget for bloc handling
class MaterialCreateFormContainerWidget extends StatelessWidget {
  final MaterialBloc bloc = MaterialBloc();
  final CoreWidgets widgets = CoreWidgets();
  final i18n = My24i18n(basePath: "inventory.material");
  final Function materialCreatedCallBack;
  final Function materialCancelCreateCallBack;

  MaterialCreateFormContainerWidget({
    required this.materialCreatedCallBack,
    required this.materialCancelCreateCallBack,
  });
  
  MaterialBloc _initialBlocCall() {
    bloc.add(MaterialEvent(
        status: MaterialEventStatus.newModel,
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MaterialBloc>(
        create: (context) => _initialBlocCall(),
        child: BlocConsumer<MaterialBloc, MyMaterialState>(
            listener: (context, state) {
              _handleListeners(context, state);
            },
            builder: (context, state) {
              return Scaffold(
                body: _getBody(context, state),
              );
            }
        )
    );
  }

  void _handleListeners(BuildContext context, state) {
    if (state is MaterialInsertedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_added'));

      materialCreatedCallBack(state.material!);
    }

    if (state is MaterialCancelCreateState) {
      materialCancelCreateCallBack();
    }
  }

  Widget _getBody(context, state) {
    if (state is MaterialInitialState) {
      return widgets.loadingNotice();
    }

    if (state is MaterialLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is MaterialLoadedState) {
      return MaterialCreateFormWidget(
        material: state.materialFormData,
        widgets: widgets,
        i18n: i18n,
      );
    }

    if (state is MaterialNewState) {
      return MaterialCreateFormWidget(
        material: state.materialFormData,
        widgets: widgets,
        i18n: i18n,
      );
    }

    return widgets.loadingNotice();
  }
}

