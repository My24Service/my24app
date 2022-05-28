import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/customer/blocs/customer_states.dart';
import 'package:my24app/customer/widgets/detail.dart';
import 'package:my24app/core/widgets/widgets.dart';

class CustomerDetailPage extends StatefulWidget {
  final int customerPk;

  CustomerDetailPage({
    Key key,
    @required this.customerPk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  CustomerBloc _getInitialBloc() {
    final CustomerBloc bloc = CustomerBloc();

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
        status: CustomerEventStatus.FETCH_DETAIL,
        value: widget.customerPk
    ));

    return bloc;
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
        bloc: _getInitialBloc(),
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                  title: Text('customers.detail.app_bar_title'.tr())),
              body: _getBody(context, state)
          );
        }
    );
  }

  Widget _getBody(context, state) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    if (state is CustomerInitialState) {
      return loadingNotice();
    }

    if (state is CustomerLoadingState) {
      return loadingNotice();
    }

    if (state is CustomerErrorState) {
      return errorNoticeWithReload(
          state.message,
          bloc,
          CustomerEvent(
              status: CustomerEventStatus.FETCH_DETAIL,
              value: widget.customerPk
          )
      );
    }

    if (state is CustomerLoadedState) {
      return CustomerDetailWidget(customer: state.customer);
    }

    return loadingNotice();
  }
}
