import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/mobile/blocs/customer_history_bloc.dart';
import 'mixins.dart';

class CustomerHistoryWidget extends BaseSliverListStatelessWidget with CustomerHistoryMixin, i18nMixin {
  final String basePath = "customers.history";
  final CustomerHistoryOrders customerHistoryOrders;
  final int customerPk;
  final PaginationInfo paginationInfo;
  final String memberPicture;
  final String customerName;
  final String searchQuery = null;
  final TextEditingController searchController = TextEditingController();

  CustomerHistoryWidget({
    Key key,
    @required this.customerHistoryOrders,
    @required this.customerPk,
    @required this.paginationInfo,
    @required this.memberPicture,
    @required this.customerName,
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture
  );

  @override
  String getAppBarTitle(BuildContext context) {
    return $trans('app_bar_title',
      namedArgs: {'customer': "$customerName"}
    );
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return $trans('app_bar_subtitle',
        namedArgs: {'count': "${customerHistoryOrders.count}"}
    );
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
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              CustomerHistoryOrder customerHistoryOrder = customerHistoryOrders.results[index];

              return Column(
                children: [
                  _createOrderRow(customerHistoryOrder),
                  _createOrderlinesSection(context, customerHistoryOrder.orderLines)
                ],
              );
            },
            childCount: customerHistoryOrders.results.length,
        )
    );
  }

  // private methods
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
      $trans('header_orderlines'),
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

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<CustomerHistoryBloc>(context);

    bloc.add(CustomerHistoryEvent(status: CustomerHistoryEventStatus.DO_ASYNC));
    bloc.add(CustomerHistoryEvent(
      status: CustomerHistoryEventStatus.FETCH_ALL,
      customerPk: customerPk,
      page: paginationInfo.currentPage + 1,
      query: searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<CustomerHistoryBloc>(context);

    bloc.add(CustomerHistoryEvent(status: CustomerHistoryEventStatus.DO_ASYNC));
    bloc.add(CustomerHistoryEvent(
        status: CustomerHistoryEventStatus.FETCH_ALL,
        customerPk: customerPk,
        page: paginationInfo.currentPage - 1,
        query: searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<CustomerHistoryBloc>(context);

    bloc.add(CustomerHistoryEvent(status: CustomerHistoryEventStatus.DO_ASYNC));
    bloc.add(CustomerHistoryEvent(status: CustomerHistoryEventStatus.DO_SEARCH));
    bloc.add(CustomerHistoryEvent(
        status: CustomerHistoryEventStatus.FETCH_ALL,
        customerPk: customerPk,
        query: searchController.text,
        page: 1
    ));
  }
}
