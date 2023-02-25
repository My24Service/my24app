import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/widgets/assigned/detail.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/blocs/assignedorder_states.dart';
import 'package:my24app/mobile/pages/assigned_list.dart';
import 'package:my24app/core/i18n_mixin.dart';


class AssignedOrderPage extends StatelessWidget with i18nMixin {
  final String basePath = "assigned_orders.detail";
  final int assignedOrderPk;

  AssignedOrderPage({
    Key key,
    this.assignedOrderPk
  }) : super(key: key);


  AssignedOrderBloc _initialBlocCall() {
    AssignedOrderBloc bloc = AssignedOrderBloc();

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.FETCH_DETAIL,
        value: assignedOrderPk
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssignedOrderBloc>(
      create: (context) => _initialBlocCall(),
      child: BlocConsumer<AssignedOrderBloc, AssignedOrderState>(
          listener: (context, state) {
            _handleListeners(context, state);
          },
          builder: (context, state) {
            return Scaffold(
                body: _getBody(context, state)
            );
          }
      ),
    );
  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    if (state is AssignedOrderReportStartCodeState) {
      createSnackBar(context, $trans('snackbar_started'));

      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_DETAIL,
          value: assignedOrderPk
      ));
    }

    if (state is AssignedOrderReportEndCodeState) {
      createSnackBar(context, $trans('snackbar_ended'));

      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_DETAIL,
          value: assignedOrderPk
      ));
    }

    if (state is AssignedOrderReportAfterEndCodeState) {
      createSnackBar(context, $trans('snackbar_ended'));

      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_DETAIL,
          value: assignedOrderPk
      ));
    }

    if (state is AssignedOrderReportExtraOrderState) {
      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_DETAIL,
          value: state.result['new_assigned_order']
      ));
    }

    if (state is AssignedOrderReportNoWorkorderFinishedState) {
      final page = AssignedOrderListPage();

      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (context) => page
          )
      );
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
