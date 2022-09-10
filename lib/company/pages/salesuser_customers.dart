import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/company/blocs/salesuser_customers_bloc.dart';
import 'package:my24app/company/blocs/salesuser_customers_states.dart';
import 'package:my24app/company/widgets/salesuser_customers.dart';
import 'package:my24app/core/widgets/widgets.dart';

class SalesUserCustomersPage extends StatefulWidget {
  SalesUserCustomersPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _SalesUserCustomersPageState();
}

class _SalesUserCustomersPageState extends State<SalesUserCustomersPage> {
  bool firstTime = true;

  SalesUserCustomerBloc _initialBlocCall() {
    SalesUserCustomerBloc bloc = SalesUserCustomerBloc();

    if (firstTime) {
      bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
      bloc.add(SalesUserCustomerEvent(
          status: SalesUserCustomerEventStatus.FETCH_ALL));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialBlocCall(),
        child: BlocConsumer<SalesUserCustomerBloc, SalesUserCustomerState>(
          listener: (context, state) {
            _handleListeners(context, state);
          },
          builder: (context, state) {
            return Scaffold(
                appBar: AppBar(
                    title: Text('sales.customers.app_bar_title'.tr())),
                body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: _getBody(context, state)
                )
            );
          }
      )
    );
  }

  void _handleListeners(BuildContext context, state) {
    final SalesUserCustomerBloc bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

    if (state is SalesUserCustomerDeletedState) {
      if (state.result == true) {
        createSnackBar(context, 'sales.customers.snackbar_deleted'.tr());

        bloc.add(SalesUserCustomerEvent(
            status: SalesUserCustomerEventStatus.DO_ASYNC));
        bloc.add(SalesUserCustomerEvent(
            status: SalesUserCustomerEventStatus.FETCH_ALL));
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'sales.customers.error_deleting_dialog_content'.tr()
        );
      }
    }
  }

  Widget _getBody(context, state) {
    final SalesUserCustomerBloc bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

    if (state is SalesUserCustomerInitialState) {
      return loadingNotice();
    }

    if (state is SalesUserCustomerLoadingState) {
      return loadingNotice();
    }

    if (state is SalesUserCustomerErrorState) {
      return errorNoticeWithReload(
          state.message,
          bloc,
          SalesUserCustomerEvent(
              status: SalesUserCustomerEventStatus.FETCH_ALL)
      );
    }

    if (state is SalesUserCustomersLoadedState) {
      return SalesUserCustomerListWidget(customers: state.customers);
    }

    return loadingNotice();
  }
}
