import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_core/widgets/slivers/app_bars.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_equipment/models/location/models.dart';
import 'package:my24_flutter_orders/blocs/orderline_bloc.dart';
import 'package:my24_flutter_orders/blocs/orderline_states.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/models/orderline/form_data.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';
import 'package:my24_flutter_orders/blocs/order_form_bloc.dart';
import 'package:my24_flutter_orders/widgets/form/documents.dart';
import 'package:my24_flutter_orders/widgets/form/orderline_equipment.dart';

import '../blocs/order_form_bloc.dart';
import '../models/form_data.dart';

final log = Logger('orders.widgets.form_from_equipment');

class OrderFormFromEquipmentWidget extends StatelessWidget {
  final OrderFormData formData;
  final CoreWidgets widgets;
  final i18n = My24i18n(basePath: "orders.form");
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final OrderPageMetaData orderPageMetaData;
  final OrderlineFormData orderlineFormData;
  final bool isPlanning;

  OrderFormFromEquipmentWidget({
    super.key,
    required this.formData,
    required this.widgets,
    required this.orderlineFormData,
    required this.isPlanning,
    required this.orderPageMetaData
  });

  String getAppBarTitle(BuildContext context) {
    return i18n.$trans('app_bar_title_insert_from_equipment',
        namedArgs: {'orderType': formData.orderType!});
  }

  SliverAppBar getAppBar(BuildContext context) {
    SmallAppBarFactory factory = SmallAppBarFactory(
        context: context,
        title: getAppBarTitle(context)
    );
    return factory.createAppBar();
  }

  @override
  Widget build(BuildContext context) {
    final orderFormBloc = BlocProvider.of<OrderFormBloc>(context);
    return Scaffold(
        body: CustomScrollView(
            slivers: <Widget>[
              getAppBar(context),
              SliverToBoxAdapter(
                  child: Form(
                      key: formKey,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 10
                          ),
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OrderlineForm(
                                    formData: formData,
                                    widgets: widgets,
                                    i18n: i18n,
                                    isPlanning: isPlanning,
                                    hasBranches: true,
                                  ),
                                  const SizedBox(height: 20),
                                  DocumentsWidget(
                                    formData: formData,
                                    widgets: widgets,
                                    orderId: null,
                                    onlyPictures: true,
                                    bloc: orderFormBloc,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  widgets.createSubmitButton(
                                      context,
                                      () => _addOrder(context)
                                  ),
                                ],
                              )
                          )
                      )
                  )
              )
            ]
        )
    );
  }

  _addOrder(BuildContext context) {
    if (formKey.currentState!.validate() && orderlineFormData.equipment != null &&
        orderlineFormData.equipmentLocation != null) {
      formKey.currentState!.save();

      Order newOrder = formData.toModel();
      Orderline orderline = orderlineFormData.toModel();

      final orderFormBloc = BlocProvider.of<OrderFormBloc>(context);
      orderFormBloc.add(const OrderFormEvent(status: OrderFormEventStatus.doAsync));
      orderFormBloc.add(OrderFormEvent(
          status: OrderFormEventStatus.insert,
          order: newOrder,
          orderLines: [orderline],
          infoLines: [],
          documents: formData.documents,
      ));
    } else {
      log.severe("error creating order; equipment: ${orderlineFormData.equipment}, "
          "equipment location: ${orderlineFormData.equipmentLocation}");
      widgets.displayDialog(context,
          My24i18n.tr('generic.error_dialog_title'),
          i18n.$trans('error_adding')
      );
    }
  }
}

class MainFormFromEquipmentWidget extends StatefulWidget {
  final OrderFormData formData;
  final CoreWidgets widgets;
  final My24i18n i18n;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final OrderlineFormData orderlineFormData;
  final bool isPlanning;

  MainFormFromEquipmentWidget({
    super.key,
    required this.formData,
    required this.widgets,
    required this.i18n,
    required this.orderlineFormData,
    required this.isPlanning
  });

  @override
  State<StatefulWidget> createState() => _MainFormFromEquipmentWidgetState();
}

class _MainFormFromEquipmentWidgetState extends State<MainFormFromEquipmentWidget> {
  final TextEditingController remarksController = TextEditingController();
  bool setLocationToEquipment = false;
  final FocusNode remarksTextFocus = FocusNode();
  bool hasChanges = false;

  @override
  void dispose() {
    super.dispose();
    remarksController.dispose();
    remarksTextFocus.dispose();
  }

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  String getAppBarTitle(BuildContext context) {
    return widget.i18n.$trans('app_bar_title_insert_from_equipment',
        namedArgs: {'orderType': widget.formData.orderType!});
  }

  SliverAppBar getAppBar(BuildContext context) {
    SmallAppBarFactory factory = SmallAppBarFactory(
        context: context, title: getAppBarTitle(context));
    return factory.createAppBar();
  }

  @override
  Widget build(BuildContext context) {
    remarksController.text = checkNull(widget.orderlineFormData.remarks);

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
        child: Column(
          children: [
            widget.widgets.createHeader(widget.i18n.$trans('header_order_details')),
            widget.widgets.wrapGestureDetector(
                context,
                Text(My24i18n.tr('generic.info_equipment'))
            ),
            Text(widget.orderlineFormData.product!),

            const SizedBox(height: 20),
            widget.widgets.wrapGestureDetector(
                context,
                Text(My24i18n.tr('generic.info_location'))
            ),
            if (widget.orderlineFormData.equipmentLocation == null)
              LocationsPart<OrderFormData>(
                formData: widget.formData,
                widgets: widget.widgets,
                canCreateLocation: _canCreateLocation(),
                orderlineFormData: widget.orderlineFormData,
                onLocationSelected: _onLocationSelected
              ),
            if (widget.orderlineFormData.equipmentLocation != null)
              Text(widget.orderlineFormData.location!),

            const SizedBox(height: 20),
            widget.widgets.wrapGestureDetector(
                context,
                Text(My24i18n.tr('generic.info_remarks'))
            ),
            Text("Location: ${widget.orderlineFormData.equipmentLocation}"),
            TextFormField(
              controller: remarksController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              focusNode: remarksTextFocus,
              validator: (value) {
                return null;
              }
            ),
          ]
        )
    );
  }

  _canCreateLocation() {
    return (widget.isPlanning && widget.formData.quickCreateSettings!.equipmentLocationPlanningQuickCreate) ||
        (!widget.isPlanning && widget.formData.quickCreateSettings!.equipmentLocationQuickCreate);
  }

  _onLocationSelected(EquipmentLocationTypeAheadModel suggestion) {
    widget.orderlineFormData.equipmentLocation = suggestion.id!;
    widget.orderlineFormData.location = suggestion.name!;
    hasChanges = true;
    _updateFormData();
    setState(() {
    });
  }

  _addListeners() {
    remarksController.addListener(_remarksListen);
    remarksTextFocus.addListener(() {
      if (hasChanges) {
        _updateFormData();
      }
      setState(() {

      });
    });
  }

  void _updateFormData() {
    Orderline orderline = widget.orderlineFormData.toModel();
    widget.formData.orderLines![0] = orderline;

    final orderFormBloc = BlocProvider.of<OrderFormBloc>(context);
    orderFormBloc.add(OrderFormEvent(
      status: OrderFormEventStatus.updateFormData,
      formData: widget.formData
    ));
  }

  void _remarksListen() {
    if (remarksController.text.isEmpty) {
      widget.orderlineFormData.remarks = "";
    } else {
      hasChanges = true;
      widget.orderlineFormData.remarks = remarksController.text;
    }
  }

}

class OrderlineForm extends StatelessWidget {
  final OrderFormData formData;
  final CoreWidgets widgets;
  final bool isPlanning;
  final bool hasBranches;
  final My24i18n i18n;

  const OrderlineForm({
    super.key,
    required this.formData,
    required this.widgets,
    required this.isPlanning,
    required this.hasBranches,
    required this.i18n
  });

  @override
  Widget build(BuildContext context) {
    log.info("build orderline form");

    return BlocProvider(
        create: (context) => _initialCall(context),
        child: BlocConsumer<OrderLineBloc, OrderLineBaseState>(
            listener: (context, state) {
              _handleListeners(context, state);
            },
            builder: (context, state) {
              return _getBody(context, state);
            }
        )
    );
  }

  OrderLineBloc _initialCall(BuildContext context) {
    final bloc = OrderLineBloc();
    bloc.add(OrderLineEvent(
        status: OrderLineStatus.loadFormData,
        formData: OrderlineFormData.createFromModel(formData.orderLines![0]),
        order: formData.id
    ));

    return bloc;
  }

  _handleListeners(context, state) {
    log.info("orderline form _handleListeners state: $state");

    if (state is OrderLineErrorSnackbarState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans(
            'error_arg', pathOverride: 'generic',
            namedArgs: {'error': "${state.message}"}
        ));
      }
    }

    if (state is OrderLineNewEquipmentCreatedState) {
      widgets.createSnackBar(context, i18n.$trans('equipment_created'));
    }

    if (state is OrderLineNewLocationCreatedState) {
      widgets.createSnackBar(context, i18n.$trans('location_created'));
    }
  }

  Widget _getBody(context, state) {
    log.info("orderline form _getBody state: $state");

    if (state is OrderLineLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is OrderLineNewFormDataState || state is OrderLineLoadedState ||
        state is OrderLineNewEquipmentCreatedState || state is OrderLineNewLocationCreatedState
    ) {
      if (hasBranches || formData.customerBranchId != null) {
        return MainFormFromEquipmentWidget(
          formData: formData,
          widgets: widgets,
          isPlanning: isPlanning,
          orderlineFormData: state.formData,
          i18n: i18n,
        );
      }
    }

    return widgets.loadingNotice();
  }
}
