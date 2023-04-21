import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/company/blocs/salesuser_customer_bloc.dart';
import 'package:my24app/company/models/salesuser_customer/models.dart';
import 'package:my24app/company/models/salesuser_customer/form_data.dart';
import 'package:my24app/customer/models/api.dart';

class SalesUserCustomerListWidget extends BaseSliverListStatelessWidget with i18nMixin {
  final String basePath = "company.salesuser_customer";
  final SalesUserCustomers salesUserCustomers;
  final PaginationInfo paginationInfo;
  final String memberPicture;
  final String searchQuery;
  final SalesUserCustomerFormData formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CustomerApi customerApi = CustomerApi();
  final TextEditingController searchController = TextEditingController();

  SalesUserCustomerListWidget({
    Key key,
    @required this.salesUserCustomers,
    @required this.paginationInfo,
    @required this.memberPicture,
    @required this.searchQuery,
    @required this.formData
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture
  ) {
    searchController.text = searchQuery?? '';
  }

  Widget getBottomSection(BuildContext context) {
    return showPaginationSearchSection(
        context,
        paginationInfo,
        searchController,
        _nextPage,
        _previousPage,
        _doSearch,
    );
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

    bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
    bloc.add(SalesUserCustomerEvent(
      status: SalesUserCustomerEventStatus.FETCH_ALL,
    ));
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return $trans('app_bar_subtitle',
      namedArgs: {'count': "${salesUserCustomers.count}"}
    );
  }

  @override
  SliverList getPreSliverListContent(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return _getSelectCustomerSection(context);
          },
          childCount: 1,
        )
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              SalesUserCustomer salesUserCustomer = salesUserCustomers.results[index];

              String key = "${$trans('info_address', pathOverride: 'generic')} / "
                  "${$trans('info_city', pathOverride: 'generic')}";
              String value = "${salesUserCustomer.customerDetails.address} / "
                  "${salesUserCustomer.customerDetails.city}";

              return Column(
                children: [
                  ...buildItemListKeyValueList(
                      $trans('info_customer', pathOverride: 'generic'),
                      salesUserCustomer.customerDetails.name),
                  ...buildItemListKeyValueList(key, value),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      createDeleteButton(
                        $trans("button_delete"),
                        () { _showDeleteDialog(context, salesUserCustomer); }
                      ),
                    ],
                  ),
                  if (index < salesUserCustomers.results.length-1)
                    getMy24Divider(context)
                ],
              );
            },
            childCount: salesUserCustomers.results.length,
        )
    );
  }

  // private methods
  Widget _getSelectCustomerSection(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                      controller: formData.typeAheadController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: $trans('form_typeahead_label')
                      )
                  ),
                  suggestionsCallback: (pattern) async {
                    return await customerApi.customerTypeAhead(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.value),
                    );
                  },
                  transitionBuilder: (context, suggestionsBox, controller) {
                    return suggestionsBox;
                  },
                  onSuggestionSelected: (suggestion) {
                    formData.selectedCustomer = suggestion;
                    formData.typeAheadController.text = suggestion.name;
                    _updateFormData(context);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return $trans('form_validator_customer');
                    }

                    return null;
                  },
                  onSaved: (value) => {},
                ),
                SizedBox(height: 10),
                _getCustomerDetailSection(context)
              ]
            )
        )
      ),
    );
  }

  Widget _getCustomerDetailSection(BuildContext context) {
    if (formData.selectedCustomer == null) {
      return SizedBox(height: 1);
    }

    return Column(
      children: [
        buildCustomerInfoCard(context, formData.selectedCustomer),
        SizedBox(height: 10),
        createDefaultElevatedButton(
            $trans('form_button_submit'),
            () => { _submitForm(context) }
        ),
        getMy24Divider(context),
      ],
    );
  }

  _doDelete(BuildContext context, SalesUserCustomer salesUserCustomer) {
    final bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

    bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
    bloc.add(SalesUserCustomerEvent(
        status: SalesUserCustomerEventStatus.DELETE,
        pk: salesUserCustomer.id,
    ));
  }

  _showDeleteDialog(BuildContext context, SalesUserCustomer salesUserCustomer) {
    showDeleteDialogWrapper(
        $trans('delete_dialog_title'),
        $trans('delete_dialog_content'),
      () => _doDelete(context, salesUserCustomer),
      context
    );
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<SalesUserCustomerBloc>(context);
    bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
    bloc.add(SalesUserCustomerEvent(
        status: SalesUserCustomerEventStatus.UPDATE_FORM_DATA,
        formData: formData
    ));
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      if (!formData.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<SalesUserCustomerBloc>(context);
      SalesUserCustomer newSalesUserCustomer = formData.toModel();
      bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
      bloc.add(SalesUserCustomerEvent(
        status: SalesUserCustomerEventStatus.INSERT,
        salesUserCustomer: newSalesUserCustomer,
      ));
    }
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

    bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
    bloc.add(SalesUserCustomerEvent(
      status: SalesUserCustomerEventStatus.FETCH_ALL,
      page: paginationInfo.currentPage + 1,
      query: searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

    bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
    bloc.add(SalesUserCustomerEvent(
      status: SalesUserCustomerEventStatus.FETCH_ALL,
      page: paginationInfo.currentPage - 1,
      query: searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

    bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
    bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_SEARCH));
    bloc.add(SalesUserCustomerEvent(
        status: SalesUserCustomerEventStatus.FETCH_ALL,
        query: searchController.text,
        page: 1
    ));
  }
}
