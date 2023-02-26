import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';


mixin MaterialMixin {
  final int assignedOrderId = 0;

  Widget getBottomSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createButton(
          () { handleNew(context); },
          title: 'assigned_orders.materials.button_add'.tr(),
        )
      ],
    );
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
    bloc.add(MaterialEvent(
        status: MaterialEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId
    ));
  }

  handleNew(BuildContext context) {
    print(assignedOrderId);
    final bloc = BlocProvider.of<MaterialBloc>(context);

    bloc.add(MaterialEvent(
        status: MaterialEventStatus.NEW,
        assignedOrderId: assignedOrderId
    ));
  }
}
