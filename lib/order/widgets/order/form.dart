import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/equipment/models/location/models.dart';
import 'package:my24app/order/models/order/form_data.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/customer/models/api.dart';
import 'package:my24app/company/api/company_api.dart';
import 'package:my24app/equipment/models/equipment/models.dart';
import 'package:my24app/equipment/models/equipment/api.dart';
import 'package:my24app/equipment/models/location/api.dart';

import '../../models/infoline/models.dart';
import '../../models/orderline/models.dart';

class OrderFormWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "orders";
  final OrderFormData? formData;
  final OrderEventStatus fetchEvent;
  final OrderPageMetaData orderPageMetaData;
  final CustomerApi customerApi = CustomerApi();
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  final EquipmentApi equipmentApi = EquipmentApi();
  final EquipmentLocationApi equipmentLocationApi = EquipmentLocationApi();

  final FocusNode equipmentCreateFocusNode = FocusNode();
  final FocusNode equipmentLocationCreateFocusNode = FocusNode();

  OrderFormWidget({
    Key? key,
    required this.orderPageMetaData,
    required this.formData,
    required this.fetchEvent,
  }) : super(
      key: key,
      memberPicture: orderPageMetaData.memberPicture
  );

  bool isPlanning() {
    return orderPageMetaData.submodel == 'planning_user';
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return formData!.id == null ? $trans('form.app_bar_title_insert') : $trans('form.app_bar_title_update');
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    createHeader($trans('header_order_details')),
                    _createOrderForm(context),
                    Divider(),
                    createHeader($trans('header_orderline_form')),
                    _buildOrderlineForm(context),
                    _buildOrderlineSection(context),
                    Divider(),
                    if (!orderPageMetaData.hasBranches! && isPlanning())
                      createHeader($trans('header_infoline_form')),
                    if (!orderPageMetaData.hasBranches! && isPlanning())
                      _buildInfolineForm(context),
                    if (!orderPageMetaData.hasBranches! && isPlanning())
                      _buildInfolineSection(context),
                    if (!orderPageMetaData.hasBranches! && isPlanning())
                      Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    if (!isPlanning())
                      Text(
                        $trans('form.notification_order_date'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.red),
                      ),
                    createSubmitSection(_getButtons(context) as Row)
                  ],
                )
            )
        )
    );
  }

  // private methods
  Widget _getButtons(BuildContext context) {
    if (!orderPageMetaData.hasBranches! && isPlanning() && formData!.id != null && !formData!.customerOrderAccepted!) {
      return Row(
        children: [
          createElevatedButtonColored(
              $trans('form.button_nav_orders'),
              () => _fetchOrders(context)
          ),
          SizedBox(width: 10),
          createDefaultElevatedButton(
              $trans('form.button_accept'),
              () => _doAccept(context)
          ),
          SizedBox(width: 10),
          createElevatedButtonColored(
              $trans('form.button_reject'),
              () => _doReject(context),
              foregroundColor: Colors.white,
              backgroundColor: Colors.red
          )
        ],
      );
    }

    return _createSubmitButton(context);
  }

  Widget _createSubmitButton(BuildContext context) {
    return Row(
        children: [
          Spacer(),
          createCancelButton(() => _fetchOrders(context)),
          SizedBox(width: 10),
          createSubmitButton(() => _doSubmit(context)),
          Spacer(),
        ]
    );
  }

  _fetchOrders(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(status: fetchEvent));
  }

  void _doAccept(BuildContext context) {
    final OrderBloc bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(status: OrderEventStatus.ACCEPT, pk: formData!.id));
  }

  void _doReject(BuildContext context) {
    final OrderBloc bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(status: OrderEventStatus.REJECT, pk: formData!.id));
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);
    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.UPDATE_FORM_DATA,
        formData: formData
    ));
  }

  _createSelectEquipment(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    formData!.isCreatingEquipment = true;
    bloc.add(OrderEvent(
        status: OrderEventStatus.UPDATE_FORM_DATA,
        formData: formData
    ));

    bloc.add(OrderEvent(
        status: OrderEventStatus.CREATE_SELECT_EQUIPMENT,
        formData: formData
    ));
  }

  _createSelectEquipmentLocation(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    formData!.isCreatingLocation = true;
    bloc.add(OrderEvent(
        status: OrderEventStatus.UPDATE_FORM_DATA,
        formData: formData
    ));

    bloc.add(OrderEvent(
        status: OrderEventStatus.CREATE_SELECT_EQUIPMENT_LOCATION,
        formData: formData
    ));
  }

  _selectStartDate(BuildContext context) async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2)
    );

    if (pickedDate != null) {
      formData!.startDate = pickedDate;
      if (!formData!.changedEndDate!) {
        formData!.endDate = pickedDate;
      }
      _updateFormData(context);
    }
  }

  _selectStartTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay(hour: 6, minute: 0);

    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime
    );

    if (pickedTime != null) {
      final DateTime startTime = DateTime(
          formData!.startDate!.year,
          formData!.startDate!.month,
          formData!.startDate!.day,
          pickedTime.hour,
          pickedTime.minute,
      );
      formData!.startTime = startTime;
      _updateFormData(context);
    }
  }

  _selectEndDate(BuildContext context) async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2)
    );

    if (pickedDate != null) {
      formData!.endDate = pickedDate;
      _updateFormData(context);
    }
  }

  _selectEndTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay(hour: 6, minute: 0);

    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime
    );

    if (pickedTime != null) {
      final DateTime endTime = DateTime(
        formData!.startDate!.year,
        formData!.startDate!.month,
        formData!.startDate!.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      formData!.endTime = endTime;
      _updateFormData(context);
    }
  }

  Widget _createOrderForm(BuildContext context) {
    var firstElement;

    // only show the typeahead when creating a new order
    if (!orderPageMetaData.hasBranches!) {
      if (isPlanning() && formData!.id == null) {
        firstElement = _getCustomerTypeAhead(context);
      } else {
        firstElement = _getCustomerNameTextField();
      }
    } else {
      if (isPlanning() && formData!.id == null) {
        firstElement = _getBranchTypeAhead(context);
      } else {
        firstElement = _getBranchNameTextField();
      }
    }

    return Form(key: _formKeys[0], child: Table(
        children: [
          firstElement,
          if (!orderPageMetaData.hasBranches!)
            TableRow(
                children: [
                  wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16),
                      child: Text($trans('info_customer_id', pathOverride: 'generic'),
                          style: TextStyle(fontWeight: FontWeight.bold))
                  )),
                  TextFormField(
                      readOnly: true,
                      controller: formData!.orderCustomerIdController,
                      validator: (value) {
                        return null;
                      }
                  ),
                ]
            ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_customer', pathOverride: 'generic'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.orderNameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return $trans('validator_name', pathOverride: 'generic');
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_address', pathOverride: 'generic'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.orderAddressController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return $trans('validator_address', pathOverride: 'generic');
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_postal', pathOverride: 'generic'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.orderPostalController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return $trans('validator_postal', pathOverride: 'generic');
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_city', pathOverride: 'generic'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.orderCityController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return $trans('validator_city', pathOverride: 'generic');
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_country_code', pathOverride: 'generic'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                DropdownButtonFormField<String>(
                  value: formData!.orderCountryCode,
                  items: ['NL', 'BE', 'LU', 'FR', 'DE'].map((String value) {
                    return new DropdownMenuItem<String>(
                      child: new Text(value),
                      value: value,
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    formData!.orderCountryCode = newValue;
                    _updateFormData(context);
                  },
                )
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_contact', pathOverride: 'generic'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                Container(
                    width: 300.0,
                    child: TextFormField(
                      controller: formData!.orderContactController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    )
                ),
              ]
          ),
          TableRow(
              children: [
                Divider(),
                SizedBox(height: 10,)
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_start_date'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                createElevatedButtonColored(
                    utils.formatDateDDMMYYYY(formData!.startDate!),
                    () => _selectStartDate(context),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black)
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_start_time'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                createElevatedButtonColored(
                    formData!.startTime != null ? utils.timeNoSeconds(utils.formatTime(formData!.startTime!.toLocal())) : '',
                    () => _selectStartTime(context),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black)
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_end_date'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                createElevatedButtonColored(
                    utils.formatDateDDMMYYYY(formData!.endDate!),
                    () => _selectEndDate(context),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black)
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_end_time'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                createElevatedButtonColored(
                    formData!.endTime != null ? utils.timeNoSeconds(utils.formatTime(formData!.endTime!.toLocal())) : '',
                    () => _selectEndTime(context),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black)
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_order_type'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                DropdownButtonFormField<String>(
                  value: formData!.orderType,
                  items: formData!.orderTypes == null ? [] : formData!.orderTypes!.orderTypes!.map((String value) {
                    return new DropdownMenuItem<String>(
                      child: new Text(value),
                      value: value,
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != formData!.orderType) {
                      formData!.orderType = newValue;
                      _updateFormData(context);

                    }
                  },
                )
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_order_reference'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.orderReferenceController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_order_email'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.orderEmailController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_order_mobile'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.orderMobileController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_order_tel'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.orderTelController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16), child: Text(
                    $trans('info_order_customer_remarks'),
                    style: TextStyle(fontWeight: FontWeight.bold))
                )),
                Container(
                    width: 300.0,
                    child: TextFormField(
                      controller: formData!.customerRemarksController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    )
                ),
              ]
          ),
        ]
    ));
  }

  Widget _buildOrderlineForm(BuildContext context) {
    if (orderPageMetaData.hasBranches!) {
      return _buildOrderlineFormEquipment(context);
    }

    return _buildOrderlineFormNoBranch(context);
  }

  Widget _getLocationsPart(BuildContext context) {
    if ((isPlanning() && formData!.equipmentLocationPlanningQuickCreate!) ||
        (!isPlanning() && formData!.equipmentLocationQuickCreate!)) {
      return Column(
        children: [
          TypeAheadFormField<EquipmentLocationTypeAheadModel>(
            minCharsForSuggestions: 2,
            textFieldConfiguration: TextFieldConfiguration(
                controller: formData!.orderlineFormData!.typeAheadControllerEquipmentLocation,
                decoration: InputDecoration(
                    labelText:
                    $trans('form.typeahead_label_search_location')
                )
            ),
            suggestionsCallback: (String pattern) async {
              return await equipmentLocationApi.locationTypeAhead(pattern, formData!.branch);
            },
            itemBuilder: (context, suggestion) {
              String text = suggestion.identifier != null && suggestion.identifier != '' ?
              '${suggestion.name} (${suggestion.identifier})' :
              '${suggestion.name}';
              return ListTile(
                title: Text(text),
              );
            },
            noItemsFoundBuilder: (_context) {
              return Expanded(
                  child: Column(
                    children: [
                      Text($trans('form.location_not_found'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey
                          )
                      ),
                      TextButton(
                        child: Text(
                            $trans('form.create_new_location'),
                            style: TextStyle(
                              fontSize: 12,
                            )
                        ),
                        onPressed: () {
                          // create new location
                          FocusScope.of(context).requestFocus(equipmentLocationCreateFocusNode);
                          _createSelectEquipmentLocation(context);
                        },
                      )
                    ]
                )
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (EquipmentLocationTypeAheadModel suggestion) {
              formData!.orderlineFormData!.equipmentLocation = suggestion.id;
              formData!.orderlineFormData!.locationController!.text = suggestion.name!;
              _updateFormData(context);
            },
            validator: (value) {
              return null;
            },
          ),
          wrapGestureDetector(context, SizedBox(
            height: 10.0,
          )),

          Visibility(
              visible: formData!.isCreatingLocation!,
              child: Text(
                $trans('form.adding_location'),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.red
                ),
              )
          ),
          Visibility(
              visible: !formData!.isCreatingLocation!,
              child:
              SizedBox(
                  width: 400,
                  child: Row(
                    children: [
                      SizedBox(width: 290,
                        child: TextFormField(
                          controller: formData!.orderlineFormData!.locationController,
                          keyboardType: TextInputType.text,
                          focusNode: equipmentLocationCreateFocusNode,
                          readOnly: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return $trans('form.validator_location');
                            }
                            return null;
                          }
                        )
                      ),
                      SizedBox(width: 10),
                      Visibility(
                        visible: formData!.orderlineFormData!.equipmentLocation != null,
                        child: Icon(
                          Icons.check,
                          color: Colors.blue,
                          size: 24.0,
                        ),
                      )
                    ],
                  )
              )
          ),

        ],
      );
    }

    return DropdownButtonFormField<String>(
      value: "${formData!.orderlineFormData!.equipmentLocation}",
      items: formData!.locations == null
          ? []
          : formData!.locations!.map((EquipmentLocation location) {
        return new DropdownMenuItem<String>(
          child: Text(location.name!),
          value: "${location.id}",
        );
      }).toList(),
      onChanged: (String? locationId) {
        formData!.orderlineFormData!.equipmentLocation = int.parse(locationId!);
        EquipmentLocation location = formData!.locations!.firstWhere(
                (_location) => _location.id == formData!.orderlineFormData!.equipmentLocation);
        formData!.orderlineFormData!.locationController!.text = location.name!;
        _updateFormData(context);
      }
    );
  }

  Widget _buildOrderlineFormEquipment(BuildContext context) {
    return Form(key: _formKeys[1], child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        wrapGestureDetector(context, Text($trans('info_equipment', pathOverride: 'generic'))),
        TypeAheadFormField<EquipmentTypeAheadModel>(
          minCharsForSuggestions: 2,
          textFieldConfiguration: TextFieldConfiguration(
              controller: formData!.orderlineFormData!.typeAheadControllerEquipment,
              decoration: InputDecoration(
                  labelText:
                  $trans('form.typeahead_label_search_equipment')
              )
          ),
          suggestionsCallback: (String pattern) async {
            return await equipmentApi.equipmentTypeAhead(pattern, formData!.branch);
          },
          itemBuilder: (context, suggestion) {
            String text = suggestion.identifier != null && suggestion.identifier != '' ?
              '${suggestion.name} (${suggestion.identifier})' :
              '${suggestion.name}';
            return ListTile(
              title: Text(text),
            );
          },
          noItemsFoundBuilder: (_context) {
            return Container(
                child: Expanded(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text($trans('form.equipment_not_found'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey
                          )
                      ),
                      if ((isPlanning() && formData!.equipmentPlanningQuickCreate!) ||
                        (!isPlanning() && formData!.equipmentQuickCreate!))
                        TextButton(
                          child: Text(
                              $trans('form.create_new_equipment'),
                              style: TextStyle(
                                fontSize: 12,
                              )
                          ),
                          onPressed: () {
                            // create new equipment
                            FocusScope.of(context).requestFocus(equipmentCreateFocusNode);
                            _createSelectEquipment(context);
                          },
                        )
                    ]
                  )
                )
              );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          onSuggestionSelected: (EquipmentTypeAheadModel suggestion) {
            formData!.orderlineFormData!.equipment = suggestion.id!;
            formData!.orderlineFormData!.productController!.text = suggestion.name!;

            // fill location if this is set and known
            if (suggestion.location != null) {
              formData!.orderlineFormData!.equipmentLocation = suggestion.location!.id;
              formData!.orderlineFormData!.locationController!.text = suggestion.location!.name!;
            }
            _updateFormData(context);
          },
          validator: (value) {
            return null;
          },
        ),

        wrapGestureDetector(context, SizedBox(
          height: 10.0,
        )),

        Visibility(
          visible: formData!.isCreatingEquipment!,
          child: Text(
            $trans('form.adding_equipment'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.red
            ),
          )
        ),
        Visibility(
          visible: !formData!.isCreatingEquipment!,
          child:
            SizedBox(
              width: 400,
              child: Row(
              children: [
                SizedBox(width: 290,
                    child: TextFormField(
                      controller: formData!.orderlineFormData!.productController,
                      keyboardType: TextInputType.text,
                      focusNode: equipmentCreateFocusNode,
                      readOnly: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return $trans('form.validator_equipment');
                        }
                        return null;
                      }
                  )
                ),
                SizedBox(width: 10),
                Visibility(
                    visible: formData!.orderlineFormData!.equipment != null,
                    child: Icon(
                      Icons.check,
                      color: Colors.blue,
                      size: 24.0,
                    ),
                )
              ],
            )
          )
        ),
        SizedBox(
          height: 10.0,
        ),

        wrapGestureDetector(context, Text($trans('info_location', pathOverride: 'generic'))),
        _getLocationsPart(context),

        wrapGestureDetector(context, SizedBox(
          height: 10.0,
        )),

        wrapGestureDetector(context, Text($trans('info_remarks', pathOverride: 'generic'))),
        TextFormField(
            controller: formData!.orderlineFormData!.remarksController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        createElevatedButtonColored(
            $trans('form.button_add_orderline'),
            () { _addOrderLineEquipment(context); }
        )
      ],
    ));
  }

  Widget _buildOrderlineFormNoBranch(BuildContext context) {
    return Form(key: _formKeys[1], child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        wrapGestureDetector(context, Text($trans('info_equipment', pathOverride: 'generic'))),
        TextFormField(
            controller: formData!.orderlineFormData!.productController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value!.isEmpty) {
                return $trans('form.validator_equipment');
              }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        wrapGestureDetector(context, Text($trans('info_location', pathOverride: 'generic'))),
        TextFormField(
            controller: formData!.orderlineFormData!.locationController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        wrapGestureDetector(context, Text($trans('info_remarks', pathOverride: 'generic'))),
        TextFormField(
            controller: formData!.orderlineFormData!.remarksController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        createElevatedButtonColored(
            $trans('form.button_add_orderline'),
            () { _addOrderLine(context); }
        )
      ],
    ));
  }

  void _addOrderLine(BuildContext context) {
    if (this._formKeys[1].currentState!.validate()) {
      this._formKeys[1].currentState!.save();

      Orderline orderline = formData!.orderlineFormData!.toModel();

      formData!.orderLines!.add(orderline);

      formData!.orderlineFormData!.remarksController!.text = '';
      formData!.orderlineFormData!.locationController!.text = '';
      formData!.orderlineFormData!.productController!.text = '';

      _updateFormData(context);
    } else {
      displayDialog(context,
          $trans('error_dialog_title', pathOverride: 'generic'),
          $trans('form.error_adding_orderline')
      );
    }
  }

  void _addOrderLineEquipment(BuildContext context) {
    if (this._formKeys[1].currentState!.validate() && formData!.orderlineFormData!.equipment != null &&
        formData!.orderlineFormData!.equipmentLocation != null) {
      this._formKeys[1].currentState!.save();

      // fill location text from selected location
      if (formData!.orderlineFormData!.locationController!.text == '') {
        EquipmentLocation location = formData!.locations!.firstWhere(
            (_location) => _location.id == formData!.orderlineFormData!.equipmentLocation
        );

        formData!.orderlineFormData!.locationController!.text = location.name!;
      }

      Orderline orderline = formData!.orderlineFormData!.toModel();

      formData!.orderLines!.add(orderline);

      formData!.orderlineFormData!.remarksController!.text = '';
      formData!.orderlineFormData!.locationController!.text = '';
      formData!.orderlineFormData!.productController!.text = '';
      formData!.orderlineFormData!.typeAheadControllerEquipment!.text = '';
      formData!.orderlineFormData!.typeAheadControllerEquipmentLocation!.text = '';
      formData!.orderlineFormData!.equipment = null;
      formData!.orderlineFormData!.equipmentLocation = null;

      _updateFormData(context);
    } else {
      displayDialog(context,
          $trans('error_dialog_title', pathOverride: 'generic'),
          $trans('form.error_adding_orderline')
      );
    }
  }

  Widget _buildOrderlineSection(BuildContext context) {
    return buildItemsSection(
        context,
        $trans('header_orderlines'),
        formData!.orderLines,
        (item) {
          String equipmentLocationTitle = "${$trans('info_equipment', pathOverride: 'generic')} / ${$trans('info_location', pathOverride: 'generic')}";
          String equipmentLocationValue = "${item.product} / ${item.location}";
          return <Widget>[
            ...buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
            ...buildItemListKeyValueList($trans('info_remarks', pathOverride: 'generic'), item.remarks)
          ];
        },
        (Orderline item) {
          return <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createDeleteButton(
                    $trans('form.button_delete_orderline'),
                    () { _showDeleteDialogOrderline(context, item); }
                )
              ],
            )
          ];
        }
    );
  }

  Widget _buildInfolineForm(BuildContext context) {
    return Form(key: _formKeys[2], child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        wrapGestureDetector(context, Text($trans('info_infoline'))),
        TextFormField(
            controller: formData!.infolineFormData!.infoController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              if (value!.isEmpty) {
                return $trans('form.validator_infoline');
              }

              return null;
            }
        ),
        SizedBox(
          height: 10.0,
        ),
        createElevatedButtonColored(
            $trans('form.button_add_infoline'),
            () { _addInfoLine(context); }
        )
      ],
    ));
  }

  void _addInfoLine(BuildContext context) {
    if (this._formKeys[2].currentState!.validate()) {
      this._formKeys[2].currentState!.save();

      Infoline infoline = formData!.infolineFormData!.toModel();

      formData!.infoLines!.add(infoline);

      // reset fields
      formData!.infolineFormData!.infoController!.text = '';
      _updateFormData(context);
    } else {
      displayDialog(context,
          $trans('error_dialog_title', pathOverride: 'generic'),
          $trans('form.error_adding_infoline')
      );
    }
  }

  Widget _buildInfolineSection(BuildContext context) {
    return buildItemsSection(
        context,
        $trans('header_infolines'),
        formData!.infoLines,
        (item) {
          return buildItemListKeyValueList($trans('info_infoline'), item.info);
        },
        (Infoline item) {
          return <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createDeleteButton(
                    $trans('form.button_delete_infoline'),
                    () { _showDeleteDialogInfoline(context, item); }
                )
              ],
            )
          ];
        }
    );
  }

  _deleteOrderLine(BuildContext context, Orderline orderLine) {
    if (orderLine.id != null && formData!.deletedOrderLines!.indexOf(orderLine) == -1) {
      formData!.deletedOrderLines!.add(orderLine);
    }
    formData!.orderLines!.removeAt(formData!.orderLines!.indexOf(orderLine));
    _updateFormData(context);
  }

  _showDeleteDialogOrderline(BuildContext context, Orderline orderLine) {
    showDeleteDialogWrapper(
        $trans('form.delete_dialog_title_orderline'),
        $trans('form.delete_dialog_content_orderline'),
        () => _deleteOrderLine(context, orderLine),
        context
    );
  }

  _deleteInfoLine(BuildContext context, Infoline infoline) {
    if (infoline.id != null && formData!.deletedInfoLines!.indexOf(infoline) == -1) {
      formData!.deletedInfoLines!.add(infoline);
    }

    formData!.infoLines!.removeAt(formData!.infoLines!.indexOf(infoline));
    _updateFormData(context);
  }

  _showDeleteDialogInfoline(BuildContext context, Infoline infoline) {
    showDeleteDialogWrapper(
        $trans('form.delete_dialog_title_infoline'),
        $trans('form.delete_dialog_content_infoline'),
        () => _deleteInfoLine(context, infoline),
        context
    );
  }

  // only show when a planning user is entering an order
  TableRow _getCustomerTypeAhead(BuildContext context) {
    return TableRow(
        children: [
          Padding(padding: EdgeInsets.only(top: 16),
              child: Text($trans('form.label_search_customer'),
                  style: TextStyle(fontWeight: FontWeight.bold))),

          TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
                controller: formData!.typeAheadControllerCustomer,
                decoration: InputDecoration(
                    labelText: $trans('form.typeahead_label_search_customer')
                )
            ),
            suggestionsCallback: (pattern) async {
              return await customerApi.customerTypeAhead(pattern);
            },
            itemBuilder: (context, dynamic suggestion) {
              return ListTile(
                title: Text(suggestion.value),
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (dynamic suggestion) {
              formData!.typeAheadControllerCustomer!.text = '';

              // fill fields
              formData!.customerPk = suggestion.id;
              formData!.customerId = suggestion.customerId;
              formData!.orderCustomerIdController!.text = suggestion.customerId;
              formData!.orderNameController!.text = suggestion.name;
              formData!.orderAddressController!.text = suggestion.address;
              formData!.orderPostalController!.text = suggestion.postal;
              formData!.orderCityController!.text = suggestion.city;
              formData!.orderCountryCode = suggestion.countryCode;
              formData!.orderTelController!.text = suggestion.tel;
              formData!.orderMobileController!.text = suggestion.mobile;
              formData!.orderEmailController!.text = suggestion.email;
              formData!.orderContactController!.text = suggestion.contact;

              _updateFormData(context);
            },
            validator: (value) {
              return null;
            },
            onSaved: (value) => {

            },
          )
        ]
    );
  }

  TableRow _getCustomerNameTextField() {
    return TableRow(
        children: [
          SizedBox(height: 1),
          SizedBox(height: 1),
        ]
    );
  }

  // only show when a planning user is entering an order and not branch
  TableRow _getBranchTypeAhead(BuildContext context) {
    return TableRow(
        children: [
          Padding(padding: EdgeInsets.only(top: 16),
              child: Text(
                  $trans('form.label_search_branch'),
                  style: TextStyle(fontWeight: FontWeight.bold)
              )
          ),
          TypeAheadFormField<dynamic>(
            textFieldConfiguration: TextFieldConfiguration(
                controller: formData!.typeAheadControllerBranch,
                decoration: InputDecoration(
                    labelText: $trans('form.typeahead_label_search_branch')
                  ),
            ),
            suggestionsCallback: (pattern) async {
              return await companyApi.branchTypeAhead(pattern);
            },
            itemBuilder: (context, dynamic suggestion) {
              return ListTile(
                title: Text(suggestion.value),
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (branch) {
              formData!.typeAheadControllerBranch!.text = '';

              // fill fields
              formData!.branch = branch.id;
              formData!.orderNameController!.text = branch.name!;
              formData!.orderAddressController!.text = branch.address!;
              formData!.orderPostalController!.text = branch.postal!;
              formData!.orderCityController!.text = branch.city!;
              formData!.orderCountryCode = branch.countryCode;
              formData!.orderTelController!.text = branch.tel!;
              formData!.orderMobileController!.text = branch.mobile!;
              formData!.orderEmailController!.text = branch.email!;
              formData!.orderContactController!.text = branch.contact!;

              _updateFormData(context);
            },
            validator: (value) {
              return null;
            },
            onSaved: (value) => {

            },
          )
        ]
    );
  }

  TableRow _getBranchNameTextField() {
    return TableRow(
        children: [
          SizedBox(height: 1),
          SizedBox(height: 1),
        ]
    );
  }

  Future<void> _doSubmit(BuildContext context) async {
    if (this._formKeys[0].currentState!.validate()) {
      if (!formData!.isValid()) {
        if (formData!.orderType == null) {
          displayDialog(context,
              $trans('form.validator_ordertype_dialog_title'),
              $trans('form.validator_ordertype_dialog_content')
          );

          return;
        }
      }

      this._formKeys[0].currentState!.save();

      final bloc = BlocProvider.of<OrderBloc>(context);
      if (formData!.id != null) {
        Order updatedOrder = formData!.toModel();
        bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
        bloc.add(OrderEvent(
          pk: updatedOrder.id,
          status: OrderEventStatus.UPDATE,
          order: updatedOrder,
          orderLines: formData!.orderLines,
          infoLines: formData!.infoLines,
          deletedOrderLines: formData!.deletedOrderLines!,
          deletedInfoLines: formData!.deletedInfoLines!,
        ));
      } else {
        if (!orderPageMetaData.hasBranches! && orderPageMetaData.submodel == 'planning_user') {
          formData!.customerOrderAccepted = true;
        }
        Order newOrder = formData!.toModel();
        bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
        bloc.add(OrderEvent(
          status: OrderEventStatus.INSERT,
          order: newOrder,
          orderLines: formData!.orderLines,
          infoLines: formData!.infoLines,
        ));
      }
    }
  }

}
