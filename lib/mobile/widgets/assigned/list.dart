import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/mobile/models/assignedorder/models.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/common/widgets/widgets.dart';
import 'mixins.dart';

class AssignedOrderListWidget extends BaseSliverListStatelessWidget with AssignedListMixin {
  final List<AssignedOrder>? orderList;
  final PaginationInfo paginationInfo;
  final OrderPageMetaData orderListData;
  final String? searchQuery;
  final TextEditingController _searchController = TextEditingController();
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn = My24i18n(basePath: "assigned_orders.list");

  AssignedOrderListWidget({
    Key? key,
    required this.orderList,
    required this.orderListData,
    required this.paginationInfo,
    required this.searchQuery,
    required this.widgetsIn,
  }): super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: orderListData.memberPicture,
      widgets: widgetsIn,
      i18n: My24i18n(basePath: "assigned_orders.list")
  ){
    _searchController.text = searchQuery?? '';
  }

  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
              AssignedOrder assignedOrder = orderList![index];

              return Column(
                children: [
                  ListTile(
                      title: createOrderListHeader2(assignedOrder.order!, assignedOrder.assignedorderDate!),
                      subtitle: createOrderListSubtitle2(assignedOrder.order!),
                      onTap: () {
                        _loadDetail(context, assignedOrder.id);
                      } // onTab
                  ),
                  if (index < orderList!.length-1)
                    widgetsIn.getMy24Divider(context)
                ],
              );
            },
            childCount: orderList!.length
        )
    );
  }

  _loadDetail(BuildContext context, int? assignedOrderPk) async {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.FETCH_DETAIL, pk: assignedOrderPk));
  }

}
