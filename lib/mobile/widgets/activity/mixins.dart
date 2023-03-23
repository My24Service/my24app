import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';


mixin ActivityMixin {
  final int assignedOrderId = 0;

  Widget getBottomSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createButton(
          () { handleNew(context); },
          title: 'assigned_orders.activity.button_add'.tr(),
        )
      ],
    );
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<ActivityBloc>(context);

    bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
    bloc.add(ActivityEvent(
        status: ActivityEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId
    ));
  }

  handleNew(BuildContext context) {
    final bloc = BlocProvider.of<ActivityBloc>(context);

    bloc.add(ActivityEvent(
        status: ActivityEventStatus.NEW,
        assignedOrderId: assignedOrderId
    ));
  }
}
