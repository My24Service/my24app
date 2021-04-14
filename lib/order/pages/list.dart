import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/widgets/list.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

class OrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  int pageNum = 1;
  bool isPageLoading = false;
  ScrollController controller;
  Future<List<Map<String, dynamic>>> future;
  int totalRecord = 0;
  bool eventAdded = false;

  _scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {}

    print('extentAfter: ${controller.position.extentAfter}');
    print('maxScrollExtent: ${controller.position.maxScrollExtent}');
    print('offset: ${controller.offset}');

    if (controller.position.extentAfter <= 0 && isPageLoading == false) {
      // _callAPIToGetListOfData();
    }
  }

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => OrderBloc(OrderInitialState()),
        child: FutureBuilder<String>(
            future: utils.getOrderListTitleForUser(),
            builder: (ctx, snapshot) {
              final bloc = BlocProvider.of<OrderBloc>(ctx);
              final String title = snapshot.data;

              if (!eventAdded) {
                bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
                bloc.add(OrderEvent(
                    status: OrderEventStatus.FETCH_ALL));
                eventAdded = true;
              }

              return FutureBuilder<Widget>(
                future: getDrawerForUser(context),
                builder: (ctx, snapshot) {
                  final Widget drawer = snapshot.data;

                  return Scaffold(
                      appBar: AppBar(
                          title: Text(title?? ''),
                      ),
                      drawer: drawer,
                      body: BlocListener<OrderBloc, OrderState>(
                          listener: (context, state) {
                            if (state is OrderDeletedState) {
                              if (state.result == true) {
                                createSnackBar(
                                    context, 'orders.snackbar_deleted'.tr());

                                bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
                                bloc.add(OrderEvent(
                                    status: OrderEventStatus.FETCH_ALL));
                              } else {
                                displayDialog(context,
                                    'generic.error_dialog_title'.tr(),
                                    'orders.error_deleting_dialog_content'.tr()
                                );
                              }
                            }
                          },
                          child: BlocBuilder<OrderBloc, OrderState>(
                              builder: (context, state) {
                                if (state is OrderInitialState) {
                                  return loadingNotice();
                                }

                                if (state is OrderLoadingState) {
                                  return loadingNotice();
                                }

                                if (state is OrderErrorState) {
                                  return errorNoticeWithReload(
                                      state.message,
                                      bloc,
                                      OrderEvent(
                                          status: OrderEventStatus.FETCH_ALL)
                                  );
                                }

                                if (state is OrdersLoadedState) {
                                  return OrderListWidget(orders: state.orders);
                                }

                                return loadingNotice();
                              }
                          )
                      )
                  );
                }
              );
            }
        )
    );
  }
}
