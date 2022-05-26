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
  SalesUserCustomerBloc bloc = SalesUserCustomerBloc();

  SalesUserCustomerBloc _initialBlocCall() {
    bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
    bloc.add(SalesUserCustomerEvent(
        status: SalesUserCustomerEventStatus.FETCH_ALL));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => _initialBlocCall(),
        child: Builder(
            builder: (BuildContext context) {
              bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

              return Scaffold(
                  appBar: AppBar(
                      title: Text('sales.customers.app_bar_title'.tr())),
                  body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child:_getBody(bloc),
                  )
              );
            }
        )
    );
  }

  Widget _getBody(SalesUserCustomerBloc bloc) {
    return BlocListener<SalesUserCustomerBloc, SalesUserCustomerState>(
        listener: (context, state) {
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
        },
        child: BlocBuilder<SalesUserCustomerBloc, SalesUserCustomerState>(
            builder: (context, state) {
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
        )
    );
  }
}
