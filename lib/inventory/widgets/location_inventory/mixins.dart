import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/inventory/blocs/location_inventory_bloc.dart';


mixin LocationInventoryMixin {
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<LocationInventoryBloc>(context);

    bloc.add(LocationInventoryEvent(status: LocationInventoryEventStatus.DO_ASYNC));
    bloc.add(LocationInventoryEvent(
      status: LocationInventoryEventStatus.NEW,
    ));
  }
}
