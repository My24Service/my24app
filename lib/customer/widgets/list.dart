import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/core/i18n_mixin.dart';
import '../pages/detail.dart';
import 'mixins.dart';


class CustomerListWidget extends BaseSliverListStatelessWidget with CustomerMixin, i18nMixin {
  final String basePath = "customers";
  final Customers? customers;
  final PaginationInfo paginationInfo;
  final String? memberPicture;
  final String? submodel;
  final String? searchQuery;

  CustomerListWidget({
    Key? key,
    required this.customers,
    required this.paginationInfo,
    required this.memberPicture,
    required this.submodel,
    required this.searchQuery
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture
  ) {
    searchController.text = searchQuery?? '';
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_REFRESH));
    bloc.add(CustomerEvent(status: CustomerEventStatus.FETCH_ALL));
  }

  @override
  String getAppBarTitle(BuildContext context) {
    if (_isPlanning()) {
      return $trans('list.app_bar_title_planning');
    }

    return $trans('list.app_bar_title_no_planning');
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return "";
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              Customer customer = customers!.results![index];

              return Column(
                  children: [
                    ListTile(
                        title: _createCustomerListHeader(customer),
                        subtitle: _createCustomerListSubtitle(customer),
                        onTap: () async {
                          _navDetailCustomer(context, customer.id);
                        } // onTab
                    ),
                    SizedBox(height: 10),
                    _getButtonRow(context, customer),
                    SizedBox(height: 10)
                  ]
              );
            },
            childCount: customers!.results!.length,
        )
    );
  }

  // private methods
  bool _isPlanning() {
    return submodel == 'planning_user';
  }

  _navEditCustomer(BuildContext context, int? customerPk) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
        status: CustomerEventStatus.FETCH_DETAIL,
        pk: customerPk
    ));
  }

  _navDetailCustomer(BuildContext context, int? customerPk) {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => CustomerDetailPage(
              pk: customerPk,
              bloc: CustomerBloc(),
              isEngineer: false,
            )
        )
    );
  }

  _doDelete(BuildContext context, Customer customer) async {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
        status: CustomerEventStatus.DELETE,
        pk: customer.id
    ));
  }

  _showDeleteDialog(BuildContext context, Customer quotation) {
    showDeleteDialogWrapper(
        $trans('list.delete_dialog_title'),
        $trans('list.delete_dialog_content'),
        () => _doDelete(context, quotation),
        context
    );
  }

  Row _getButtonRow(BuildContext context, Customer customer) {
    Row row;

    Widget editButton = createElevatedButtonColored(
        $trans('action_edit', pathOverride: 'generic'),
        () => _navEditCustomer(context, customer.id)
    );

    Widget deleteButton = createElevatedButtonColored(
        $trans('action_delete', pathOverride: 'generic'),
        () => _showDeleteDialog(context, customer),
        foregroundColor: Colors.red,
        backgroundColor: Colors.white,
    );

    if (_isPlanning()) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          editButton,
          SizedBox(width: 10),
          deleteButton
        ],
      );
    } else {
      // sales user
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          editButton
        ],
      );
    }

    return row;
  }

  Widget _createCustomerListHeader(Customer customer) {
    return Table(
      children: [
        TableRow(
            children: [
              Text($trans('info_customer_id'), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${customer.customerId}')
            ]
        ),
        TableRow(
            children: [
              Text($trans('info_name'), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${customer.name}')
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 10),
              Text(''),
            ]
        )
      ],
    );
  }

  Widget _createCustomerListSubtitle(Customer customer) {
    return Table(
      children: [
        TableRow(
            children: [
              Text($trans('info_address'), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${customer.address}'),
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 3),
              SizedBox(height: 3),
            ]
        ),
        TableRow(
            children: [
              Text($trans('info_postal_city'), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${customer.countryCode}-${customer.postal} ${customer.city}'),
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 3),
              SizedBox(height: 3),
            ]
        ),
        TableRow(
            children: [
              Text($trans('info_tel'), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${customer.tel}'),
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 3),
              SizedBox(height: 3),
            ]
        ),
        TableRow(
            children: [
              Text($trans('info_mobile'), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${customer.mobile}')
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 3),
              SizedBox(height: 3),
            ]
        ),
        TableRow(
            children: [
              Text($trans('info_email'), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${customer.email}')
            ]
        )
      ],
    );
  }
}
