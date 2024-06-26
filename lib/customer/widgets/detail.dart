import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_orders/blocs/order_bloc.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';

import 'package:my24app/customer/models/models.dart';
import 'package:my24app/order/pages/detail.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/common/widgets/widgets.dart';

class CustomerDetailWidget extends BaseSliverListStatelessWidget{
  final PaginationInfo paginationInfo;
  final Customer? customer;
  final CustomerHistoryOrders? customerHistoryOrders;
  final String? memberPicture;
  final TextEditingController searchController = TextEditingController();
  final bool isEngineer;
  final String? searchQuery;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  CustomerDetailWidget({
    Key? key,
    required this.customer,
    required this.customerHistoryOrders,
    required this.paginationInfo,
    required this.memberPicture,
    required this.isEngineer,
    required this.searchQuery,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture,
      widgets: widgetsIn,
      i18n: i18nIn
  ) {
    searchController.text = searchQuery?? '';
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return i18nIn.$trans('detail.app_bar_title');
  }

  @override
  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
        status: CustomerEventStatus.FETCH_DETAIL_VIEW,
        pk: customer!.id,
    ));
  }

  Widget getBottomSection(BuildContext context) {
    return widgetsIn.showPaginationSearchSection(
      context,
      paginationInfo,
      searchController,
      _nextPage,
      _previousPage,
      _doSearch
    );
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return "";
  }

  @override
  SliverList getPreSliverListContent(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Column(
                children: [
                  buildCustomerInfoCard(context, customer!),
                  widgetsIn.getMy24Divider(context),
                ],
              );
            },
            childCount: 1,
        )
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            CustomerHistoryOrder customerHistoryOrder = customerHistoryOrders!.results![index];
            Widget content = isEngineer ? _getContentEngineer(context, customerHistoryOrder) : _getContentNoEngineer(context, customerHistoryOrder);

            return Column(
              children: [
                content,
                SizedBox(height: 2),
                if (index < customerHistoryOrders!.results!.length-1)
                  widgetsIn.getMy24Divider(context)
              ],
            );
          },
          childCount: customerHistoryOrders!.results!.length,
        )
    );
  }

  // private methods
  Widget _getContentEngineer(BuildContext context, CustomerHistoryOrder customerHistoryOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: widgetsIn.createOrderHistoryListHeader2(customerHistoryOrder.orderDate!),
          subtitle: widgetsIn.createOrderHistoryListSubtitle2(
              customerHistoryOrder,
              widgetsIn.buildItemListCustomWidget(
                  i18nIn.$trans('detail.info_workorder'),
                  _createWorkorderText(customerHistoryOrder, context)
              ),
              widgetsIn.buildItemListCustomWidget(
                  i18nIn.$trans('detail.info_view_order'),
                  _createOrderDetailButton(context, customerHistoryOrder)
              )
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: _createOrderlinesSection(context, customerHistoryOrder.orderLines)
        )
      ],
    );
  }

  Widget _getContentNoEngineer(BuildContext context, CustomerHistoryOrder customerHistoryOrder) {
    return ListTile(
        title: widgetsIn.createOrderHistoryListHeader2(customerHistoryOrder.orderDate!),
        subtitle: widgetsIn.createOrderHistoryListSubtitle2(
            customerHistoryOrder,
            widgetsIn.buildItemListCustomWidget(
                i18nIn.$trans('detail.info_workorder'),
                _createWorkorderText(customerHistoryOrder, context)
            ),
            widgetsIn.buildItemListCustomWidget(
                i18nIn.$trans('detail.info_view_order'),
                _createOrderDetailButton(context, customerHistoryOrder)
            )
        ),
    );
  }

  Widget _createWorkorderText(CustomerHistoryOrder customerHistoryOrder, BuildContext context) {
    return widgetsIn.createViewWorkOrderButton(customerHistoryOrder.workorderPdfUrl, context);
  }

  Widget _createOrderDetailButton(BuildContext context, CustomerHistoryOrder customerHistoryOrder) {
    return widgetsIn.createElevatedButtonColored(
        i18nIn.$trans('detail.button_view_order'),
        () => _navOrderDetail(context, customerHistoryOrder.orderPk)
    );
  }

  Widget _createOrderlinesSection(BuildContext context, List<Orderline>? orderLines) {
    return widgetsIn.buildItemsSection(
      context,
      i18nIn.$trans('detail.header_orderlines'),
      orderLines,
      (Orderline orderline) {
        String equipmentLocationTitle = "${i18nIn.$trans('info_equipment', pathOverride: 'generic')} / ${i18nIn.$trans('info_location', pathOverride: 'generic')}";
        String equipmentLocationValue = "${orderline.product?? '-'} / ${orderline.location?? '-'}";
        return <Widget>[
          ...widgetsIn.buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
          if (orderline.remarks != null && orderline.remarks != "")
            ...widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_remarks', pathOverride: 'generic'), orderline.remarks)
        ];
      },
      (Orderline orderline) {
        return <Widget>[];
      },
      withLastDivider: false
    );
  }

  void _navOrderDetail(BuildContext context, int? orderPk) {
    final page = OrderDetailPage(
        orderId: orderPk,
        bloc: OrderBloc(),
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
      status: CustomerEventStatus.FETCH_DETAIL_VIEW,
      pk: customer!.id,
      page: paginationInfo.currentPage! + 1,
      query: searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
      status: CustomerEventStatus.FETCH_DETAIL_VIEW,
      pk: customer!.id,
      page: paginationInfo.currentPage! - 1,
      query: searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_SEARCH));
    bloc.add(CustomerEvent(
        status: CustomerEventStatus.FETCH_DETAIL_VIEW,
        pk: customer!.id,
        query: searchController.text,
        page: 1
    ));
  }
}
