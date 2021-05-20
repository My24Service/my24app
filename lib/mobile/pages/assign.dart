import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';

import 'package:my24app/mobile/blocs/assign_bloc.dart';
import 'package:my24app/mobile/blocs/assign_states.dart';
import 'package:my24app/mobile/widgets/assign.dart';
import 'package:my24app/order/pages/unassigned.dart';

class OrderAssignPage extends StatefulWidget {
  final int orderPk;

  OrderAssignPage({
    Key key,
    @required this.orderPk,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _OrderAssignPageState();
}

class _OrderAssignPageState extends State<OrderAssignPage> {
  @override
  Widget build(BuildContext context) {
    print('orderPk: ${widget.orderPk}');
    return BlocProvider(
        create: (BuildContext context) => AssignBloc(AssignInitialState()),
        child: Builder(
            builder: (BuildContext context) {
              final bloc = BlocProvider.of<AssignBloc>(context);

              bloc.add(AssignEvent(status: AssignEventStatus.DO_ASYNC));
              bloc.add(AssignEvent(
                  status: AssignEventStatus.FETCH_ORDER,
                  orderPk: widget.orderPk
              ));

              return Scaffold(
                  appBar: AppBar(
                      title: Text('orders.assign.app_bar_title'.tr())),
                  body: BlocListener<AssignBloc, AssignState>(
                      listener: (context, state) async {
                        if (state is AssignedState) {
                          createSnackBar(
                              context, 'orders.assign.snackbar_assigned'.tr());

                          await Future.delayed(Duration(seconds: 1));

                          Navigator.pushReplacement(context,
                              MaterialPageRoute(
                                  builder: (context) => OrdersUnAssignedPage())
                          );
                        }

                        if (state is AssignErrorState) {
                          displayDialog(context,
                              'generic.error_dialog_title'.tr(),
                              'orders.assign.error_dialog_content'.tr()
                          );
                        }
                      },
                      child: BlocBuilder<AssignBloc, AssignState>(
                          builder: (context, state) {
                            if (state is AssignInitialState) {
                              return loadingNotice();
                            }

                            if (state is AssignLoadingState) {
                              return loadingNotice();
                            }

                            if (state is AssignErrorState) {
                              return errorNoticeWithReload(
                                  state.message,
                                  bloc,
                                  AssignEvent(
                                      status: AssignEventStatus.FETCH_ORDER,
                                      orderPk: widget.orderPk
                                  )
                              );
                            }

                            if (state is OrderLoadedState) {
                              return AssignWidget(order: state.order);
                            }

                            return loadingNotice();
                          }
                      )
                  )
              ); // Scaffold
            } // builder
        ) // Builder
    ); // BlocProvider
  }
}
