import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/blocs/material_states.dart';
import 'package:my24app/mobile/widgets/material/list.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/mobile/widgets/material/error.dart';
import 'package:my24app/mobile/widgets/material/form.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/company/models/models.dart';
import 'package:my24app/inventory/models/api.dart';
import 'package:my24app/inventory/models/models.dart';
import '../models/material/models.dart';

String? initialLoadMode;
int? loadId;

class AssignedOrderMaterialPage extends StatelessWidget with i18nMixin {
  final int? assignedOrderId;
  final String basePath = "assigned_orders.materials";
  final inventoryApi = InventoryApi();
  final Utils utils = Utils();
  final MaterialBloc bloc;

  AssignedOrderMaterialPage({
    Key? key,
    this.assignedOrderId,
    required this.bloc,
    String? initialMode,
    int? pk
  }) : super(key: key) {
    if (initialMode != null) {
      initialLoadMode = initialMode;
      loadId = pk;
    }
  }

  Future<MaterialPageData> getMaterialPageData() async {
    StockLocations locations = await this.inventoryApi.list();
    var userData = await this.utils.getUserInfo();
    EngineerUser engineer = userData['user'];
    String? memberPicture = await this.utils.getMemberPicture();

    MaterialPageData result = MaterialPageData(
        memberPicture: memberPicture,
        locations: locations,
        preferedLocation: engineer.engineer!.preferedLocation
    );

    return result;
  }

  MaterialBloc _initialBlocCall() {
    if (initialLoadMode == null) {
      bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
      bloc.add(MaterialEvent(
          status: MaterialEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    } else if (initialLoadMode == 'form') {
      bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
      bloc.add(MaterialEvent(
          status: MaterialEventStatus.FETCH_DETAIL,
          pk: loadId
      ));
    } else if (initialLoadMode == 'new') {
      bloc.add(MaterialEvent(
          status: MaterialEventStatus.NEW,
          assignedOrderId: assignedOrderId
      ));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MaterialPageData>(
        future: getMaterialPageData(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            MaterialPageData? materialPageData = snapshot.data;

            return BlocProvider<MaterialBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<MaterialBloc, AssignedOrderMaterialState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          body: _getBody(context, state, materialPageData),
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
                child: Text(
                  $trans("error_arg", pathOverride: "generic",
                    namedArgs: {"error": snapshot.error as String?}))
            );
          } else {
            return Scaffold(
                body: loadingNotice()
            );
          }
        }
    );
  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    if (state is MaterialInsertedState) {
      createSnackBar(context, $trans('snackbar_added'));

      bloc.add(MaterialEvent(
        status: MaterialEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId,
      ));
    }

    if (state is MaterialUpdatedState) {
      createSnackBar(context, $trans('snackbar_updated'));

      bloc.add(MaterialEvent(
          status: MaterialEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is MaterialDeletedState) {
      createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(MaterialEvent(
          status: MaterialEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is MaterialsLoadedState && state.query == null &&
        state.materials!.results!.length == 0) {
      bloc.add(MaterialEvent(
          status: MaterialEventStatus.NEW_EMPTY,
          assignedOrderId: assignedOrderId
      ));
    }
  }

  Widget _getBody(context, state, MaterialPageData? materialPageData) {
    if (state is MaterialInitialState) {
      return loadingNotice();
    }

    if (state is MaterialLoadingState) {
      return loadingNotice();
    }

    if (state is MaterialErrorState) {
      return MaterialListErrorWidget(
          error: state.message,
          memberPicture: materialPageData!.memberPicture
      );
    }

    if (state is MaterialsLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.materials!.count,
          next: state.materials!.next,
          previous: state.materials!.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return MaterialListWidget(
          materials: state.materials,
          assignedOrderId: assignedOrderId,
          paginationInfo: paginationInfo,
          memberPicture: materialPageData!.memberPicture,
          searchQuery: state.query,
      );
    }

    if (state is MaterialLoadedState) {
      return MaterialFormWidget(
          material: state.materialFormData,
          assignedOrderId: assignedOrderId,
          materialPageData: materialPageData!,
          newFromEmpty: false,
      );
    }

    if (state is MaterialNewState) {
      state.materialFormData!.location = materialPageData!.preferedLocation;

      return MaterialFormWidget(
          material: state.materialFormData,
          assignedOrderId: assignedOrderId,
          materialPageData: materialPageData,
          newFromEmpty: state.fromEmpty,
      );
    }

    return loadingNotice();
  }
}
