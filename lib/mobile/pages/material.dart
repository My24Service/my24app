import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/blocs/material_states.dart';
import 'package:my24app/mobile/widgets/material.dart';


class AssignedOrderMaterialPage extends StatefulWidget {
  final int assignedOrderPk;

  AssignedOrderMaterialPage({
    Key key,
    this.assignedOrderPk
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _AssignedOrderMaterialPageState();
}

class _AssignedOrderMaterialPageState extends State<AssignedOrderMaterialPage> {
  MaterialBloc bloc = MaterialBloc();

  @override
  Widget build(BuildContext context) {
    _initalBlocCall() {
      final bloc = MaterialBloc();
      bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
      bloc.add(MaterialEvent(
          status: MaterialEventStatus.FETCH_ALL,
          value: widget.assignedOrderPk
      ));

      return bloc;
    }

    return BlocProvider(
        create: (BuildContext context) => _initalBlocCall(),
        child: Scaffold(
            appBar: AppBar(
              title: new Text('assigned_orders.materials.app_bar_title'.tr()),
            ),
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: BlocListener<MaterialBloc, AssignedOrderMaterialState>(
                    listener: (context, state) async {
                      if (state is MaterialInsertedState) {
                        createSnackBar(context, 'assigned_orders.materials.snackbar_added'.tr());

                        bloc.add(MaterialEvent(
                            status: MaterialEventStatus.FETCH_ALL,
                            value: widget.assignedOrderPk
                        ));
                      }

                      if (state is MaterialUpdatedState) {
                        createSnackBar(context, 'assigned_orders.materials.snackbar_updated'.tr());

                        bloc.add(MaterialEvent(
                            status: MaterialEventStatus.FETCH_ALL,
                            value: widget.assignedOrderPk
                        ));
                      }

                      if (state is MaterialDeletedState) {
                        if (state.result == true) {
                          createSnackBar(context, 'assigned_orders.materials.snackbar_deleted'.tr());

                          bloc.add(MaterialEvent(
                              status: MaterialEventStatus.FETCH_ALL,
                              value: widget.assignedOrderPk
                          ));

                          setState(() {});
                        } else {
                          displayDialog(context,
                              'generic.error_dialog_title'.tr(),
                              'assigned_orders.materials.error_dialog_content_delete'.tr()
                          );
                          setState(() {});
                        }
                      }
                    },
                    child: BlocBuilder<MaterialBloc, AssignedOrderMaterialState>(
                        builder: (context, state) {
                          bloc = BlocProvider.of<MaterialBloc>(context);

                          if (state is MaterialInitialState) {
                            return loadingNotice();
                          }

                          if (state is MaterialLoadingState) {
                            return loadingNotice();
                          }

                          if (state is MaterialErrorState) {
                            return errorNotice(state.message);
                          }

                          if (state is MaterialsLoadedState) {
                            return MaterialWidget(
                              materials: state.materials,
                              assignedOrderPk: widget.assignedOrderPk,
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
