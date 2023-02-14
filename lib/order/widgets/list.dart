import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:my24app/core/models/models.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/order/pages/form.dart';
import 'package:my24app/order/pages/info.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/blocs/order_bloc.dart';

// ignore: must_be_immutable
class OrderListWidget extends StatelessWidget {
  final OrderListData orderListData;
  final List<Order> orderList;
  final dynamic fetchEvent;
  final String searchQuery;
  BuildContext _context;

  var _searchController = TextEditingController();

  bool isPlanning = false;
  bool _inAsyncCall = false;

  OrderListWidget({
    Key key,
    @required this.orderListData,
    @required this.orderList,
    @required this.fetchEvent,
    @required this.searchQuery,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    _context = context;
    _searchController.text = searchQuery?? '';
    isPlanning = orderListData.submodel == 'planning_user';

    return ModalProgressHUD(
        child: Column(
          children: [
            // _showSearchRow(context),
            // SizedBox(height: 20),
            Expanded(child: _buildList(context)),
          ]
        ), inAsyncCall: _inAsyncCall
    );
	}

  navEditOrder(BuildContext context, int orderPk) {
    final page = OrderFormPage(orderPk: orderPk);

    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => page
        )
    );
  }

  navDocuments(BuildContext context, int orderPk) {
    final page = OrderDocumentsPage(orderPk: orderPk);

    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  showDeleteDialog(BuildContext context, Order order) {
    showDeleteDialogWrapper(
      'orders.delete_dialog_title'.tr(),
      'orders.delete_dialog_content'.tr(),
      () => doDelete(context, order),
        _context
    );
  }

  Row _showSearchRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 220, child:
          TextField(
            controller: _searchController,
          ),
        ),
        createDefaultElevatedButton(
            'generic.action_search'.tr(),
            () => _doSearch(context, _searchController.text)
        ),
      ],
    );
  }

  Row getButtonRow(BuildContext context, Order order) {
    Row row;

    if(isPlanning) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createEditButton(() => navEditOrder(context, order.id)),
          SizedBox(width: 10),
          createElevatedButtonColored(
              'orders.unaccepted.button_documents'.tr(),
              () => navDocuments(context, order.id)),
          SizedBox(width: 10),
          createDeleteButton(
              'generic.action_delete'.tr(),
              () => showDeleteDialog(context, order)
          ),
        ],
      );
    } else {
      row = Row();
    }

    return row;
  }

  doDelete(BuildContext context, Order order) async {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.DELETE, value: order.id));
    bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
    bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
  }

  _doSearch(BuildContext context, String query) async {
    final bloc = BlocProvider.of<OrderBloc>(context);

    await Future.delayed(Duration(milliseconds: 100));

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(status: OrderEventStatus.DO_SEARCH));
    bloc.add(OrderEvent(status: fetchEvent, query: query));

  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
    bloc.add(OrderEvent(status: fetchEvent));
  }

  SliverAppBar getAppBar(BuildContext context) {
    OrdersAppBarFactory factory = OrdersAppBarFactory(
      context: context,
      orderListData: orderListData,
      orders: orderList
    );
    return factory.createAppBar();
  }

  Widget _buildList(BuildContext context) {
    if (orderList.length == 0) {
      return RefreshIndicator(
          child: CustomScrollView(
              slivers: [
                getAppBar(context),
                SliverFixedExtentList(
                    itemExtent: 50,
                    delegate: SliverChildListDelegate([
                      Center(
                          child: Column(
                            children: [
                              SizedBox(height: 30),
                              Text('orders.list.notice_no_order'.tr())
                            ],
                          )
                      )
                    ])
                )
              ]
          ),
          onRefresh: () => doRefresh(context)
      );
    }

    return RefreshIndicator(
      child: CustomScrollView(
          slivers: [
            getAppBar(context),
            SliverList(
                delegate: new SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      Order order = orderList[index];

                      return Column(
                          children: [
                            ListTile(
                              title: createOrderListHeader2(order, order.orderDate),
                              subtitle: createOrderListSubtitle2(order),
                              onTap: () {
                                // navigate to next page
                                final page = OrderInfoPage(orderPk: order.id);

                                Navigator.push(context,
                                  new MaterialPageRoute(builder: (context) => page
                                ));
                              } // onTab
                            ),
                            SizedBox(height: 10),
                            getButtonRow(context, order),
                            SizedBox(height: 10)
                          ]
                      );
                    },
                    childCount: orderList != null ? orderList.length : 0
                )
            )
          ]
      ),
      onRefresh: () => doRefresh(context),
    );
  }
}
