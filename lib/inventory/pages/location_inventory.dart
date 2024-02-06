import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/inventory/blocs/location_inventory_bloc.dart';
import 'package:my24app/inventory/blocs/location_inventory_states.dart';
import 'package:my24app/inventory/models/api.dart';
import 'package:my24app/inventory/models/models.dart';
import 'package:my24app/inventory/widgets/location_inventory/error.dart';
import 'package:my24app/inventory/widgets/location_inventory/main.dart';
import 'package:my24app/common/widgets/drawers.dart';
import 'package:my24app/common/utils.dart';

class LocationInventoryPage extends StatelessWidget{
  final i18n = My24i18n(basePath: "location_inventory");
  final inventoryApi = InventoryApi();
  final Utils utils = Utils();
  final LocationInventoryBloc bloc;
  final CoreWidgets widgets = CoreWidgets();

  LocationInventoryPage({
    Key? key,
    required this.bloc
  }) : super(key: key);

  Future<LocationInventoryPageData> getPageData(BuildContext context) async {
    StockLocations locations = await this.inventoryApi.list();
    String? memberPicture = await this.utils.getMemberPicture();
    String? submodel = await this.utils.getUserSubmodel();

    LocationInventoryPageData result = LocationInventoryPageData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        memberPicture: memberPicture,
        locations: locations,
    );

    return result;
  }

  LocationInventoryBloc _initialBlocCall() {
    bloc.add(LocationInventoryEvent(status: LocationInventoryEventStatus.DO_ASYNC));
    bloc.add(LocationInventoryEvent(
        status: LocationInventoryEventStatus.NEW,
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationInventoryPageData>(
        future: getPageData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            LocationInventoryPageData? pageData = snapshot.data;

            return BlocProvider<LocationInventoryBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<LocationInventoryBloc, LocationInventoryState>(
                    listener: (context, state) {
                      _handleListeners(context, state, pageData);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: pageData!.drawer,
                          body: _getBody(context, state, pageData),
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    i18n.$trans("generic.error_arg",
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

  void _handleListeners(BuildContext context, state, LocationInventoryPageData? pageData) {
    final bloc = BlocProvider.of<LocationInventoryBloc>(context);

    if (state is LocationInventoryNewState) {
      state.formData!.locations = pageData!.locations;
      state.formData!.locationId = pageData.locations.results![0].id;
      state.formData!.location = pageData.locations.results![0].name;
      bloc.add(LocationInventoryEvent(
        status: LocationInventoryEventStatus.UPDATE_FORM_DATA,
        formData: state.formData,
      ));
    }
  }

  Widget _getBody(context, state, LocationInventoryPageData? pageData) {
    if (state is LocationInventoryInitialState) {
      return widgets.loadingNotice();
    }

    if (state is LocationInventoryLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is LocationInventoryErrorState) {
      return LocationInventoryListErrorWidget(
          error: state.message,
          memberPicture: pageData!.memberPicture,
          widgetsIn: widgets,
          i18nIn: i18n,
      );
    }

    if (state is LocationInventoryLoadedState) {
      return LocationInventoryWidget(
          formData: state.formData,
          memberPicture: pageData!.memberPicture,
          widgetsIn: widgets,
          i18nIn: i18n,
      );
    }

    return widgets.loadingNotice();
  }
}
