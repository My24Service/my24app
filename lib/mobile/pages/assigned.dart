import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/utils.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_orders/models/order/models.dart';

import 'package:my24app/mobile/widgets/assigned/empty.dart';
import 'package:my24app/mobile/widgets/assigned/list.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/blocs/assignedorder_states.dart';
import 'package:my24app/mobile/widgets/assigned/error.dart';
import '../../common/widgets/drawers.dart';
import '../widgets/assigned/detail.dart';

String? initialLoadMode;
int? loadId;

class AssignedOrdersPage extends StatelessWidget {
  final i18n = My24i18n(basePath: "assigned_orders.detail");
  final AssignedOrderBloc bloc;
  final int? pk;
  final CoreWidgets widgets = CoreWidgets();
  final CoreUtils utils = CoreUtils();

  AssignedOrdersPage({
    Key? key,
    this.pk,
    required this.bloc,
    String? initialMode,
  }) : super(key: key) {
    if (initialMode != null) {
      initialLoadMode = initialMode;
    }
  }

  AssignedOrderBloc _initialBlocCall() {
    if (initialLoadMode == null) {
      bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_ALL
      ));
    } else if (initialLoadMode == 'detail') {
      bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
      bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.FETCH_DETAIL, pk: pk));
    }

    return bloc;
  }

  Future<OrderPageMetaData?> getOrderPageMetaData(BuildContext context) async {
    String? submodel = await utils.getUserSubmodel();
    bool? hasBranches = await utils.getHasBranches();
    String? memberPicture = await utils.getMemberPicture();
    Widget? drawer = context.mounted ?
    await getDrawerForUserWithSubmodel(context, submodel) : null;

    return OrderPageMetaData(
        drawer: drawer,
        submodel: submodel,
        firstName: await utils.getFirstName(),
        memberPicture: memberPicture,
        pageSize: 20,
        hasBranches: hasBranches
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderPageMetaData?>(
        future: getOrderPageMetaData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderPageMetaData? orderListData = snapshot.data;

            return BlocProvider<AssignedOrderBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<AssignedOrderBloc, AssignedOrderState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: orderListData!.drawer,
                          body: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: _getBody(context, state, orderListData)
                          )
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    i18n.$trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": "${snapshot.error}"}
                    )
                )
            );
          } else {
            return Scaffold(
                body: widgets.loadingNotice()
            );
          }
        }
    );
  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    if (state is AssignedOrderReportStartCodeState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_started'));

      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_DETAIL,
          pk: state.pk
      ));
    }

    if (state is AssignedOrderReportEndCodeState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_ended'));

      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_DETAIL,
          pk: state.pk
      ));
    }

    if (state is AssignedOrderReportAfterEndCodeState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_ended'));

      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_DETAIL,
          pk: state.pk
      ));
    }

    if (state is AssignedOrderReportExtraOrderState) {
      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_DETAIL,
          pk: state.result['new_assigned_order']
      ));
    }

    if (state is AssignedOrderReportNoWorkorderFinishedState) {
      bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_ALL
      ));
    }
  }

  Widget _getBody(context, state, OrderPageMetaData? orderListData) {
    if (state is AssignedOrderErrorState) {
      return AssignedOrderListErrorWidget(
        error: state.message,
        memberPicture: orderListData!.memberPicture,
        widgetsIn: widgets,
        orderListData: orderListData,
      );
    }

    if (state is AssignedOrderLoadedState) {
      return AssignedWidget(
        assignedOrder: state.assignedOrder,
        memberPicture: orderListData!.memberPicture,
        widgetsIn: widgets,
      );
    }

    if (state is AssignedOrdersLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.assignedOrders!.count,
          next: state.assignedOrders!.next,
          previous: state.assignedOrders!.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: orderListData!.pageSize
      );

      if (state.assignedOrders!.results!.length == 0) {
        return AssignedOrderListEmptyWidget(
            orderListData: orderListData,
            memberPicture: orderListData.memberPicture,
            paginationInfo: paginationInfo,
            widgetsIn: widgets,
        );
      }

      return AssignedOrderListWidget(
          orderList: state.assignedOrders!.results,
          orderListData: orderListData,
          paginationInfo: paginationInfo,
          searchQuery: state.query,
          widgetsIn: widgets,
      );
    }

    return widgets.loadingNotice();
  }
}
