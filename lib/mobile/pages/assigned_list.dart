import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/widgets/assigned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/blocs/assignedorder_states.dart';
import 'package:my24app/core/widgets/drawers.dart';


class AssignedOrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AssignedOrderListPageState();
}

class _AssignedOrderListPageState extends State<AssignedOrderListPage> {
  AssignedOrderBloc bloc = AssignedOrderBloc();

  Future<String> _getFirstName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('first_name');
  }

  @override
  Widget build(BuildContext context) {

    _initalBlocCall() {
      final bloc = AssignedOrderBloc();

      bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_ALL
      ));

      return bloc;
    }

    return BlocProvider(
        create: (BuildContext context) => _initalBlocCall(),
        child: FutureBuilder<Widget>(
            future: getDrawerForUser(context),
            builder: (ctx, snapshot) {
              final Widget drawer = snapshot.data;
              bloc = BlocProvider.of<AssignedOrderBloc>(ctx);

              return FutureBuilder<String>(
                  future: _getFirstName(),
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox(height: 0);
                    }

                    final firstName = snapshot.data;

                    return Scaffold(
                      drawer: drawer,
                      appBar: AppBar(
                        title: new Text(
                            'assigned_orders.list.app_bar_title'.tr(
                                namedArgs: {'firstName': firstName})),
                      ),
                      body: BlocListener<AssignedOrderBloc, AssignedOrderState>(
                          listener: (context, state) {
                          },
                          child: BlocBuilder<AssignedOrderBloc, AssignedOrderState>(
                              builder: (context, state) {
                                if (state is AssignedOrderInitialState) {
                                  return loadingNotice();
                                }

                                if (state is AssignedOrderLoadingState) {
                                  return loadingNotice();
                                }

                                if (state is AssignedOrderErrorState) {
                                  return errorNoticeWithReload(
                                      state.message,
                                      bloc,
                                      AssignedOrderEvent(
                                          status: AssignedOrderEventStatus.FETCH_ALL)
                                  );
                                }

                                if (state is AssignedOrdersLoadedState) {
                                  return AssignedListWidget(
                                    orderList: state.assignedOrders.results
                                  );
                                }

                                return loadingNotice();
                              }
                          )
                      )
                    );
                }
              );
            }
        )
    );
  }
}
