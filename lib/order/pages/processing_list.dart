import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/order/widgets/processing_list.dart';

class ProcessingListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ProcessingListPageState();
}

class _ProcessingListPageState extends State<ProcessingListPage> {
  @override
  Widget build(BuildContext context) {
      return BlocProvider(
          create: (BuildContext context) => OrderBloc(OrderInitialState()),
          child: FutureBuilder<Widget>(
                  future: getDrawerForUser(context),
                  builder: (ctx, snapshot) {
                    final Widget drawer = snapshot.data;
                    final bloc = BlocProvider.of<OrderBloc>(ctx);

                    bloc.add(OrderEvent(status: OrderEventStatus.DO_FETCH));
                    bloc.add(OrderEvent(
                        status: OrderEventStatus.FETCH_PROCESSING));

                    return Scaffold(
                        appBar: AppBar(title: Text(
                            'orders.not_yet_accepted.app_bar_title'.tr())),
                        drawer: drawer,
                        body: BlocListener<OrderBloc, OrderState>(
                            listener: (context, state) {
                              if (state is OrderAcceptedState) {
                                if (state.result == true) {
                                  createSnackBar(
                                      context,
                                      'orders.not_yet_accepted.snackbar_accepted'.tr());

                                  bloc.add(OrderEvent(
                                      status: OrderEventStatus.DO_FETCH));
                                  bloc.add(OrderEvent(
                                      status: OrderEventStatus.FETCH_PROCESSING));
                                } else {
                                  displayDialog(context,
                                      'generic.error_dialog_title'.tr(),
                                      'orders.not_yet_accepted.error_accepting_dialog_content'.tr());
                                }
                              }
                              if (state is OrderDeletedState) {
                                if (state.result == true) {
                                  createSnackBar(
                                      context,
                                      'orders.snackbar_deleted'.tr());

                                  bloc.add(OrderEvent(
                                      status: OrderEventStatus.DO_FETCH));
                                  bloc.add(OrderEvent(
                                      status: OrderEventStatus.FETCH_PROCESSING));
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
                                            status: OrderEventStatus
                                                .FETCH_PROCESSING)
                                    );
                                  }

                                  if (state is OrdersProcessingLoadedState) {
                                    return ProcessingListWidget(
                                        orders: state.orders);
                                  }

                                  return loadingNotice();
                                }
                            )
                        )
                    );
                  }
              )
      );
    }
}
