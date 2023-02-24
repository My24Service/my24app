import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/blocs/material_states.dart';
import 'package:my24app/mobile/widgets/material/list.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/mobile/widgets/material/empty.dart';
import 'package:my24app/mobile/widgets/material/error.dart';
import 'package:my24app/mobile/widgets/material/form.dart';


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
      return MaterialListErrorWidget(
          error: state.message,
      );
    }

    if (state is MaterialsLoadedState) {
      if (state.materials.results.length == 0) {
        return MaterialListEmptyWidget();
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.materials.count,
          next: state.materials.next,
          previous: state.materials.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return MaterialListWidget(
          materials: state.materials,
          assignedOrderId: assignedOrderId,
          paginationInfo: paginationInfo,
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
