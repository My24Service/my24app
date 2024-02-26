import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/mobile/blocs/assign_bloc.dart';
import 'package:my24app/common/widgets/widgets.dart';
import '../list.dart';

class OrdersUnAssignedWidget extends OrderListWidget {
  final List<Order>? orderList;
  final PaginationInfo paginationInfo;
  final OrderPageMetaData orderPageMetaData;
  final OrderEventStatus fetchEvent;
  final String? searchQuery;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  OrdersUnAssignedWidget({
    Key? key,
    required this.orderList,
    required this.orderPageMetaData,
    required this.fetchEvent,
    required this.searchQuery,
    required this.paginationInfo,
    required this.widgetsIn,
    required this.i18nIn,
  }): super(
    key: key,
    orderList: orderList,
    orderPageMetaData: orderPageMetaData,
    paginationInfo: paginationInfo,
    fetchEvent: fetchEvent,
    searchQuery: searchQuery,
    widgetsIn: widgetsIn,
    // i18nIn: i18nIn
  );

  SliverAppBar getAppBar(BuildContext context) {
    UnassignedOrdersAppBarFactory factory = UnassignedOrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderPageMetaData,
        orders: orderList,
        count: paginationInfo.count,
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }

  Row getButtonRow(BuildContext context, Order order) {
    if (orderPageMetaData.submodel != 'planning_user') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widgetsIn.createDefaultElevatedButton(
            context,
            i18nIn.$trans('button_assign_engineer'),
            () => _showDoAssignDialog(context, order.orderId)
          ),
        ],
      );
    }

    return Row(children: []);
  }

  _showDoAssignDialog(BuildContext context, String? orderId) {
    // set up the button
    Widget cancelButton = TextButton(
        child: Text(i18nIn.$trans('button_cancel', pathOverride: 'utils')),
        onPressed: () => Navigator.of(context).pop(false)
    );
    Widget assignButton = TextButton(
        child: Text(i18nIn.$trans('button_assign')),
        onPressed: () => Navigator.of(context).pop(true)
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(i18nIn.$trans('assign_to_me_header_confirm')),
      content: Text(i18nIn.$trans('assign_to_me_content_confirm')),
      actions: [
        cancelButton,
        assignButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    ).then((dialogResult) {
      if (dialogResult == null) return;

      if (dialogResult) {
        _doAssignOrderEngineer(context, orderId);
      }
    });
  }

  _doAssignOrderEngineer(BuildContext context, String? orderId) async {
    final bloc = BlocProvider.of<AssignBloc>(context);
    bloc.add(AssignEvent(status: AssignEventStatus.DO_ASYNC));
    bloc.add(AssignEvent(
        status: AssignEventStatus.ASSIGN_ME,
        orderId: orderId,
    ));
  }
}
