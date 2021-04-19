import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/workorder_bloc.dart';
import 'package:my24app/mobile/blocs/workorder_states.dart';
import 'package:my24app/mobile/widgets/workorder.dart';

import 'assigned_list.dart';


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
  WorkorderBloc bloc = WorkorderBloc(WorkorderDataInitialState());

  @override
  Widget build(BuildContext context) {
    _initalBlocCall() {
      final bloc = WorkorderBloc(WorkorderDataInitialState());
      bloc.add(WorkorderEvent(status: WorkorderEventStatus.DO_ASYNC));
      bloc.add(WorkorderEvent(
          status: WorkorderEventStatus.FETCH,
          value: widget.assignedorderPk
      ));

      return bloc;
    }

    return BlocProvider(
        create: (BuildContext context) => _initalBlocCall(),
        child: Scaffold(
            appBar: AppBar(
              title: new Text('assigned_orders.workorder.app_bar_title'.tr()),
            ),
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: BlocListener<WorkorderBloc, WorkorderDataState>(
                    listener: (context, state) async {
                      if (state is WorkorderDataInsertedState) {
                        if (state.result == true) {
                          final page = AssignedOrderListPage();
                          createSnackBar(context,
                              'assigned_orders.workorder.snackbar_created'.tr());

                          // go to order list
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(
                                  builder: (context) => page
                              )
                          );
                        } else {
                          displayDialog(context,
                              'generic.error_dialog_title'.tr(),
                              'assigned_orders.workorder.error_creating_dialog_content'.tr()
                          );
                        }
                      }
                    },
                    child: BlocBuilder<WorkorderBloc, WorkorderDataState>(
                        builder: (context, state) {
                          bloc = BlocProvider.of<WorkorderBloc>(context);

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
                    )
                )
            )
        )
    );
  }
}
