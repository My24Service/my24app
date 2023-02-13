import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/mobile/pages/assigned.dart';

import '../../core/models/models.dart';

class AssignedListWidget extends StatelessWidget {
  final List<AssignedOrder> orderList;
  final OrderListData orderListData;

  AssignedListWidget({
    Key key,
    @required this.orderList,
    @required this.orderListData
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    if (orderList.length == 0) {
      return RefreshIndicator(
          child: Center(
              child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Text('assigned_orders.list.notice_no_order'.tr())
                          ],
                        )
                    )
                  ]
              )
          ),
          onRefresh: () => _doRefresh(context)
      );
    }

    return RefreshIndicator(
        child: CustomScrollView(
            slivers: [
              makeAssignedOrdersAppBar2(context, orderListData, orderList),
              SliverList(
                delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    AssignedOrder assignedOrder = orderList[index];

                    return ListTile(
                        title: createOrderListHeader(assignedOrder.order, assignedOrder.assignedorderDate),
                        subtitle: createOrderListSubtitle(assignedOrder.order),
                        onTap: () {
                          // navigate to next page
                          final page = AssignedOrderPage(assignedOrderPk: assignedOrder.id);

                          Navigator.push(context,
                              new MaterialPageRoute(builder: (context) => page
                              )
                          );
                        } // onTab
                    );

                  },
                  childCount: orderList.length
                )
              )
            ]
        ),
        onRefresh: () => _doRefresh(context),
    );
  }

  _doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.FETCH_ALL
    ));

    return Future.delayed(Duration(milliseconds: 100));
  }
}
