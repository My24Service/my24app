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
  bool firstTime = true;

  MaterialBloc _initalBlocCall() {
    final bloc = MaterialBloc();

    if (firstTime) {
      bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
      bloc.add(MaterialEvent(
          status: MaterialEventStatus.FETCH_ALL,
          value: widget.assignedOrderPk
      ));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initalBlocCall(),
        child: BlocConsumer<MaterialBloc, AssignedOrderMaterialState>(
          listener: (context, state) {
            _handleListeners(context, state);
          },
          builder: (context, state) {
            return Scaffold(
                appBar: AppBar(
                  title: new Text('assigned_orders.materials.app_bar_title'.tr()),
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

  void _handleListeners(context, state) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

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
      print('MaterialDeletedState');
      print(state.result);
      if (state.result == true) {
        createSnackBar(context, 'assigned_orders.materials.snackbar_deleted'.tr());

        bloc.add(MaterialEvent(
            status: MaterialEventStatus.FETCH_ALL,
            value: widget.assignedOrderPk
        ));

        // setState(() {});
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'assigned_orders.materials.error_dialog_content_delete'.tr()
        );
        setState(() {});
      }
    }
  }

  Widget _getBody(BuildContext context, state) {
    if (state is MaterialErrorState) {
      return errorNotice(state.message);
    }

    if (state is MaterialsLoadedState) {
      print('MaterialsLoadedState, materials: ${state.materials.results.length}');
      return MaterialWidget(
        materials: state.materials,
        assignedOrderPk: widget.assignedOrderPk,
      );
    }

    return loadingNotice();
  }
}
