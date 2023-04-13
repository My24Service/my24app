import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/customer/models/models.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/pages/detail.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';

class CustomerDetailWidget extends BaseSliverListStatelessWidget with i18nMixin {
  final String basePath = "customers";
  final PaginationInfo paginationInfo;
  final Customer customer;
  final CustomerHistoryOrders customerHistoryOrders;
  final String memberPicture;
  final TextEditingController searchController = TextEditingController();
  final bool isEngineer;
  final String searchQuery;

  CustomerDetailWidget({
    Key key,
    @required this.customer,
    @required this.customerHistoryOrders,
    @required this.paginationInfo,
    @required this.memberPicture,
    @required this.isEngineer,
    @required this.searchQuery
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture
  ) {
    searchController.text = searchQuery?? '';
  }

  @override
  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
        status: CustomerEventStatus.FETCH_DETAIL_VIEW,
        pk: customer.id,
    ));
  }

  Widget getBottomSection(BuildContext context) {
    return showPaginationSearchSection(
      context,
      paginationInfo,
      searchController,
      _nextPage,
      _previousPage,
      _doSearch,
    );
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return "${customer.name}, ${customer.city}";
  }

  @override
  SliverList getPreSliverListContent(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Column(
                children: [
                  buildCustomerInfoCard(context, customer),
                  getMy24Divider(context),
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
            CustomerHistoryOrder customerHistoryOrder = customerHistoryOrders.results[index];
            if (isEngineer) {
              return _getContentEngineer(context, customerHistoryOrder);
            }

            return _getContentNoEngineer(context, customerHistoryOrder);
          },
          childCount: customerHistoryOrders.results.length,
        )
    );
  }

  // private methods
  Widget _getContentEngineer(BuildContext context, CustomerHistoryOrder customerHistoryOrder) {
    return Column(
      children: [
        _createOrderRow(customerHistoryOrder),
        _createOrderlinesSection(context, customerHistoryOrder.orderLines)
      ],
    );
  }

  Widget _getContentNoEngineer(BuildContext context, CustomerHistoryOrder customerHistoryOrder) {
    String key = "${$trans('info_order_id', pathOverride: 'orders')} / "
        "${$trans('info_order_date', pathOverride: 'orders')} / "
        "${$trans('info_order_type', pathOverride: 'orders')}";
    String value = "${customerHistoryOrder.orderId} / ${customerHistoryOrder.orderDate} / ${customerHistoryOrder.orderType}";

    return Column(
      children: [
        ...buildItemListKeyValueList(key, value),
        buildItemListCustomWidget(
            $trans('detail.info_workorder'),
            _createWorkorderText(customerHistoryOrder)
        ),
        buildItemListCustomWidget(
            $trans('detail.info_view_order'),
            _createOrderDetailButton(context, customerHistoryOrder)
        )
      ],
    );
  }

  Widget _createWorkorderText(CustomerHistoryOrder customerHistoryOrder) {
    if (customerHistoryOrder.workorderPdfUrl != null && customerHistoryOrder.workorderPdfUrl != '') {
      return createElevatedButtonColored(
          $trans('detail.button_open_workorder'),
          () => utils.launchURL(customerHistoryOrder.workorderPdfUrl.replaceAll('/api', ''))
      );
    }

    return Text('-');
  }

  Widget _createOrderDetailButton(BuildContext context, CustomerHistoryOrder customerHistoryOrder) {
    return createElevatedButtonColored(
        $trans('detail.button_view_order'),
        () => _navOrderDetail(context, customerHistoryOrder.orderPk)
    );
  }

  Widget _createOrderRow(CustomerHistoryOrder orderData) {
    return Table(
      children: [
        TableRow(
            children: [
              Table(
                children: [
                  TableRow(
                      children: [
                        Text($trans('info_date'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text('${orderData.orderDate}')
                      ]
                  ),
                  TableRow(
                      children: [
                        Text($trans('info_order_type'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text('${orderData.orderType}'),
                      ]
                  )
                ],
              ),
              Table(
                children: [
                  TableRow(
                      children: [
                        Text($trans('info_reference'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(orderData.orderReference != null ? orderData.orderReference : '-')
                      ]
                  ),
                  TableRow(
                      children: [
                        Text($trans('info_customer_id'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(orderData.orderId != null ? orderData.orderId : '-')
                      ]
                  ),
                ],
              )
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 10),
              SizedBox(height: 10),
            ]
        ),
        TableRow(
            children: [
              SizedBox(width: 10),
              createViewWorkOrderButton(orderData.workorderPdfUrl)
            ]
        ),
      ],
    );
  }

  Widget _createOrderlinesSection(BuildContext context, List<Orderline> orderLines) {
    return buildItemsSection(
      context,
      $trans('detail.header_orderlines'),
      orderLines,
          (Orderline orderline) {
        String equipmentLocationTitle = "${$trans('info_equipment', pathOverride: 'generic')} / ${$trans('info_location', pathOverride: 'generic')}";
        String equipmentLocationValue = "${orderline.product?? '-'} / ${orderline.location?? '-'}";
        return <Widget>[
          ...buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
          if (orderline.remarks != null && orderline.remarks != "")
            ...buildItemListKeyValueList($trans('info_remarks', pathOverride: 'generic'), orderline.remarks)
        ];
      },
          (Orderline orderline) {
        return <Widget>[];
      },
    );
  }

  void _navOrderDetail(BuildContext context, int orderPk) {
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
      pk: customer.id,
      page: paginationInfo.currentPage + 1,
      query: searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
      status: CustomerEventStatus.FETCH_DETAIL_VIEW,
      pk: customer.id,
      page: paginationInfo.currentPage - 1,
      query: searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_SEARCH));
    bloc.add(CustomerEvent(
        status: CustomerEventStatus.FETCH_DETAIL_VIEW,
        pk: customer.id,
        query: searchController.text,
        page: 1
    ));
  }
}
