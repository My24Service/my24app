import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/widgets/assigned_list.dart';

import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/blocs/assignedorder_states.dart';

import '../../core/models/models.dart';
import '../../core/utils.dart';


class AssignedOrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AssignedOrderListPageState();
}

class _AssignedOrderListPageState extends State<AssignedOrderListPage> {
  bool firstTime = true;

  AssignedOrderBloc _initialBlocCall() {
    final bloc = AssignedOrderBloc();

    if (firstTime) {
      bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_ALL
      ));

      firstTime = false;
    }

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
                          body: _getBody(context, state, orderListData)
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text("An error occurred (${snapshot.error})"));
          } else {
            return loadingNotice();
          }
        }
    );
  }

  Widget _getBody(context, state, OrderListData orderListData) {
    if (state is AssignedOrderErrorState) {
      return AssignedListWidget(
          orderList: [],
          error: state.message,
          orderListData: orderListData,
          paginationInfo: null
      );
    }

    if (state is AssignedOrdersLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
        count: state.assignedOrders.count,
        next: state.assignedOrders.next,
        previous: state.assignedOrders.previous,
        currentPage: state.page != null ? state.page : 1,
        pageSize: orderListData.pageSize
      );

      return AssignedListWidget(
          orderList: state.assignedOrders.results,
          orderListData: orderListData,
          paginationInfo: paginationInfo,
          error: null,
      );
    }

    return loadingNotice();
  }
}
