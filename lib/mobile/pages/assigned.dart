import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/widgets/assigned.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/blocs/assignedorder_states.dart';
import 'package:my24app/mobile/pages/assigned_list.dart';


class AssignedOrderPage extends StatefulWidget {
  final int assignedOrderPk;

  AssignedOrderPage({
    Key key,
    this.assignedOrderPk
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _AssignedOrderPageState();
}

class _AssignedOrderPageState extends State<AssignedOrderPage> {
  bool firstTime = true;

  AssignedOrderBloc _initalBlocCall() {
    AssignedOrderBloc bloc = AssignedOrderBloc();

    if (firstTime) {
      bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_DETAIL,
          value: widget.assignedOrderPk
      ));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssignedOrderBloc>(
      create: (context) => _initalBlocCall(),
      child: BlocConsumer<AssignedOrderBloc, AssignedOrderState>(
          listener: (context, state) {
            _handleListeners(context, state);
          },
          builder: (context, state) {
            return Scaffold(
                appBar: AppBar(
                  title: new Text('assigned_orders.detail.app_bar_title'.tr()),
                ),
                body: _getBody(context, state)
            );
          }
      ),
    );
  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    if (state is AssignedOrderReportStartCodeState) {
      if (state.result == true) {
        createSnackBar(context, 'assigned_orders.detail.snackbar_started'.tr());

        bloc.add(AssignedOrderEvent(
            status: AssignedOrderEventStatus.FETCH_DETAIL,
            value: widget.assignedOrderPk
        ));
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'assigned_orders.detail.error_dialog_content_started'.tr()
        );
      }
      // setState(() {});
    }

    if (state is AssignedOrderReportEndCodeState) {
      print('result is true in handleListeners, state is AssignedOrderReportEndCodeState');
      if (state.result == true) {
        print('result is true in handleListeners, adding bloc for FETCH_DETAIL');
        createSnackBar(context, 'assigned_orders.detail.snackbar_ended'.tr());

        bloc.add(AssignedOrderEvent(
            status: AssignedOrderEventStatus.FETCH_DETAIL,
            value: widget.assignedOrderPk
        ));
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'assigned_orders.detail.error_dialog_content_ended'.tr()
        );
      }

      // setState(() {});
    }

    if (state is AssignedOrderReportAfterEndCodeState) {
      if (state.result == true) {
        createSnackBar(context, 'assigned_orders.detail.snackbar_ended'.tr());

        bloc.add(AssignedOrderEvent(
            status: AssignedOrderEventStatus.FETCH_DETAIL,
            value: widget.assignedOrderPk
        ));
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'assigned_orders.detail.error_dialog_content_ended'.tr()
        );
      }
      // setState(() {});
    }

    if (state is AssignedOrderReportExtraOrderState) {
      if (state.result == false) {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'assigned_orders.detail.error_dialog_content_extra_order'.tr()
        );
        // setState(() {});
      } else {
        bloc.add(AssignedOrderEvent(
            status: AssignedOrderEventStatus.FETCH_DETAIL,
            value: state.result['new_assigned_order']
        ));
      }
      // setState(() {});
    }

    if (state is AssignedOrderReportNoWorkorderFinishedState) {
      if (state.result == true) {
        final page = AssignedOrderListPage();

        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) => page
            )
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'assigned_orders.detail.error_dialog_content_ending'.tr()
        );
        // setState(() {});
      }
    }
  }

  Widget _getBody(context, state) {
    if (state is AssignedOrderErrorState) {
      return errorNotice(state.message);
    }

    if (state is AssignedOrderLoadedState) {
      return AssignedWidget(
          assignedOrder: state.assignedOrder
      );
    }

    return loadingNotice();
  }
}
