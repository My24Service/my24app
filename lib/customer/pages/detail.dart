import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/customer/blocs/customer_states.dart';
import 'package:my24app/customer/widgets/detail.dart';
import 'package:my24app/customer/widgets/error.dart';
import '../models/models.dart';

String? initialLoadMode;
int? loadId;

class CustomerDetailPage extends StatelessWidget{
  final i18n = My24i18n(basePath: "customers");
  final CustomerBloc bloc;
  final Utils utils = Utils();
  final bool isEngineer;
  final int? pk;
  final CoreWidgets widgets = CoreWidgets();

  Future<CustomerPageMetaData> getPageData() async {
    String? memberPicture = await this.utils.getMemberPicture();
    String? submodel = await this.utils.getUserSubmodel();

    CustomerPageMetaData result = CustomerPageMetaData(
        memberPicture: memberPicture,
        submodel: submodel,
        drawer: null
    );

    return result;
  }

  CustomerDetailPage({
    Key? key,
    required this.bloc,
    required this.isEngineer,
    required this.pk,
    String? initialMode,
  }) : super(key: key) {
    if (initialMode != null) {
      initialLoadMode = initialMode;
      loadId = pk;
    }
  }

  CustomerBloc _initialBlocCall() {
    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
        status: CustomerEventStatus.FETCH_DETAIL_VIEW,
        pk: pk
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CustomerPageMetaData>(
        future: getPageData(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            CustomerPageMetaData? pageData = snapshot.data;

            return BlocProvider<CustomerBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<CustomerBloc, CustomerState>(
                    listener: (context, state) {
                    },
                    builder: (context, state) {
                      return Scaffold(
                          body: _getBody(context, state, pageData),
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    i18n.$trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": "${snapshot.error}"}
                    )
                )
            );
          } else {
            return Scaffold(
                body: widgets.loadingNotice()
            );
          }
        }
    );
  }

  Widget _getBody(context, state, CustomerPageMetaData? pageData) {
    if (state is CustomerInitialState) {
      return widgets.loadingNotice();
    }

    if (state is CustomerLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is CustomerErrorState) {
      return CustomerListErrorWidget(
          error: state.message,
          memberPicture: pageData!.memberPicture,
          widgetsIn: widgets,
          i18nIn: i18n,
      );
    }

    if (state is CustomerLoadedViewState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.customerHistoryOrders!.count,
          next: state.customerHistoryOrders!.next,
          previous: state.customerHistoryOrders!.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return CustomerDetailWidget(
        customer: state.customer,
        memberPicture: pageData!.memberPicture,
        customerHistoryOrders: state.customerHistoryOrders,
        isEngineer: isEngineer,
        paginationInfo: paginationInfo,
        searchQuery: state.query,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    return widgets.loadingNotice();
  }
}
