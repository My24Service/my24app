import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/inventory/models/supplier/models.dart';
import 'package:my24app/inventory/blocs/supplier_bloc.dart';
import 'package:my24app/inventory/models/supplier/form_data.dart';

import '../../models/material/form_data.dart';

class SupplierCreateFormWidget extends StatefulWidget {
  final SupplierFormData? supplier;
  final CoreWidgets widgets;
  final My24i18n i18n;
  final MaterialFormData? materialFormData;

  SupplierCreateFormWidget({
    Key? key,
    this.supplier,
    required this.widgets,
    required this.i18n,
    this.materialFormData
  });

  @override
  _SupplierCreateFormWidgetState createState() => _SupplierCreateFormWidgetState();
}

class _SupplierCreateFormWidgetState extends State<SupplierCreateFormWidget> with TextEditingControllerMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController postalController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    addTextEditingController(nameController, widget.supplier!, 'name');
    addTextEditingController(addressController, widget.supplier!, 'address');
    addTextEditingController(postalController, widget.supplier!, 'postal');
    addTextEditingController(countryCodeController, widget.supplier!, 'country_code');
    addTextEditingController(cityController, widget.supplier!, 'city');
    super.initState();
  }

  void dispose() {
    disposeAll();
    super.dispose();
  }

  void _fillTextControllers() {
    addressController.text = checkNull(widget.supplier!.address);
    postalController.text = checkNull(widget.supplier!.postal);
    cityController.text = checkNull(widget.supplier!.city);
  }

  @override
  Widget build(BuildContext context) {
    _fillTextControllers();

    return Container(
        padding: const EdgeInsets.all(14),
        child: Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  widget.widgets.wrapGestureDetector(
                      context,
                      Text(widget.i18n.$trans('info_name'))
                  ),
                  TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return widget.i18n.$trans('validator_name');
                        }

                        return null;
                      }
                  ),

                  widget.widgets.wrapGestureDetector(context, SizedBox(
                    height: 10.0,
                  )),
                  TextButton(
                    child: Text(
                        widget.i18n.$trans(
                            'info_address_from_gps'),
                        style: TextStyle(
                          fontSize: 12,
                        )
                    ),
                    onPressed: () {
                      _addressFromGps(context);
                    },
                  ),

                  widget.widgets.wrapGestureDetector(context, SizedBox(
                    height: 10.0,
                  )),
                  widget.widgets.wrapGestureDetector(
                      context,
                      Text(widget.i18n.$trans('info_address'))
                  ),
                  TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: addressController,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return widget.i18n.$trans('validator_address');
                        }

                        return null;
                      }
                  ),

                  widget.widgets.wrapGestureDetector(context, SizedBox(
                    height: 10.0,
                  )),
                  widget.widgets.wrapGestureDetector(
                      context,
                      Text(widget.i18n.$trans('info_city'))
                  ),
                  TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return widget.i18n.$trans('validator_city');
                        }
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
                                Text(widget.i18n.$trans('info_postal'))
                            ),
                            TextFormField(
                                controller: postalController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return widget.i18n.$trans('validator_postal');
                                  }
                                  return null;
                                }
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(width: 1),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            widget.widgets.wrapGestureDetector(
                                context,
                                Text(widget.i18n.$trans('info_country'))
                            ),
                            DropdownButtonFormField<String>(
                              value: widget.supplier!.country_code,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: ['NL', 'BE', 'LU', 'FR', 'DE'].map((String value) {
                                return new DropdownMenuItem<String>(
                                  child: new Text(value),
                                  value: value,
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                widget.supplier!.country_code = newValue;
                                _updateFormData(context);
                              },
                            )
                          ],
                        ),
                      ),

                    ],
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

  _cancelCreate(BuildContext context) {
    final bloc = BlocProvider.of<SupplierBloc>(context);
    bloc.add(SupplierEvent(status: SupplierEventStatus.cancelCreate));
  }

  _addressFromGps(BuildContext context) {
    final bloc = BlocProvider.of<SupplierBloc>(context);
    bloc.add(SupplierEvent(status: SupplierEventStatus.doAsync));
    bloc.add(SupplierEvent(
      status: SupplierEventStatus.getAddressFromLocation,
      supplierFormData: widget.supplier
    ));
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState!.validate()) {
      this._formKey.currentState!.save();

      if (!widget.supplier!.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<SupplierBloc>(context);
      if (widget.supplier!.id != null) {
        Supplier updatedSupplier = widget.supplier!.toModel();
        bloc.add(SupplierEvent(status: SupplierEventStatus.doAsync));
        bloc.add(SupplierEvent(
          pk: updatedSupplier.id,
          status: SupplierEventStatus.update,
          supplier: updatedSupplier,
          materialFormData: widget.materialFormData!
        ));
      } else {
        Supplier newSupplier = widget.supplier!.toModel();
        bloc.add(SupplierEvent(status: SupplierEventStatus.doAsync));
        bloc.add(SupplierEvent(
          status: SupplierEventStatus.insert,
          supplier: newSupplier,
          materialFormData: widget.materialFormData!
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<SupplierBloc>(context);
    bloc.add(SupplierEvent(status: SupplierEventStatus.doAsync));
    bloc.add(SupplierEvent(
        status: SupplierEventStatus.updateFormData,
        supplierFormData: widget.supplier
    ));
  }
}
