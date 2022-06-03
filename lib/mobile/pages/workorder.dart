import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/workorder_bloc.dart';
import 'package:my24app/mobile/blocs/workorder_states.dart';
import 'package:my24app/mobile/widgets/workorder.dart';


class WorkorderPage extends StatefulWidget {
  final int assignedorderPk;

  WorkorderPage({
    Key key,
    this.assignedorderPk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _WorkorderPageState();
}

class _WorkorderPageState extends State<WorkorderPage> {
  bool firstTime = true;

  WorkorderBloc _initalBlocCall() {
    final bloc = WorkorderBloc();

    if (firstTime) {
      bloc.add(WorkorderEvent(status: WorkorderEventStatus.DO_ASYNC));
      bloc.add(WorkorderEvent(
          status: WorkorderEventStatus.FETCH,
          value: widget.assignedorderPk
      ));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initalBlocCall(),
        child: BlocConsumer(
          bloc: _initalBlocCall(),
          listener: (context, state) {},
          builder: (context, state) {
            return Scaffold(
                appBar: AppBar(
                  title: new Text('assigned_orders.workorder.app_bar_title'.tr()),
                ),
                body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: _getBody(context, state)
                )
            );
          }
      )
    );
  }

  Widget _getBody(context, state) {
    if (state is WorkorderDataInitialState) {
      return loadingNotice();
    }

    if (state is WorkorderDataLoadingState) {
      return loadingNotice();
    }

    if (state is WorkorderDataErrorState) {
      return errorNotice(state.message);
    }

    if (state is WorkorderDataLoadedState) {
      return WorkorderWidget(
        workorderData: state.workorderData,
        assignedOrderPk: widget.assignedorderPk,
      );
    }

    return loadingNotice();
  }
}
