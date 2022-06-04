import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/customer_history_bloc.dart';
import 'package:my24app/mobile/blocs/customer_history_states.dart';
import 'package:my24app/mobile/widgets/customer_history.dart';


class CustomerHistoryPage extends StatefulWidget {
  final int customerPk;
  final String customerName;

  CustomerHistoryPage({
    Key key,
    this.customerPk,
    this.customerName,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _CustomerHistoryPageState();
}

class _CustomerHistoryPageState extends State<CustomerHistoryPage> {
  bool firstTime = true;

  CustomerHistoryBloc _initalBlocCall() {
    final bloc = CustomerHistoryBloc();

    if (firstTime) {
      bloc.add(CustomerHistoryEvent(status: CustomerHistoryEventStatus.DO_ASYNC));
      bloc.add(CustomerHistoryEvent(
          status: CustomerHistoryEventStatus.FETCH_ALL,
          value: widget.customerPk
      ));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initalBlocCall(),
        child: BlocConsumer<CustomerHistoryBloc, CustomerHistoryState>(
          listener: (context, state) {},
          builder: (context, state) {
            return Scaffold(
                appBar: AppBar(
                  title: new Text(
                      'customers.history.app_bar_title'.tr(
                          namedArgs: {'customer': widget.customerName})),
                ),
                body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: _getBody(context, state)
                )
            );
          }
      )
    );
  }

  Widget _getBody(context, state) {
    if (state is CustomerHistoryInitialState) {
      return loadingNotice();
    }

    if (state is CustomerHistoryLoadingState) {
      return loadingNotice();
    }

    if (state is CustomerHistoryErrorState) {
      return errorNotice(state.message);
    }

    if (state is CustomerHistoryLoadedState) {
      return CustomerHistoryWidget(
        customerHistory: state.customerHistory,
      );
    }

    return loadingNotice();
  }
}
