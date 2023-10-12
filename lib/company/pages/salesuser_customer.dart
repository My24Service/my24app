import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/blocs/salesuser_customer_bloc.dart';
import 'package:my24app/company/blocs/salesuser_customer_states.dart';
import 'package:my24app/company/widgets/salesuser_customer/list.dart';
import 'package:my24app/company/widgets/salesuser_customer/error.dart';
import 'package:my24app/core/widgets/drawers.dart';

class SalesUserCustomerPage extends StatelessWidget with i18nMixin {
  final String basePath = "company.SalesUserCustomers";
  final SalesUserCustomerBloc bloc;
  final Utils utils = Utils();

  Future<DefaultPageData> getPageData(BuildContext context) async {
    String? submodel = await this.utils.getUserSubmodel();
    String? memberPicture = await this.utils.getMemberPicture();

    DefaultPageData result = DefaultPageData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        memberPicture: memberPicture,
    );

    return result;
  }

  SalesUserCustomerPage({
    Key? key,
    required this.bloc,
  }) : super(key: key);

  SalesUserCustomerBloc _initialBlocCall() {
    bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
    bloc.add(SalesUserCustomerEvent(
        status: SalesUserCustomerEventStatus.FETCH_ALL,
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DefaultPageData>(
        future: getPageData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            DefaultPageData? pageData = snapshot.data;

            return BlocProvider<SalesUserCustomerBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<SalesUserCustomerBloc, SalesUserCustomerState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: pageData!.drawer,
                          body: _getBody(context, state, pageData),
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    $trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": "${snapshot.error}"}
                    )
                )
            );
          } else {
            return Scaffold(
                body: loadingNotice()
            );
          }
        }
    );

  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

    if (state is SalesUserCustomerInsertedState) {
      createSnackBar(context, $trans('snackbar_added'));

      bloc.add(SalesUserCustomerEvent(
          status: SalesUserCustomerEventStatus.FETCH_ALL,
      ));
    }

    if (state is SalesUserCustomerDeletedState) {
      createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(SalesUserCustomerEvent(
          status: SalesUserCustomerEventStatus.FETCH_ALL,
      ));
    }
  }

  Widget _getBody(context, state, DefaultPageData? pageData) {
    if (state is SalesUserCustomerInitialState) {
      return loadingNotice();
    }

    if (state is SalesUserCustomerLoadingState) {
      return loadingNotice();
    }

    if (state is SalesUserCustomerErrorState) {
      return SalesUserCustomerListErrorWidget(
          error: state.message,
          memberPicture: pageData!.memberPicture
      );
    }

    if (state is SalesUserCustomersLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.salesUserCustomers!.count,
          next: state.salesUserCustomers!.next,
          previous: state.salesUserCustomers!.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return SalesUserCustomerListWidget(
        salesUserCustomers: state.salesUserCustomers,
        paginationInfo: paginationInfo,
        memberPicture: pageData!.memberPicture,
        searchQuery: state.query,
        formData: state.formData,
      );
    }

    return loadingNotice();
  }
}
