import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:logging/logging.dart';

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
import 'package:my24app/inventory/blocs/material_bloc.dart';
import 'package:my24app/inventory/blocs/material_states.dart';
import 'package:my24app/inventory/blocs/supplier_bloc.dart';
import 'package:my24app/inventory/blocs/supplier_states.dart';
import 'package:my24app/inventory/widgets/material/form.dart';
import 'package:my24app/inventory/widgets/supplier/form.dart';
import 'package:my24app/inventory/models/material/form_data.dart';
import 'breadcrumb.dart';

final log = Logger('mobile.widgets.form');

class MaterialFormWidget extends StatefulWidget {
  final int? assignedOrderId;
  final AssignedOrderMaterialFormData? material;
  final MaterialPageData materialPageData;
  final MaterialTypeAheadModel? selectedMaterial;
  final bool? newFromEmpty;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  final bool isMaterialCreated;
  final List<AssignedOrderMaterial>? materialsFromQuotation;

  MaterialFormWidget({
    Key? key,
    this.assignedOrderId,
    this.material,
    this.selectedMaterial,
    this.materialsFromQuotation,
    required this.materialPageData,
    required this.newFromEmpty,
    required this.widgetsIn,
    required this.i18nIn,
    required this.isMaterialCreated
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
    if (widget.isMaterialCreated) {
      _fillTextControllers();
      isDoCreate = false;
    }

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
                    child: _getBody(context)
                )
            )
        )
    );
  }

  String getAppBarTitle(BuildContext context) {
    return widget.material!.id == null ? widget.i18nIn.$trans('app_bar_title_new') :widget.i18nIn.$trans('app_bar_title_edit');
  }

  void _fillTextControllers() {
    typeAheadControllerAll.text = checkNull(widget.material!.name);
    nameController.text = checkNull(widget.material!.name);
    identifierController.text = checkNull(widget.material!.identifier);
    isDoCreate = false;
  }

  Widget _getBody(BuildContext context) {
    if (isDoCreate) {
      return Container(
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
          child: MaterialCreateFormContainerWidget(
            materialCancelCreateCallBack: _materialCancelCreateCallBack,
            assignedOrderMaterialFormData: widget.material!,
          )
      );
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
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
    );
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
              visible: widget.material!.stockMaterialFound! && !isDoCreate,
              child: Column(
                children: [
                  SizedBox(height: 14),
                  widget.widgetsIn.wrapGestureDetector(
                      context,
                      Text(widget.i18nIn.$trans('info_material_stock'))
                  ),
                  TypeAheadFormField<LocationMaterialInventory>(
                    minCharsForSuggestions: 2,
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
            visible: !widget.material!.stockMaterialFound! && !isDoCreate,
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
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.i18nIn.$trans('not_found_in_all')),
                            TextButton(
                              child: Text(
                                  widget.i18nIn.$trans(
                                      'info_create_new_material'),
                                  style: TextStyle(
                                    fontSize: 12,
                                  )
                              ),
                              onPressed: () {
                                setState(() {
                                  isDoCreate = true;
                                });
                              },
                            )
                          ]
                      );
                    },
                    onSuggestionSelected: (MaterialTypeAheadModel suggestion) {
                      widget.material!.material = suggestion.id;
                      typeAheadControllerAll.text = checkNull(suggestion.materialName);
                      nameController.text = checkNull(suggestion.materialName);
                      identifierController.text = checkNull(suggestion.materialIdentifier);
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

          widget.widgetsIn.wrapGestureDetector(context, SizedBox(
            height: 10.0,
          )),
          widget.widgetsIn.wrapGestureDetector(
              context,
              Text(widget.i18nIn.$trans('info_amount'))
          ),
          Container(
            width: 200,
            child: TextFormField(
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
          )
        ]
    );
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

class MaterialFormQuotationMaterialsWidget extends StatefulWidget {
  final int? assignedOrderId;
  final AssignedOrderMaterialFormData? material;
  final MaterialPageData materialPageData;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  final List<AssignedOrderMaterial>? materialsFromQuotation;

  MaterialFormQuotationMaterialsWidget({
    Key? key,
    this.assignedOrderId,
    this.material,
    this.materialsFromQuotation,
    required this.materialPageData,
    required this.widgetsIn,
    required this.i18nIn,
  });

  @override
  _MaterialFormQuotationMaterialsWidgetState createState() => _MaterialFormQuotationMaterialsWidgetState();
}

class _MaterialFormQuotationMaterialsWidgetState extends State<MaterialFormQuotationMaterialsWidget> with TextEditingControllerMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MaterialApi materialApi = MaterialApi();
  final LocationApi locationApi = LocationApi();
  final List<Map<String, TextEditingController>> textControllers = [];

  @override
  void initState() {
    for (int i=0; i<widget.materialsFromQuotation!.length; i++) {
      final TextEditingController amountController = TextEditingController();
      addTextEditingController(amountController, widget.material!.formDataList![i], 'amount');

      final TextEditingController requestedAmountController = TextEditingController();
      requestedAmountController.text = "${widget.materialsFromQuotation![i].amount}";
      addTextEditingController(requestedAmountController, widget.material!.formDataList![i], 'requestedAmount');

      final TextEditingController nameController = TextEditingController();
      nameController.text = "${widget.materialsFromQuotation![i].materialName}";
      addTextEditingController(nameController, widget.material!.formDataList![i], 'name');

      final TextEditingController identifierController = TextEditingController();
      identifierController.text = "${widget.materialsFromQuotation![i].materialIdentifier}";
      addTextEditingController(identifierController, widget.material!.formDataList![i], 'identifier');

      textControllers.add({
        'amount': amountController,
        'requestedAmount': requestedAmountController,
        'name': nameController,
        'identifier': identifierController
      });
    }
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
                    child: _getBody(context)
                )
            )
        )
    );
  }

  String getAppBarTitle(BuildContext context) {
    return widget.material!.id == null ? widget.i18nIn.$trans('app_bar_title_new') :widget.i18nIn.$trans('app_bar_title_edit');
  }

  Widget _getBody(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
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
            child: Row(
              children: _buildForm(context),
            ),
          ),
          widget.widgetsIn.createSubmitSection(_getButtons(context) as Row)
        ]
    );
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

  List<Column> _buildForm(BuildContext context) {
    List<Column> columns = [];
    for (int i=0; i<widget.materialsFromQuotation!.length; i++) {
      columns.add(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            widget.widgetsIn.wrapGestureDetector(context, Text(widget.i18nIn.$trans('info_location'))),
            DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: "${widget.material!.formDataList![i].location}",
                items: widget.materialPageData.locations == null || widget.materialPageData.locations!.results == null
                    ? []
                    : widget.materialPageData.locations!.results!.map((StockLocation location) {
                  return new DropdownMenuItem<String>(
                    child: Text(location.name!),
                    value: "${location.id}",
                  );
                }).toList(),
                onChanged: (String? locationId) {
                  widget.material!.formDataList![i].location = int.parse(locationId!);
                  _updateFormData(context);
                }
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
                controller: textControllers[i]['name'],
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
                controller: textControllers[i]['identifier'],
                keyboardType: TextInputType.text,
                validator: (value) {
                  return null;
                }
            ),

            widget.widgetsIn.wrapGestureDetector(context, SizedBox(
              height: 10.0,
            )),
            widget.widgetsIn.wrapGestureDetector(
                context,
                Text(widget.i18nIn.$trans('info_amount_requested'))
            ),
            Container(
              width: 200,
              child: TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  controller: textControllers[i]['requestedAmount'],
                  readOnly: true
              ),
            ),

            widget.widgetsIn.wrapGestureDetector(context, SizedBox(
              height: 10.0,
            )),
            widget.widgetsIn.wrapGestureDetector(
                context,
                Text(widget.i18nIn.$trans('info_amount'))
            ),
            Container(
              width: 200,
              child: TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  controller: textControllers[i]['amount'],
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
            )
          ]
      ));
    }

    return columns;
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

      List<AssignedOrderMaterial> models = [];
      for (int i=0; i<widget.material!.formDataList!.length; i++) {
        models.add(widget.material!.formDataList![i].toModel());
      }

      final bloc = BlocProvider.of<AssignedOrderMaterialBloc>(context);
      bloc.add(AssignedOrderMaterialEvent(
          status: AssignedOrderMaterialEventStatus.DO_ASYNC
      ));
      bloc.add(AssignedOrderMaterialEvent(
          status: AssignedOrderMaterialEventStatus.INSERT_MULTIPLE,
          materials: models,
          assignedOrderId: widget.assignedOrderId
      ));
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderMaterialBloc>(context);
    bloc.add(AssignedOrderMaterialEvent(
        status: AssignedOrderMaterialEventStatus.DO_ASYNC
    ));
    bloc.add(AssignedOrderMaterialEvent(
        status: AssignedOrderMaterialEventStatus.UPDATE_FORM_DATA,
        materialFormData: widget.material,
    ));
  }
}


// container widget for material bloc handling
// stateful for the boolean is create supplier
class MaterialCreateFormContainerWidget extends StatefulWidget {
  final CoreWidgets widgets = CoreWidgets();
  final i18n = My24i18n(basePath: "inventory.material");
  final AssignedOrderMaterialFormData assignedOrderMaterialFormData;
  final Function materialCancelCreateCallBack;

  MaterialCreateFormContainerWidget({
    required this.materialCancelCreateCallBack,
    required this.assignedOrderMaterialFormData
  });

  @override
  _MaterialCreateFormWidgetState createState() => _MaterialCreateFormWidgetState();
}

class _MaterialCreateFormWidgetState extends State<MaterialCreateFormContainerWidget> {
  final MaterialBloc bloc = MaterialBloc();
  bool isCreateSupplier = false;

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
              return _getMainBody(context, state);
            }
        )
    );
  }

  Widget _getMainBody(BuildContext context, state) {
    if (!isCreateSupplier) {
      final List<BreadCrumbItem> items = [
        BreadCrumbItem(
            text: widget.i18n.$trans("breadcrumb_used_material"),
            callback: () => widget.materialCancelCreateCallBack()
        ),
        BreadCrumbItem(
            text: widget.i18n.$trans("breadcrumb_new_material"),
            callback: () {}
        )
      ];

      final BreadCrumbNavigator breadCrumbNavigator = BreadCrumbNavigator(items: items);

      return Column(
        children: [
          breadCrumbNavigator,
          _getBody(context, state),
        ],
      );
    }

    return _getBody(context, state);
  }

  void _handleListeners(BuildContext context, state) {
    log.info("_MaterialCreateFormWidgetState._handleListeners state: $state");
    if (state is MaterialInsertedState) {
      widget.widgets.createSnackBar(
          context, widget.i18n.$trans('snackbar_added'));

      state.assignedOrderMaterialFormData!.material = state.material!.id!;
      state.assignedOrderMaterialFormData!.name = state.material!.name!;
      state.assignedOrderMaterialFormData!.identifier = state.material!.identifier;
      // state.assignedOrderMaterialFormData!.typeAheadStock = state.material!.name!;
      // state.assignedOrderMaterialFormData!.typeAheadAll = state.material!.name!;

      final bloc = BlocProvider.of<AssignedOrderMaterialBloc>(context);
      bloc.add(AssignedOrderMaterialEvent(
          status: AssignedOrderMaterialEventStatus.materialCreated,
          materialFormData: state.assignedOrderMaterialFormData!
      ));
    }

    if (state is MaterialCancelCreateState) {
      widget.materialCancelCreateCallBack();
    }

    if (state is MaterialSupplierCreatedState) {
      setState(() {
        isCreateSupplier = false;
      });
    }
  }

  supplierCancelCreateCallBack() {
    setState(() {
      isCreateSupplier = false;
    });
  }

  supplierCreateCallBack() {
    setState(() {
      isCreateSupplier = true;
    });
  }

  Widget _getBody(context, state) {
    log.info("_MaterialCreateFormWidgetState._getBody state: $state");

    if (isCreateSupplier && !(state is MaterialSupplierCreatedState)) {
      return SupplierCreateFormContainerWidget(
        supplierCancelCreateCallBack: supplierCancelCreateCallBack,
        materialFormData: state.materialFormData,
      );
    }

    if (state is MaterialInitialState) {
      return widget.widgets.loadingNotice();
    }

    if (state is MaterialLoadingState) {
      return widget.widgets.loadingNotice();
    }

    if (state is MaterialSupplierCreatedState) {
      return MaterialCreateFormWidget(
        material: state.materialFormData,
        widgets: widget.widgets,
        i18n: widget.i18n,
        supplierCreateCallBack: supplierCreateCallBack,
        assignedOrderMaterialFormData: widget.assignedOrderMaterialFormData,
      );
    }

    if (state is MaterialLoadedState) {
      return MaterialCreateFormWidget(
        material: state.materialFormData,
        widgets: widget.widgets,
        i18n: widget.i18n,
        supplierCreateCallBack: supplierCreateCallBack,
        assignedOrderMaterialFormData: widget.assignedOrderMaterialFormData,
      );
    }

    if (state is MaterialNewState) {
      return MaterialCreateFormWidget(
        material: state.materialFormData,
        widgets: widget.widgets,
        i18n: widget.i18n,
        supplierCreateCallBack: supplierCreateCallBack,
        assignedOrderMaterialFormData: widget.assignedOrderMaterialFormData,
      );
    }

    return widget.widgets.loadingNotice();
  }
}

// container widget for supplier bloc handling
class SupplierCreateFormContainerWidget extends StatelessWidget {
  final SupplierBloc bloc = SupplierBloc();
  final CoreWidgets widgets = CoreWidgets();
  final MaterialFormData? materialFormData;
  final i18n = My24i18n(basePath: "inventory.supplier");
  final Function supplierCancelCreateCallBack;

  SupplierCreateFormContainerWidget({
    required this.supplierCancelCreateCallBack,
    this.materialFormData
  });

  SupplierBloc _initialBlocCall() {
    bloc.add(SupplierEvent(
      status: SupplierEventStatus.newModel,
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    final List<BreadCrumbItem> items = [
      BreadCrumbItem(
          text: i18n.$trans("breadcrumb_used_material"),
          callback: () {}
      ),
      BreadCrumbItem(
          text: i18n.$trans("breadcrumb_new_material"),
          callback: () => supplierCancelCreateCallBack()
      ),
      BreadCrumbItem(
          text: i18n.$trans("breadcrumb_new_supplier"),
          callback: () {}
      )
    ];

    final BreadCrumbNavigator breadCrumbNavigator = BreadCrumbNavigator(items: items);

    return BlocProvider<SupplierBloc>(
        create: (context) => _initialBlocCall(),
        child: BlocConsumer<SupplierBloc, SupplierState>(
            listener: (context, state) {
              _handleListeners(context, state);
            },
            builder: (context, state) {
              return Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: breadCrumbNavigator
                    ),
                    _getBody(context, state),
                  ],
              );
            }
        )
    );
  }

  void _handleListeners(BuildContext context, state) {
    log.info("SupplierCreateFormContainerWidget._handleListeners state: $state");

    if (state is SupplierInsertedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_added'));

      state.materialFormData!.supplierRelation = state.supplier!.id!;
      state.materialFormData!.supplier = state.supplier!.name!;
      state.materialFormData!.typeAheadSupplier = state.supplier!.name!;

      final bloc = BlocProvider.of<MaterialBloc>(context);
      bloc.add(MaterialEvent(status: MaterialEventStatus.doAsync));
      bloc.add(MaterialEvent(
          status: MaterialEventStatus.supplierCreated,
          materialFormData: state.materialFormData!
      ));
    }

    if (state is SupplierCancelCreateState) {
      supplierCancelCreateCallBack();
    }

    if (state is SupplierErrorState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_error_creating'));
    }
  }

  Widget _getBody(context, state) {
    log.info("SupplierCreateFormContainerWidget._getBody state: $state");
    if (state is SupplierInitialState) {
      return widgets.loadingNotice();
    }

    if (state is SupplierLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is SupplierAddressReceivedState) {
      return SupplierCreateFormWidget(
        supplier: state.supplierFormData,
        widgets: widgets,
        i18n: i18n,
        materialFormData: materialFormData,
      );
    }

    if (state is SupplierLoadedState) {
      return SupplierCreateFormWidget(
        supplier: state.supplierFormData,
        widgets: widgets,
        i18n: i18n,
        materialFormData: materialFormData,
      );
    }

    if (state is SupplierNewState) {
      return SupplierCreateFormWidget(
        supplier: state.supplierFormData,
        widgets: widgets,
        i18n: i18n,
        materialFormData: materialFormData,
      );
    }

    return widgets.loadingNotice();
  }
}
