import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/customer/pages/detail.dart';
import 'package:my24app/customer/pages/form.dart';


// ignore: must_be_immutable
class CustomerListWidget extends StatelessWidget {
  final ScrollController controller;
  final List<Customer> customerList;
  final String searchQuery;
  final String submodel;
  BuildContext _context;

  var _searchController = TextEditingController();

  bool _inAsyncCall = false;

  CustomerListWidget({
    Key key,
    @required this.controller,
    @required this.customerList,
    @required this.searchQuery,
    @required this.submodel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _context = context;
    _searchController.text = searchQuery ?? '';

    return ModalProgressHUD(
        child: Column(
            children: [
              _showSearchRow(context),
              SizedBox(height: 20),
              Expanded(child: _buildList(context)),
            ]
        ), inAsyncCall: _inAsyncCall
    );
  }

  _navEditCustomer(BuildContext context, int customerPk) {
    final page = CustomerFormPage(customerPk: customerPk);

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => page)
    );
  }

  _doDelete(BuildContext context, Customer quotation) async {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
        status: CustomerEventStatus.DELETE, value: quotation.id));
  }

  _showDeleteDialog(BuildContext context, Customer quotation) {
    showDeleteDialogWrapper(
        'customers.list.delete_dialog_title'.tr(),
        'customers.list.delete_dialog_content'.tr(),
        () => _doDelete(context, quotation),
        _context
    );
  }

  Row _showSearchRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 220, child:
        TextField(
          controller: _searchController,
        ),
        ),
        createDefaultElevatedButton(
            'generic.action_search'.tr(),
            () => _doSearch(context, _searchController.text)
        ),
      ],
    );
  }

  Row _getButtonRow(BuildContext context, Customer customer) {
    Row row;

    Widget editButton = createElevatedButtonColored(
        'generic.action_edit'.tr(),
        () => _navEditCustomer(context, customer.id)
    );

    Widget deleteButton = createElevatedButtonColored(
        'generic.action_delete'.tr(),
        () => _showDeleteDialog(context, customer),
        foregroundColor: Colors.red,
        backgroundColor: Colors.white,
    );

    if (submodel == 'planning_user') {
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

  _doSearch(BuildContext context, String query) async {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    controller.animateTo(
      controller.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 10),
    );

    await Future.delayed(Duration(milliseconds: 100));

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_SEARCH));
    bloc.add(CustomerEvent(status: CustomerEventStatus.FETCH_ALL, query: query));

  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_REFRESH));
    bloc.add(CustomerEvent(status: CustomerEventStatus.FETCH_ALL));
  }

  Widget _buildList(BuildContext context) {
    return RefreshIndicator(
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          controller: controller,
          key: PageStorageKey<String>('customerList'),
          shrinkWrap: true,
          padding: EdgeInsets.all(8),
          itemCount: customerList.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                ListTile(
                    title: createCustomerListHeader(customerList[index]),
                    subtitle: createCustomerListSubtitle(customerList[index]),
                    onTap: () async {
                      // navigate to detail page
                      final page = CustomerDetailPage(customerPk: customerList[index].id);

                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => page)
                      );
                    } // onTab
                ),
                SizedBox(height: 10),
                _getButtonRow(context, customerList[index]),
                SizedBox(height: 10)
              ],
            );
          } // itemBuilder
      ),
        onRefresh: () async {
          Future.delayed(
              Duration(milliseconds: 5),
                  () {
                doRefresh(context);
              });
        }
    );
  }

  Widget createCustomerListHeader(Customer customer) {
    return Table(
      children: [
        TableRow(
            children: [
              Text('orders.info_customer_id'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${customer.customerId}')
            ]
        ),
        TableRow(
            children: [
              Text('orders.info_name'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget createCustomerListSubtitle(Customer customer) {
    return Table(
      children: [
        TableRow(
            children: [
              Text('orders.info_address'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text('orders.info_postal_city'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text('orders.info_tel'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text('orders.info_mobile'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text('orders.info_order_email'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${customer.email}')
            ]
        )
      ],
    );
  }
}
