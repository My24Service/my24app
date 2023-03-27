import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/mobile/pages/assigned.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/models/order/models.dart';
import 'mixins.dart';


// ignore: must_be_immutable
class AssignedOrderListWidget extends BaseSliverListStatelessWidget with AssignedListMixin, i18nMixin {
  final String basePath = "assigned_orders.list";
  final List<AssignedOrder> orderList;
  final PaginationInfo paginationInfo;
  final OrderPageMetaData orderListData;
  final String searchQuery;
  var _searchController = TextEditingController();

  AssignedOrderListWidget({
    Key key,
    @required this.orderList,
    @required this.orderListData,
    @required this.paginationInfo,
    @required this.searchQuery,
  }): super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: orderListData.memberPicture
  ){
    _searchController.text = searchQuery?? '';
  }

  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
              AssignedOrder assignedOrder = orderList[index];

              return Column(
                children: [
                  ListTile(
                      title: createOrderListHeader2(assignedOrder.order, assignedOrder.assignedorderDate),
                      subtitle: createOrderListSubtitle2(assignedOrder.order),
                      onTap: () {
                        // navigate to next page
                        final page = AssignedOrderPage(assignedOrderPk: assignedOrder.id);
                        Navigator.push(context, new MaterialPageRoute(builder: (context) => page)
                        );
                      } // onTab
                  ),
                  if (index < orderList.length-1)
                    getMy24Divider(context)
                ],
              );
            },
            childCount: orderList.length
        )
    );
  }
}
