import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/company/blocs/time_registration_bloc.dart';
import 'package:my24app/core/models/models.dart';

mixin TimeRegistrationMixin {
  final PaginationInfo? paginationInfo = null;
  final String? searchQuery = null;
  final TextEditingController searchController = TextEditingController();

  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<TimeRegistrationBloc>(context);

    bloc.add(TimeRegistrationEvent(status: TimeRegistrationEventStatus.DO_ASYNC));
    bloc.add(TimeRegistrationEvent(
        status: TimeRegistrationEventStatus.FETCH_ALL,
    ));
  }
}
