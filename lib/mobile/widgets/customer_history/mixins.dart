import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/mobile/blocs/customer_history_bloc.dart';


mixin CustomerHistoryMixin {
  final int customerPk = 0;

  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<CustomerHistoryBloc>(context);

    bloc.add(CustomerHistoryEvent(status: CustomerHistoryEventStatus.DO_ASYNC));
    bloc.add(CustomerHistoryEvent(
        status: CustomerHistoryEventStatus.FETCH_ALL,
        customerPk: customerPk
    ));
  }
}
