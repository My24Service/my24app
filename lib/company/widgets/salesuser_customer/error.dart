import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/company/blocs/salesuser_customer_bloc.dart';

class SalesUserCustomerListErrorWidget extends BaseErrorWidget with i18nMixin {
  final String basePath = "company.salesuser_customer";
  final String memberPicture;
  final String error;

  SalesUserCustomerListErrorWidget({
    Key key,
    @required this.error,
    @required this.memberPicture,
  }) : super(
      key: key,
      error: error,
      memberPicture: memberPicture
  );

  @override
  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

    bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
    bloc.add(SalesUserCustomerEvent(
      status: SalesUserCustomerEventStatus.FETCH_ALL,
    ));
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }
}
