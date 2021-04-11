import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/widgets/order_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/pages/list.dart';

class OrderFormPage extends StatefulWidget {
  final dynamic orderPk;

  OrderFormPage({
    Key key,
    @required this.orderPk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.orderPk is int;
    bool orderLoaded = false;

    return FutureBuilder<String>(
      future: utils.getUserSubmodel(),
      builder: (ctx, snapshot) {
        final _isPlanning = snapshot.data == 'planning_user';

        return BlocProvider(
          create: (BuildContext context) => OrderBloc(OrderLoadingState()),
          child:  BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              final bloc = BlocProvider.of<OrderBloc>(context);
              Order order;
              Widget result;

              if (isEdit) {
                bloc.add(OrderEvent(
                    status: OrderEventStatus.FETCH_DETAIL, value: widget.orderPk));
                orderLoaded = true;
              }

              // show form with order data
              if (state is OrderLoadedState) {
                result = OrderFormWidget(order: state.order);
              }

              else if (state is OrderInsertState) {
                if (state.order != null) {
                  createSnackBar(context, 'orders.snackbar_order_saved'.tr());

                  if (_isPlanning) {
                    // nav to orders list
                    Navigator.pushReplacement(context,
                        new MaterialPageRoute(
                            builder: (context) => OrderListPage())
                    );
                  } else {
                    // nav to orders processing list
                    // Navigator.pushReplacement(context,
                    //     new MaterialPageRoute(
                    //         builder: (context) => OrderNotAcceptedListPage())
                    // );
                  }
                } else {
                  displayDialog(context,
                    'generic.error_dialog_title'.tr(),
                    'orders.error_storing_order'.tr()
                  );
                }
              }

              // both result for insert and edit
              else if (state is OrderEditState) {
                if (state.order != null) {
                  createSnackBar(context, 'orders.snackbar_order_saved'.tr());

                  if (_isPlanning) {
                    // nav to orders list
                    Navigator.pushReplacement(context,
                        new MaterialPageRoute(
                            builder: (context) => OrderListPage())
                    );
                  } else {
                    // nav to orders processing list
                    // Navigator.pushReplacement(context,
                    //     new MaterialPageRoute(
                    //         builder: (context) => OrderNotAcceptedListPage())
                    // );
                  }
                } else {
                  displayDialog(context,
                    'generic.error_dialog_title'.tr(),
                    'orders.error_storing_order'.tr()
                  );
                }
              }

              else if (state is OrderInitialState) {
                result = result = OrderFormWidget(order: order);
              }

              else if (state is OrderLoadingState) {
                result = loadingNotice();
              }

              else if (state is OrderErrorState) {
                result = errorNotice(state.message);
              }

              return FutureBuilder<Widget>(
                future: getDrawerForUser(context),
                builder: (ctx, snapshot) {
                  final Widget drawer = snapshot.data;

                  return Scaffold(
                    appBar: AppBar(
                      title: Text('orders.edit_form.app_bar_title'.tr()),
                    ),
                    body: Container(
                      child: result,
                    ),
                    drawer: drawer,
                  );
                }
              );
            }
          )
        );
      }
    );
  }
}
