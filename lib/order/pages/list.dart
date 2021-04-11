import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/widgets/order_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

class OrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  @override
  Widget build(BuildContext context) {
    bool firstLoaded = false;

    return BlocProvider(
      create: (BuildContext context) => OrderBloc(OrderLoadingState()),
      child:  BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          final bloc = BlocProvider.of<OrderBloc>(context);

          if (!firstLoaded) {
            bloc.add(OrderEvent(
                status: OrderEventStatus.FETCH_ALL));
            firstLoaded = true;
          }

          return FutureBuilder<String>(
            future: utils.getOrderListTitleForUser(),
            builder: (ctx, snapshot) {
              final String title = snapshot.data;

              Widget result = loadingNotice();

              if (state is OrderInitialState) {
                result = loadingNotice();
              }

              else if (state is OrderLoadingState) {
                result = loadingNotice();
              }

              else if (state is OrderErrorState) {
                result = errorNoticeWithReload(
                    state.message,
                    bloc,
                    OrderEvent(status: OrderEventStatus.FETCH_ALL)
                );
              }

              else if (state is OrdersLoadedState) {
                result = OrderListWidget(orders: state.orders);
              }

              else if (state is OrderDeletedState) {
                if (state.result == true) {
                  result = createSnackBar(context, 'orders.snackbar_deleted'.tr());

                  bloc.add(OrderEvent(
                      status: OrderEventStatus.FETCH_ALL));
                } else {
                  displayDialog(context,
                      'generic.error_dialog_title'.tr(),
                      'orders.error_deleting_dialog_content'.tr()
                  );
                }
              }

              else {
                result = errorNotice('generic.error'.tr());
              }

              return FutureBuilder<Widget>(
                future: getDrawerForUser(context),
                builder: (ctx, snapshot) {
                  final Widget drawer = snapshot.data;

                  return Scaffold(
                    appBar: AppBar(
                      title: Text(title?? ''),
                    ),
                    body: Container(
                      child: result,
                    ),
                    drawer: drawer,
                  );
                }
              );
            }
          );
        }
      )
    );
  }
}
