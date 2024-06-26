import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/inventory/models/supplier/models.dart';
import 'package:my24app/inventory/blocs/material_bloc.dart';
import 'package:my24app/inventory/models/material/form_data.dart';
import 'package:my24app/inventory/models/material/models.dart';
import 'package:my24app/inventory/models/supplier/api.dart';
import 'package:my24app/mobile/models/material/form_data.dart';

class MaterialCreateFormWidget extends StatefulWidget {
  final MaterialFormData? material;
  final AssignedOrderMaterialFormData? assignedOrderMaterialFormData;
  final CoreWidgets widgets;
  final My24i18n i18n;
  final Function supplierCreateCallBack;
  final picker = ImagePicker();

  MaterialCreateFormWidget({
    Key? key,
    this.material,
    this.assignedOrderMaterialFormData,
    required this.widgets,
    required this.i18n,
    required this.supplierCreateCallBack,
  });

  @override
  _MaterialCreateFormWidgetState createState() => _MaterialCreateFormWidgetState();
}

class _MaterialCreateFormWidgetState extends State<MaterialCreateFormWidget> with TextEditingControllerMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nameShortController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController typeAheadControllerSupplier = TextEditingController();
  final SupplierApi supplierApi = SupplierApi();

  @override
  void initState() {
    addTextEditingController(identifierController, widget.material!, 'identifier');
    addTextEditingController(nameController, widget.material!, 'name');
    addTextEditingController(nameShortController, widget.material!, 'nameShort');
    addTextEditingController(supplierController, widget.material!, 'supplier');
    addTextEditingController(typeAheadControllerSupplier, widget.material!, 'typeAheadSupplier');
    super.initState();
  }

  void dispose() {
    disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(14),
        child: Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  widget.widgets.wrapGestureDetector(
                      context,
                      Text(widget.i18n.$trans('info_search_supplier'))
                  ),
                  TypeAheadFormField<SupplierTypeAheadModel>(
                    minCharsForSuggestions: 2,
                    textFieldConfiguration: TextFieldConfiguration(
                        controller: typeAheadControllerSupplier,
                        decoration: InputDecoration(
                          labelText: widget.i18n.$trans(
                              'typeahead_label_search_supplier'),
                          filled: true,
                          fillColor: Colors.white,
                        )
                    ),
                    suggestionsCallback: (String pattern) async {
                      return await supplierApi.typeAhead(pattern);
                    },
                    itemBuilder: (_context, suggestion) {
                      return ListTile(
                        title: Text(suggestion.value!),
                      );
                    },
                    noItemsFoundBuilder: (_context) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.i18n.$trans('info_supplier_not_found')),
                            TextButton(
                              child: Text(
                                  widget.i18n.$trans(
                                      'info_create_new_supplier'),
                                  style: TextStyle(
                                    fontSize: 12,
                                  )
                              ),
                              onPressed: () => widget.supplierCreateCallBack()
                            )
                          ]
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (SupplierTypeAheadModel suggestion) {
                      widget.material!.supplierRelation = suggestion.id!;
                      widget.material!.supplier = suggestion.name!;
                      typeAheadControllerSupplier.text = suggestion.name!;
                      supplierController.text = suggestion.name!;
                      _updateFormData(context);
                    },
                    validator: (value) {
                      return null;
                    },
                  ),

                  widget.widgets.wrapGestureDetector(context, SizedBox(
                    height: 10.0,
                  )),
                  widget.widgets.wrapGestureDetector(
                      context,
                      Text(widget.i18n.$trans('info_supplier'))
                  ),
                  TextFormField(
                      readOnly: true,
                      controller: supplierController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        return null;
                      }
                  ),

                  widget.widgets.wrapGestureDetector(context, SizedBox(
                    height: 10.0,
                  )),
                  widget.widgets.wrapGestureDetector(
                      context,
                      Text(widget.i18n.$trans('info_name'))
                  ),
                  TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        return null;
                      }
                  ),

                  widget.widgets.wrapGestureDetector(context, SizedBox(
                    height: 10.0,
                  )),
                  widget.widgets.wrapGestureDetector(
                      context,
                      Text(widget.i18n.$trans('info_name_short'))
                  ),
                  TextFormField(
                      controller: nameShortController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        // if (value!.isEmpty) {
                        //   return widget.i18n.$trans('validator_postal');
                        // }
                        return null;
                      }
                  ),

                  widget.widgets.wrapGestureDetector(context, SizedBox(
                    height: 10.0,
                  )),
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            widget.widgets.wrapGestureDetector(
                                context,
                                Text(widget.i18n.$trans('info_identifier'))
                            ),
                            TextFormField(
                                controller: identifierController,
                                decoration: InputDecoration(
                                  hintText: widget.i18n.$trans('info_identifier_hint'),
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (value) {
                                  // if (value!.isEmpty) {
                                  //   return widget.i18n.$trans('validator_postal');
                                  // }
                                  return null;
                                }
                            )
                          ],
                        )
                      ),
                      // Expanded(
                      //   flex: 1,
                      //   child: SizedBox(width: 1),
                      // ),
                      Expanded(
                          flex: 2,
                          child: TextButton(
                            child: Text(
                                widget.i18n.$trans('info_scan_barcode'),
                                style: TextStyle(
                                  fontSize: 12,
                                )
                            ),
                            onPressed: () async {
                              // scan barcode
                              var result = await BarcodeScanner.scan();
                              setState(() {
                                identifierController.text = checkNull(result.rawContent);
                              });
                            },
                          )
                      ),
                      // Expanded(
                      //   flex: 2,
                      //   child: FloatingActionButton(
                      //     onPressed: () async {
                      //       // var result = await BarcodeScanner.scan();
                      //       //
                      //       // setState(() {
                      //       //   identifierController.text = result.rawContent;
                      //       // });
                      //     },
                      //     child: const Icon(Icons.camera_alt),
                      //   )
                      // )
                    ],
                  ),

                  widget.widgets.wrapGestureDetector(context, SizedBox(
                    height: 10.0,
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Text(
                            My24i18n.tr('generic.button_choose_image'),
                            style: TextStyle(
                              fontSize: 14,
                            )
                        ),
                        onPressed: () => _openImagePicker(context)
                      ),

                      SizedBox(width: 10),
                      TextButton(
                        child: Text(
                            My24i18n.tr('generic.button_take_picture'),
                            style: TextStyle(
                              fontSize: 14,
                            )
                        ),
                        onPressed: () => _openImageCamera(context)
                      ),
                    ],
                  ),

                  if (widget.material!.imageFile != null)
                    Image.file(
                      widget.material!.imageFile!,
                      width: 300,
                    ),

                  widget.widgets.createSubmitSection(
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            widget.widgets.createCancelButton(
                                () => _cancelCreate(context)
                            ),
                            SizedBox(width: 10),
                            widget.widgets.createSubmitButton(
                                context,
                                () => _submitForm(context)
                            ),
                          ]
                      )
                  )
              ]
          )
        )
    );
  }

  _openImageCamera(BuildContext context) async {
    final pickedFile = await widget.picker.pickImage(
        source: ImageSource.camera);

    if (pickedFile != null) {
      widget.material!.imageFile = await widget.material!.getLocalFile(pickedFile.path);
      _updateFormData(context);
    } else {
      print('No image selected.');
    }
  }

  _openImagePicker(BuildContext context) async {
    final pickedFile = await widget.picker.pickImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      widget.material!.imageFile = await widget.material!.getLocalFile(pickedFile.path);
      _updateFormData(context);
    } else {
      print('No image selected.');
    }
  }

  _cancelCreate(BuildContext context) {
    final bloc = BlocProvider.of<MaterialBloc>(context);
    bloc.add(MaterialEvent(status: MaterialEventStatus.cancelCreate));
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState!.validate()) {
      this._formKey.currentState!.save();

      if (!widget.material!.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<MaterialBloc>(context);
      if (widget.material!.id != null) {
        MaterialModel updatedMaterial = widget.material!.toModel();
        bloc.add(MaterialEvent(status: MaterialEventStatus.doAsync));
        bloc.add(MaterialEvent(
            pk: updatedMaterial.id,
            status: MaterialEventStatus.update,
            material: updatedMaterial,
            assignedOrderMaterialFormData: widget.assignedOrderMaterialFormData
        ));
      } else {
        MaterialModel newMaterial = widget.material!.toModel();
        bloc.add(MaterialEvent(status: MaterialEventStatus.doAsync));
        bloc.add(MaterialEvent(
          status: MaterialEventStatus.insert,
          material: newMaterial,
          assignedOrderMaterialFormData: widget.assignedOrderMaterialFormData
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<MaterialBloc>(context);
    bloc.add(MaterialEvent(status: MaterialEventStatus.doAsync));
    bloc.add(MaterialEvent(
        status: MaterialEventStatus.updateFormData,
        materialFormData: widget.material,
        assignedOrderMaterialFormData: widget.assignedOrderMaterialFormData
    ));
  }
}
