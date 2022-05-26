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
  CustomerHistoryBloc bloc = CustomerHistoryBloc();

  @override
  Widget build(BuildContext context) {
    _initalBlocCall() {
      final bloc = CustomerHistoryBloc();
      bloc.add(CustomerHistoryEvent(status: CustomerHistoryEventStatus.DO_ASYNC));
      bloc.add(CustomerHistoryEvent(
          status: CustomerHistoryEventStatus.FETCH_ALL,
          value: widget.customerPk
      ));

      return bloc;
    }

    return BlocProvider(
        create: (BuildContext context) => _initalBlocCall(),
        child: Scaffold(
            appBar: AppBar(
              title: new Text(
                  'customers.history.app_bar_title'.tr(
                      namedArgs: {'customer': widget.customerName})),
            ),
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: BlocListener<CustomerHistoryBloc, CustomerHistoryState>(
                    listener: (context, state) async {
                    },
                    child: BlocBuilder<CustomerHistoryBloc, CustomerHistoryState>(
                        builder: (context, state) {
                          bloc = BlocProvider.of<CustomerHistoryBloc>(context);

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
                    )
                )
            )
        )
    );
  }
}
