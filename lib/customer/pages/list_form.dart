import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/customer/blocs/customer_states.dart';
import 'package:my24app/customer/widgets/form.dart';
import 'package:my24app/customer/widgets/list.dart';
import 'package:my24app/customer/widgets/empty.dart';
import 'package:my24app/customer/widgets/error.dart';
import '../models/models.dart';

String initialLoadMode;
int loadId;

class CustomerPage extends StatelessWidget with i18nMixin {
  final String basePath = "customers";
  final CustomerBloc bloc;
  final Utils utils = Utils();

  Future<CustomerPageMetaData> getPageData() async {
    String memberPicture = await this.utils.getMemberPicture();
    String submodel = await this.utils.getUserSubmodel();

    CustomerPageMetaData result = CustomerPageMetaData(
        memberPicture: memberPicture,
        submodel: submodel
    );

    return result;
  }

  CustomerPage({
    Key key,
    @required this.bloc,
    String initialMode,
    int pk
  }) : super(key: key) {
    if (initialMode != null) {
      initialLoadMode = initialMode;
      loadId = pk;
    }
  }

  CustomerBloc _initialBlocCall() {
    if (initialLoadMode == null) {
      bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
      bloc.add(CustomerEvent(
          status: CustomerEventStatus.FETCH_ALL,
      ));
    } else if (initialLoadMode == 'form') {
      bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
      bloc.add(CustomerEvent(
          status: CustomerEventStatus.FETCH_DETAIL,
          pk: loadId
      ));
    } else if (initialLoadMode == 'new') {
      bloc.add(CustomerEvent(
          status: CustomerEventStatus.NEW,
      ));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CustomerPageMetaData>(
        future: getPageData(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            CustomerPageMetaData pageData = snapshot.data;

            return BlocProvider<CustomerBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<CustomerBloc, CustomerState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          body: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                              child: _getBody(context, state, pageData),
                          )
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    $trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": snapshot.error}))
            );
          } else {
            return loadingNotice();
          }
        }
    );
  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    if (state is CustomerInsertedState) {
      createSnackBar(context, $trans('snackbar_added'));

      bloc.add(CustomerEvent(
          status: CustomerEventStatus.FETCH_ALL,
      ));
    }

    if (state is CustomerUpdatedState) {
      createSnackBar(context, $trans('snackbar_updated'));

      bloc.add(CustomerEvent(
          status: CustomerEventStatus.FETCH_ALL,
      ));
    }

    if (state is CustomerDeletedState) {
      createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(CustomerEvent(
          status: CustomerEventStatus.FETCH_ALL,
      ));
    }
  }

  Widget _getBody(context, state, CustomerPageMetaData pageData) {
    if (state is CustomerInitialState) {
      return loadingNotice();
    }

    if (state is CustomerLoadingState) {
      return loadingNotice();
    }

    if (state is CustomerErrorState) {
      return CustomerListErrorWidget(
          error: state.message,
          memberPicture: pageData.memberPicture
      );
    }

    if (state is CustomersLoadedState) {
      if (state.customers.results.length == 0) {
        return CustomerListEmptyWidget(memberPicture: pageData.memberPicture);
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.customers.count,
          next: state.customers.next,
          previous: state.customers.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return CustomerListWidget(
        customers: state.customers,
        paginationInfo: paginationInfo,
        memberPicture: pageData.memberPicture,
        searchQuery: state.query,
        submodel: pageData.submodel,
      );
    }

    if (state is CustomerLoadedState) {
      return CustomerFormWidget(
        formData: state.formData,
        memberPicture: pageData.memberPicture
      );
    }

    if (state is CustomerNewState) {
      return CustomerFormWidget(
          formData: state.formData,
          memberPicture: pageData.memberPicture
      );
    }

    return loadingNotice();
  }
}
