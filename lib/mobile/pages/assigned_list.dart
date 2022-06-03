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
  bool firstTime = true;

  Future<String> _getFirstName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('first_name');
  }

  AssignedOrderBloc _initalBlocCall() {
    final bloc = AssignedOrderBloc();

    if (firstTime) {
      bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
      bloc.add(AssignedOrderEvent(
          status: AssignedOrderEventStatus.FETCH_ALL
      ));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssignedOrderBloc>(
        create: (context) => _initalBlocCall(),
        child: BlocConsumer<AssignedOrderBloc, AssignedOrderState>(
            listener: (context, state) {},
            builder: (context, state) {
              return FutureBuilder<Widget>(
                  future: getDrawerForUser(context),
                  builder: (ctx, snapshot) {
                    final Widget drawer = snapshot.data;

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
                              body: _getBody(context, state)
                          );
                        }
                    );
                  }
              );
            }
        )
    );
  }

  Widget _getBody(context, state) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    if (state is AssignedOrderErrorState) {
      return errorNoticeWithReload(
          state.message,
          bloc,
          AssignedOrderEvent(
              status: AssignedOrderEventStatus.FETCH_ALL)
      );
    }

    if (state is AssignedOrdersLoadedState) {
      print('AssignedOrdersLoadedState!');
      return AssignedListWidget(
          orderList: state.assignedOrders.results
      );
    }

    return loadingNotice();
  }
}
