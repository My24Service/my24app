import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/blocs/order_form_bloc.dart';

import 'package:my24_flutter_orders/blocs/order_states.dart';
import 'package:my24_flutter_orders/models/order/models.dart';

import 'package:my24_flutter_orders/blocs/order_form_states.dart';
import 'package:my24_flutter_orders/models/orderline/form_data.dart';
import 'package:my24_flutter_orders/widgets/form/error.dart';

import '../blocs/order_form_bloc.dart';
import '../widgets/form_from_equipment.dart';
import 'detail.dart';

final log = Logger('orders.pages.form_from_equipment');

Future sleep1() {
  return Future.delayed(const Duration(seconds: 1), () => "1");
}

class OrderFormFromEquipmentPage extends StatelessWidget {
  final i18n = My24i18n(basePath: "orders");
  final CoreWidgets widgets = CoreWidgets();
  final CoreUtils utils = CoreUtils();
  final OrderFormBloc? bloc; // this bloc is here so we can use a custom bloc in tests
  final String equipmentUuid;
  final String equipmentOrderType;

  OrderFormFromEquipmentPage({
    super.key,
    required this.equipmentUuid,
    required this.equipmentOrderType,
    this.bloc
  });

  Future<OrderPageMetaData?> getOrderPageMetaData(BuildContext context) async {
    String? submodel = await utils.getUserSubmodel();
    String? memberPicture = await utils.getMemberPicture();

    return OrderPageMetaData(
        submodel: submodel,
        firstName: await utils.getFirstName(),
        memberPicture: memberPicture,
        pageSize: 20,
        hasBranches: true
    );
  }

  OrderFormBloc _initialCall(BuildContext context) {
    final OrderFormBloc useBloc = bloc == null ? BlocProvider.of<OrderFormBloc>(context) : bloc!;
    // useBloc.add(const OrderFormEvent(status: OrderFormEventStatus.doAsync));
    // useBloc.add(OrderFormEvent(
    //   status: OrderFormEventStatus.newOrderFromEquipmentBranch,
    //   equipmentUuid: equipmentUuid,
    //   equipmentOrderType: equipmentOrderType
    // ));

    return useBloc;
  }

  bool isPlanning(OrderPageMetaData orderListData) {
    return orderListData.submodel == 'planning_user';
  }

  @override
  Widget build(BuildContext context) {
    log.info("build");
    return FutureBuilder<OrderPageMetaData?>(
        future: getOrderPageMetaData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderPageMetaData? orderListData = snapshot.data;
            return BlocProvider(
                create: (context) => _initialCall(context),
                child: BlocConsumer<OrderFormBloc, OrderFormState>(
                    listener: (context, state) {
                      _handleListener(context, state, orderListData);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          body: _getBody(context, state, orderListData!)
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            log.severe("snapshot.hasError ${snapshot.error}");
            return Center(
                child: Text("An error occurred (${snapshot.error})")
            );
          } else {
            return Scaffold(
                body: widgets.loadingNotice()
            );
          }
        }
    );
  }

  void _handleListener(BuildContext context, state, OrderPageMetaData? orderPageMetaData) async {
    log.info("_handleListener state: $state");

    if (state is OrderInsertedState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans('list.snackbar_added'));
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) => OrderDetailPage(
                  bloc: OrderBloc(),
                  orderId: state.order!.id!,
                )
            )
        );
      }
    }

    if (state is OrderFormErrorState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans(
            'error_arg', pathOverride: 'generic',
            namedArgs: {'error': "${state.message}"}
        ));
      }
    }

    if (state is OrderErrorSnackbarState) {
      if (context.mounted) {
        widgets.createSnackBar(context, i18n.$trans(
            'error_arg', pathOverride: 'generic',
            namedArgs: {'error': "${state.message}"}
        ));
      }
    }
  }

  Widget? _getBody(context, state, OrderPageMetaData orderPageMetaData) {
    log.info("_getBody state: $state");

    if (state is OrderFormInitialState) {
      final OrderFormBloc bloc = BlocProvider.of<OrderFormBloc>(context);
      bloc.add(const OrderFormEvent(status: OrderFormEventStatus.doAsync));
      bloc.add(OrderFormEvent(
          status: OrderFormEventStatus.newOrderFromEquipmentBranch,
          equipmentUuid: equipmentUuid,
          equipmentOrderType: equipmentOrderType
      ));
      return null;
    }

    if (state is OrderLoadedState) {
      return OrderFormFromEquipmentWidget(
          formData: state.formData,
          orderPageMetaData: orderPageMetaData,
          widgets: widgets,
          orderlineFormData: OrderlineFormData.createFromModel(state.formData!.orderLines[0]),
          isPlanning: isPlanning(orderPageMetaData)
      );
    }

    if (state is OrderNewState) {
      return OrderFormFromEquipmentWidget(
        formData: state.formData,
        orderPageMetaData: orderPageMetaData,
        widgets: widgets,
        orderlineFormData: OrderlineFormData.createFromModel(state.formData!.orderLines[0]),
        isPlanning: isPlanning(orderPageMetaData)
      );
    }

    if (state is OrderFormErrorState) {
      // TODO maybe we want to display the form again but with error messages?
      return OrderFormErrorWidget(
        widgetsIn: widgets,
        i18nIn: i18n,
        error: state.message!,
        orderPageMetaData: orderPageMetaData,
      );
    }

    if (state is OrderFormInitialState) {
      return widgets.loadingNotice();
    }

    // navs
    if (state is OrderInsertedState) {
      if (context.mounted) {
        return null;
      }
    }

    if (state is OrderUpdatedState) {
      if (context.mounted) {
        return null;
      }
    }

    if (state is OrderAcceptedState) {
      if (context.mounted) {
        return null;
      }
    }

    if (state is OrderRejectedState) {
      if (context.mounted) {
        return null;
      }
    }

    if (state is OrderFormLoadingState) {
      return widgets.loadingNotice();
    }

    return null;
  }
}
