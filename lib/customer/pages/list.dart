import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/customer/blocs/customer_states.dart';
import 'package:my24app/customer/widgets/list.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/customer/models/models.dart';

class CustomerListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _scrollThreshold = 200.0;
  ScrollController controller;
  List<Customer> customerList = [];
  bool hasNextPage = false;
  int page = 1;
  bool inPaging = false;
  String searchQuery = '';
  bool rebuild = true;
  bool inSearch = false;
  bool refresh = false;
  bool firstTime = true;

  _scrollListener() {
    // end reached
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    final CustomerBloc bloc = CustomerBloc();

    if (hasNextPage && maxScroll - currentScroll <= _scrollThreshold) {
      bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
      bloc.add(CustomerEvent(
        status: CustomerEventStatus.FETCH_ALL,
        page: ++page,
        query: searchQuery,
      ));
      inPaging = true;
    }
  }

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  CustomerBloc _initialCall() {
    CustomerBloc bloc = CustomerBloc();

    if (firstTime) {
      bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
      bloc.add(CustomerEvent(status: CustomerEventStatus.FETCH_ALL));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
        create: (context) => _initialCall(),
        child: BlocConsumer<CustomerBloc, CustomerState>(
          listener: (context, state) {
            _handleListeners(context, state);
          },
          builder: (context, state) {
            return FutureBuilder<String>(
                future: utils.getUserSubmodel(),
                builder: (ctx, snapshot) {
                  if (snapshot.data == null) {
                    return loadingNotice();
                  }

                  final String submodel = snapshot.data;

                  return FutureBuilder<Widget>(
                      future: getDrawerForUser(context),
                      builder: (ctx, snapshot) {
                        final Widget drawer = snapshot.data;
                        final title = submodel == 'planning_user'
                            ? 'customers.list.app_bar_title_planning'.tr()
                            : 'customers.list.app_bar_title_no_planning'.tr();

                        return Scaffold(
                            appBar: AppBar(
                              title: Text(title),
                            ),
                            drawer: drawer,
                            body: _getBody(context, state, submodel)
                        );
                      }
                  );
                }
            );
          }
      )
    );
  }

  void _handleListeners(context, state) {
    final CustomerBloc bloc = BlocProvider.of<CustomerBloc>(context);

    if (state is CustomerDeletedState) {
      if (state.result == true) {
        createSnackBar(
            context, 'quotations.snackbar_deleted'.tr());

        bloc.add(CustomerEvent(status: CustomerEventStatus.DO_REFRESH));
        bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
        bloc.add(CustomerEvent(status: CustomerEventStatus.FETCH_ALL));
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.error_deleting_dialog_content'.tr()
        );
      }
    }
  }

  Widget _getBody(context, state, submodel) {
    final CustomerBloc bloc = BlocProvider.of<CustomerBloc>(context);

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
          CustomerEvent(status: CustomerEventStatus.FETCH_ALL)
      );
    }

    if (state is CustomerRefreshState) {
      // reset vars on refresh
      customerList = [];
      page = 1;
      inPaging = false;
      inSearch = false;
      refresh = true;
    }

    if (state is CustomerSearchState) {
      // reset vars on search
      customerList = [];
      inSearch = true;
      page = 1;
      inPaging = false;
      refresh = true;
    }

    if (state is CustomersLoadedState) {
      if (refresh || (inSearch && !inPaging)) {
        // set search string and orderList
        searchQuery = state.query;
        customerList = state.customers.results;
      } else {
        // only merge on widget build, paging and search
        if (rebuild || inPaging || searchQuery != null) {
          hasNextPage = state.customers.next != null;
          customerList = new List.from(customerList)..addAll(state.customers.results);
          rebuild = false;
        }
      }

      return CustomerListWidget(
        customerList: customerList,
        controller: controller,
        searchQuery: searchQuery,
        submodel: submodel,
      );
    }

    return loadingNotice();
  }
}
