import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/inventory/blocs/location_inventory_bloc.dart';
import 'package:my24app/inventory/blocs/location_inventory_states.dart';
import 'package:my24app/inventory/models/api.dart';
import 'package:my24app/inventory/models/models.dart';
import 'package:my24app/inventory/widgets/location_inventory/error.dart';
import 'package:my24app/inventory/widgets/location_inventory/main.dart';
import 'package:my24app/core/widgets/drawers.dart';

class LocationInventoryPage extends StatelessWidget with i18nMixin {
  final inventoryApi = InventoryApi();
  final Utils utils = Utils();
  final LocationInventoryBloc bloc;

  LocationInventoryPage({
    Key key,
    @required this.bloc
  }) : super(key: key);

  Future<LocationInventoryPageData> getPageData(BuildContext context) async {
    StockLocations locations = await this.inventoryApi.list();
    String memberPicture = await this.utils.getMemberPicture();
    String submodel = await this.utils.getUserSubmodel();

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
            LocationInventoryPageData pageData = snapshot.data;

            return BlocProvider<LocationInventoryBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<LocationInventoryBloc, LocationInventoryState>(
                    listener: (context, state) {
                      _handleListeners(context, state, pageData);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: pageData.drawer,
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
            print('snapshot.error: ${snapshot.error}');
            return Center(
                child: Text(
                    $trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": snapshot.error}))
            );
          } else {
            return loadingNotice();
          }
        }
    );
  }

  void _handleListeners(BuildContext context, state, LocationInventoryPageData pageData) {
    final bloc = BlocProvider.of<LocationInventoryBloc>(context);

    if (state is LocationInventoryNewState) {
      state.formData.locationId = pageData.locations.results[0].id;
      bloc.add(LocationInventoryEvent(
        status: LocationInventoryEventStatus.UPDATE_FORM_DATA,
        formData: state.formData,
      ));
    }
  }

  Widget _getBody(context, state, LocationInventoryPageData pageData) {
    if (state is LocationInventoryInitialState) {
      return loadingNotice();
    }

    if (state is LocationInventoryLoadingState) {
      return loadingNotice();
    }

    if (state is LocationInventoryErrorState) {
      return LocationInventoryListErrorWidget(
          error: state.message,
          memberPicture: pageData.memberPicture
      );
    }

    if (state is LocationInventoryLoadedState) {
      return LocationInventoryWidget(
          formData: state.formData,
          memberPicture: pageData.memberPicture,
      );
    }

    return loadingNotice();
  }
}
