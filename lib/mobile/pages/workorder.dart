import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/blocs/workorder_bloc.dart';
import 'package:my24app/mobile/blocs/workorder_states.dart';
import 'package:my24app/mobile/widgets/workorder.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/mobile/models/assignedorder/api.dart';
import 'package:my24app/mobile/models/workorder/models.dart';
import 'assigned.dart';

class WorkorderPage extends StatelessWidget with i18nMixin {
  final String basePath = "assigned_orders.workorder";
  final int? assignedOrderId;
  final WorkorderBloc bloc;
  final Utils utils = Utils();
  final AssignedOrderApi assignedOrderApi = AssignedOrderApi();

  Future<AssignedOrderWorkOrderPageData> getPageData() async {
    final String? memberPicture = await this.utils.getMemberPicture();
    final AssignedOrderWorkOrderSign workOrderSign = await assignedOrderApi.fetchWorkOrderSign(
        assignedOrderId!
    );

    AssignedOrderWorkOrderPageData result = AssignedOrderWorkOrderPageData(
      memberPicture: memberPicture,
      workorderData: workOrderSign
    );

    return result;
  }

  WorkorderPage({
    Key? key,
    required this.assignedOrderId,
    required this.bloc,
  }) : super(key: key);

  WorkorderBloc _initialBlocCall() {
    bloc.add(WorkorderEvent(status: WorkorderEventStatus.DO_ASYNC));
    bloc.add(WorkorderEvent(
        status: WorkorderEventStatus.NEW,
        assignedOrderId: assignedOrderId
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AssignedOrderWorkOrderPageData>(
        future: getPageData(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            AssignedOrderWorkOrderPageData? pageData = snapshot.data;

            return BlocProvider<WorkorderBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<WorkorderBloc, WorkorderDataState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          body: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: _getBody(context, state, pageData),
                          )
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
                child: Text(
                    $trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": "${snapshot.error}"}
                    )
                )
            );
          } else {
            return Scaffold(
                body: loadingNotice()
            );
          }
        }
    );
  }

  void _handleListeners(BuildContext context, state) async {
    final bloc = BlocProvider.of<WorkorderBloc>(context);

    if (state is WorkorderDataInsertedState) {
      createSnackBar(context, $trans('snackbar_added'));

      bloc.add(WorkorderEvent(
          status: WorkorderEventStatus.CREATE_WORKORDER_PDF,
          assignedOrderId: assignedOrderId,
          orderPk: state.orderPk
      ));
    }

    if (state is WorkorderPdfCreatedState) {
      createSnackBar(context, $trans('snackbar_workorder_created'));

      await Future.delayed(Duration(seconds: 1));

      // go to assigned order list
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (context) => AssignedOrdersPage(
                bloc: AssignedOrderBloc(),
              )
          )
      );
    }
  }

  Widget _getBody(BuildContext context, state, AssignedOrderWorkOrderPageData? pageData) {
    if (state is WorkorderDataInitialState) {
      return loadingNotice();
    }

    if (state is WorkorderDataLoadingState) {
      return loadingNotice();
    }

    if (state is WorkorderDataErrorState) {
      return errorNotice(state.message!);
    }

    if (state is WorkorderDataLoadedState) {
      return WorkorderWidget(
        formData: state.formData,
        assignedOrderId: assignedOrderId,
        memberPicture: pageData!.memberPicture,
        workorderData: pageData.workorderData,
      );
    }

    if (state is WorkorderDataNewState) {
      state.formData!.assignedOrderWorkorderId = pageData!.workorderData!.assignedOrderWorkorderId;
      return WorkorderWidget(
          formData: state.formData,
          assignedOrderId: assignedOrderId,
          memberPicture: pageData.memberPicture,
          workorderData: pageData.workorderData,
      );
    }

    return loadingNotice();
  }
}
