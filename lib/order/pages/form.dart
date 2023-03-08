import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/widgets/form.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/core/i18n_mixin.dart';

class OrderFormPage extends StatelessWidget with i18nMixin {
  final String basePath = "orders.list";
  final dynamic orderPk;

  OrderFormPage({
    Key key,
    @required this.orderPk
  });

  OrderBloc _initialBlocCall(isEdit) {
    OrderBloc bloc = OrderBloc();

    if (isEdit) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(status: OrderEventStatus.FETCH_DETAIL, pk: orderPk));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = orderPk is int;

    return BlocProvider(
        create: (context) => _initialBlocCall(isEdit),
        child: FutureBuilder<Widget>(
          future: getDrawerForUser(context),
          builder: (ctx, snapshot) {
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

                return BlocConsumer<OrderBloc, OrderState>(
                  builder: (context, state) {
                    return Scaffold(
                        appBar: AppBar(title: Text(
                            isEdit ? 'orders.form.app_bar_title_update'.tr() : 'orders.form.app_bar_title_insert'.tr()
                        )),
                        body: _getBody(context, state, _isPlanning)
                    );
                  },
                  listener: (context, state) {
                    _handleListener(context, state);
                  }
                );
              }
            );
          }
        )
    );
  }

  void _handleListener(BuildContext context, state) {
  }

  Widget _getBody(BuildContext context, state, isPlanning) {
    if (state is OrderLoadedState) {
      return OrderFormWidget(order: state.formData, isPlanning: isPlanning);
    }

    if (state is OrderInitialState) {
      return OrderFormWidget(order: null, isPlanning: isPlanning);
    }

    if (state is OrderErrorState) {
      return errorNotice(state.message);
    }

    return loadingNotice();
  }
}
