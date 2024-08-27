import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:my24_flutter_core/utils.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/blocs/material_states.dart';
import 'package:my24app/mobile/widgets/material/list.dart';
import 'package:my24app/common/utils.dart';
import 'package:my24app/mobile/widgets/material/error.dart';
import 'package:my24app/mobile/widgets/material/form.dart';
import 'package:my24app/company/models/engineer/models.dart';
import 'package:my24app/inventory/models/location/api.dart';
import 'package:my24app/inventory/models/location/models.dart';
import '../models/material/models.dart';

final log = Logger('mobile.pages.material');

String? initialLoadMode;
int? loadId;

class AssignedOrderMaterialPage extends StatelessWidget{
  final int? assignedOrderId;
  final int? quotationId;
  final i18n = My24i18n(basePath: "assigned_orders.materials");
  final locationApi = LocationApi();
  final Utils utils = Utils();
  final AssignedOrderMaterialBloc bloc;
  final CoreWidgets widgets = CoreWidgets();

  AssignedOrderMaterialPage({
    Key? key,
    this.assignedOrderId,
    this.quotationId,
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
    StockLocations locations = await this.locationApi.list();
    EngineerUser engineer = await this.utils.getUserInfo();
    String? memberPicture = await coreUtils.getMemberPicture();

    MaterialPageData result = MaterialPageData(
        memberPicture: memberPicture,
        locations: locations,
        preferredLocation: engineer.engineer!.preferredLocation
    );

    return result;
  }

  AssignedOrderMaterialBloc _initialBlocCall() {
    if (initialLoadMode == null) {
      bloc.add(AssignedOrderMaterialEvent(status: AssignedOrderMaterialEventStatus.DO_ASYNC));
      bloc.add(AssignedOrderMaterialEvent(
          status: AssignedOrderMaterialEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    } else if (initialLoadMode == 'form') {
      bloc.add(AssignedOrderMaterialEvent(status: AssignedOrderMaterialEventStatus.DO_ASYNC));
      bloc.add(AssignedOrderMaterialEvent(
          status: AssignedOrderMaterialEventStatus.FETCH_DETAIL,
          pk: loadId
      ));
    } else if (initialLoadMode == 'new') {
      bloc.add(AssignedOrderMaterialEvent(
          status: AssignedOrderMaterialEventStatus.NEW,
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

            return BlocProvider<AssignedOrderMaterialBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<AssignedOrderMaterialBloc, AssignedOrderMaterialState>(
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
            log.severe("future builder: ${snapshot.error}");
            return Center(
                child: Text(
                    i18n.$trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": "${snapshot.error}"}
                    )
                )
            );
          } else {
            return Scaffold(
                body: widgets.loadingNotice()
            );
          }
        }
    );
  }

  void _handleListeners(BuildContext context, state) {
    log.info("_handleListeners state: $state");
    final bloc = BlocProvider.of<AssignedOrderMaterialBloc>(context);

    if (state is MaterialInsertedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_added'));

      bloc.add(AssignedOrderMaterialEvent(
        status: AssignedOrderMaterialEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId,
      ));
    }

    if (state is MaterialUpdatedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_updated'));

      bloc.add(AssignedOrderMaterialEvent(
          status: AssignedOrderMaterialEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is MaterialDeletedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_deleted'));

      bloc.add(AssignedOrderMaterialEvent(
          status: AssignedOrderMaterialEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is MaterialsLoadedState && state.query == null &&
        state.materials!.results!.length == 0) {
      bloc.add(AssignedOrderMaterialEvent(
          status: AssignedOrderMaterialEventStatus.NEW_EMPTY,
          assignedOrderId: assignedOrderId
      ));
    }
  }

  Widget _getBody(context, state, MaterialPageData? materialPageData) {
    log.info("_getBody state: $state");
    if (state is MaterialInitialState) {
      return widgets.loadingNotice();
    }

    if (state is MaterialLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is MaterialErrorState) {
      return MaterialListErrorWidget(
        error: state.message,
        memberPicture: materialPageData!.memberPicture,
        widgetsIn: widgets,
        i18nIn: i18n,
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
        widgetsIn: widgets,
        i18nIn: i18n,
        quotationId: quotationId,
      );
    }

    if (state is MaterialNewMaterialCreatedState) {
      return MaterialFormWidget(
        material: state.materialFormData,
        assignedOrderId: assignedOrderId,
        materialPageData: materialPageData!,
        newFromEmpty: false,
        widgetsIn: widgets,
        i18nIn: i18n,
        isMaterialCreated: true,
      );
    }

    if (state is MaterialLoadedState) {
      return MaterialFormWidget(
        material: state.materialFormData,
        assignedOrderId: assignedOrderId,
        materialPageData: materialPageData!,
        newFromEmpty: false,
        widgetsIn: widgets,
        i18nIn: i18n,
        isMaterialCreated: false
      );
    }

    if (state is MaterialNewState) {
      state.materialFormData!.location = materialPageData!.preferredLocation;

      return MaterialFormWidget(
        material: state.materialFormData,
        assignedOrderId: assignedOrderId,
        materialPageData: materialPageData,
        newFromEmpty: state.fromEmpty,
        widgetsIn: widgets,
        i18nIn: i18n,
        isMaterialCreated: false,
        quotationMaterials: state.quotationMaterials,
      );
    }

    return widgets.loadingNotice();
  }
}
