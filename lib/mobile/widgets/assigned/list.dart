import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/slivers/app_bars.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/mobile/pages/assigned.dart';
import 'package:my24app/core/models/models.dart';
import 'mixins.dart';


// ignore: must_be_immutable
class AssignedOrderListWidget extends BaseSliverListStatelessWidget with AssignedListMixin {
  final List<AssignedOrder> orderList;
  final PaginationInfo paginationInfo;
  final OrderListData orderListData;
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
      modelName: 'orders.model_name'.tr(),
      paginationInfo: paginationInfo
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
