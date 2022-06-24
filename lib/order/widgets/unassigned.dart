import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/mobile/pages/assign.dart';
import 'package:my24app/order/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/widgets/list.dart';
import 'package:my24app/mobile/api/mobile_api.dart';

// ignore: must_be_immutable
class UnAssignedListWidget extends OrderListWidget {
  final List<Order> orderList;
  final ScrollController controller;
  final dynamic fetchEvent;
  final String searchQuery;

  bool isPlanning = false;
  bool _inAsyncCall = false;

  UnAssignedListWidget({
    Key key,
    @required this.orderList,
    @required this.controller,
    @required this.fetchEvent,
    @required this.searchQuery,
  }): super(key: key, orderList: orderList, controller: controller, fetchEvent: fetchEvent, searchQuery: searchQuery);

  @override
  Widget build(BuildContext context) {
    _searchController.text = searchQuery?? '';

    return FutureBuilder<String>(
      future: utils.getUserSubmodel(),
      builder: (context, snapshot) {
        if(snapshot.data == null) {
          return loadingNotice();
        }

        isPlanning = snapshot.data == 'planning_user';

        return Column(
          children: [
            Expanded(child: _buildList(context)),
          ]
        );
      }
    );
  }

  _navAssignOrder(BuildContext context, int orderPk) async {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => OrderAssignPage(orderPk: orderPk))
    );
  }

  _navAssignOrderEngineer(BuildContext context, int orderPk) async {
    final bloc = BlocProvider.of<AssignBloc>(context);
    bloc.add(AssignEvent(status: AssignEventStatus.DO_ASYNC));
    bloc.add(AssignEvent(
        status: AssignEventStatus.ASSIGN,
        engineerPks: _selectedEngineerPks,
        orderId: widget.order.orderId
    ));

    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => OrderListPage(orderPk: orderPk))
    );
  }

  @override
  Row getButtonRow(BuildContext context, Order order) {
    if (isPlanning) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createBlueElevatedButton(
                'orders.unassigned.button_assign'.tr(),
                () => _navAssignOrder(context, order.id)
            ),
          ],
        );    
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'orders.unassigned.button_assign_engineer'.tr(),
              () => _navAssignOrderEngineer(context, order.id)
          ),
        ],
      );

  }

  @override
  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
    bloc.add(OrderEvent(status: fetchEvent));
  }

}
