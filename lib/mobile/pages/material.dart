import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/blocs/material_states.dart';
import 'package:my24app/mobile/widgets/material_form.dart';
import 'package:my24app/mobile/widgets/material_list.dart';

import '../../core/models/models.dart';
import '../../core/utils.dart';
import '../../inventory/api/inventory_api.dart';
import '../../inventory/models/models.dart';


class AssignedOrderMaterialPage extends StatelessWidget {
  final int assignedOrderId;

  AssignedOrderMaterialPage({
    Key key,
    this.assignedOrderId
  }) : super(key: key);

  MaterialBloc _initialBlocCall() {
    MaterialBloc bloc = MaterialBloc();

    bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
    bloc.add(MaterialEvent(
        status: MaterialEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MaterialPageData>(
        future: utils.getMaterialPageData(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            MaterialPageData materialPageData = snapshot.data;

            return BlocProvider<MaterialBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<MaterialBloc, AssignedOrderMaterialState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          body: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: _getBody(context, state, materialPageData),
                          )
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text("An error occurred (${snapshot.error})"));
          } else {
            return loadingNotice();
          }
        }
    );
  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    if (state is MaterialInsertedState) {
      createSnackBar(context, 'assigned_orders.materials.snackbar_added'.tr());

      bloc.add(MaterialEvent(
          status: MaterialEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is MaterialUpdatedState) {
      createSnackBar(context, 'assigned_orders.materials.snackbar_updated'.tr());

      bloc.add(MaterialEvent(
          status: MaterialEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is MaterialDeletedState) {
      createSnackBar(context, 'assigned_orders.materials.snackbar_deleted'.tr());

      bloc.add(MaterialEvent(
          status: MaterialEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }
  }

  Widget _getBody(context, state, MaterialPageData materialPageData) {
    if (state is MaterialInitialState) {
      return loadingNotice();
    }

    if (state is MaterialLoadingState) {
      return loadingNotice();
    }

    if (state is MaterialErrorState) {
      return MaterialListWidget(
          materials: null,
          error: state.message,
          assignedOrderId: assignedOrderId
      );
    }

    if (state is MaterialsLoadedState) {
      return MaterialListWidget(
          materials: state.materials,
          assignedOrderId: assignedOrderId
      );
    }

    if (state is MaterialLoadedState) {
      return MaterialFormWidget(
          material: state.materialFormData,
          assignedOrderId: assignedOrderId,
          materialPageData: materialPageData
      );
    }

    if (state is MaterialNewState) {
      state.materialFormData.location = materialPageData.preferedLocation;

      return MaterialFormWidget(
          material: state.materialFormData,
          assignedOrderId: assignedOrderId,
          materialPageData: materialPageData
      );
    }

    return loadingNotice();
  }
}
