import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/widgets/form.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/order/pages/unaccepted.dart';

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
  bool orderLoaded = false;

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.orderPk is int;

    return BlocProvider(
        create: (BuildContext context) => OrderBloc(OrderInitialState()),
        child: FutureBuilder<Widget>(
          future: getDrawerForUser(context),
          builder: (ctx, snapshot) {
            final Widget drawer = snapshot.data;
            final bloc = BlocProvider.of<OrderBloc>(ctx);

            if (isEdit) {
              bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
              bloc.add(OrderEvent(
                  status: OrderEventStatus.FETCH_DETAIL, value: widget.orderPk));
            }

            return FutureBuilder<String>(
              future: utils.getUserSubmodel(),
              builder: (ctx, snapshot) {
                bool _isPlanning;

                if(snapshot.data == null) {
                  return Scaffold(
                      appBar: AppBar(title: Text('')),
                      body: Container()
                  );
                }

                _isPlanning = snapshot.data == 'planning_user';

                return Scaffold(
                    appBar: AppBar(title: Text(
                        isEdit ? 'orders.form.app_bar_title_update'.tr() : 'orders.form.app_bar_title_insert'.tr()
                    )),
                    body: BlocListener<OrderBloc, OrderState>(
                        listener: (context, state) async {
                        },
                        child: BlocBuilder<OrderBloc, OrderState>(
                          builder: (context, state) {
                            // show form with order data
                            if (state is OrderLoadedState) {
                              return OrderFormWidget(order: state.order, isPlanning: _isPlanning);
                            }

                            if (state is OrderInitialState) {
                              return OrderFormWidget(order: null, isPlanning: _isPlanning);
                            }

                            if (state is OrderLoadingState) {
                              return loadingNotice();
                            }

                            if (state is OrderErrorState) {
                              return errorNotice(state.message);
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
