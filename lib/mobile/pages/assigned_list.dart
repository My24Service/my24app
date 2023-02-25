import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/widgets/assigned/empty.dart';
import 'package:my24app/mobile/widgets/assigned/list.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/blocs/assignedorder_states.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/mobile/widgets/assigned/error.dart';
import 'package:my24app/core/i18n_mixin.dart';


class AssignedOrderListPage extends StatelessWidget with i18nMixin {
  AssignedOrderBloc _initialBlocCall() {
    final bloc = AssignedOrderBloc();

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.FETCH_ALL
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderListData>(
        future: utils.getOrderListData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderListData orderListData = snapshot.data;

            return BlocProvider<AssignedOrderBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<AssignedOrderBloc, AssignedOrderState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      return Scaffold(
                          drawer: orderListData.drawer,
                          body: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: _getBody(context, state, orderListData)
                          )
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    $trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": snapshot.error}))
            );
          } else {
            return loadingNotice();
          }
        }
    );
  }

  Widget _getBody(context, state, OrderListData orderListData) {
    if (state is AssignedOrderErrorState) {
      return AssignedOrderListErrorWidget(
          error: state.message,
      );
    }

    if (state is AssignedOrdersLoadedState) {
      if (state.assignedOrders.results.length == 0) {
        return AssignedOrderListEmptyWidget();
      }

      PaginationInfo paginationInfo = PaginationInfo(
        count: state.assignedOrders.count,
        next: state.assignedOrders.next,
        previous: state.assignedOrders.previous,
        currentPage: state.page != null ? state.page : 1,
        pageSize: orderListData.pageSize
      );

      return AssignedOrderListWidget(
          orderList: state.assignedOrders.results,
          orderListData: orderListData,
          paginationInfo: paginationInfo,
          searchQuery: state.query,
      );
    }

    return loadingNotice();
  }
}
