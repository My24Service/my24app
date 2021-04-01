import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';
import 'customer_edit_form.dart';
import 'customer_detail.dart';


Future<bool> deleteCustomer(http.Client client, Customer customer) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/customer/customer/${customer.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<Customers> fetchCustomers(http.Client client, { query=''}) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final String token = newToken.token;
  String url = await getUrl('/customer/customer/?orders=&page=1');
  if (query != '') {
    url += '&q=$query';
  }

  final response = await client.get(
    url,
    headers: getHeaders(token)
  );

  if (response.statusCode == 200) {
    Customers results = Customers.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('customers.list.exception_fetch'.tr());
}


class CustomerListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderState();
  }
}

class _OrderState extends State<CustomerListPage> {
  List<Customer> _customers = [];
  bool _fetchDone = false;
  Widget _drawer;
  String _title;
  bool _isPlanning = false;
  var _searchController = TextEditingController();
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _setIsPlanning();
    await _doFetchCustomers();
    await _getDrawerForUser();
    await  _getTitle();
  }

  _setIsPlanning() async {
    final String submodel = await getUserSubmodel();

    setState(() {
      _isPlanning = submodel == 'planning_user';
    });
  }

  _storeCustomerPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('customer_pk', pk);
  }

  _getDrawerForUser() async {
    Widget drawer = await getDrawerForUser(context);

    setState(() {
      _drawer = drawer;
    });
  }

  _getTitle() async {
    String title = await getOrderListTitleForUser();

    setState(() {
      _title = title;
    });
  }

  _navEditCustomer(int orderPk) {
    _storeCustomerPk(orderPk);

    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => CustomerEditFormPage())
    );
  }

  _doDelete(Customer customer) async {
    bool result = await deleteCustomer(http.Client(), customer);

    // fetch and rebuild widgets
    if (result) {
      createSnackBar(context, 'customers.list.snackbar_deleted'.tr());

      _doFetchCustomers();
    } else {
      displayDialog(context,
        'generic.action_delete'.tr(),
        'customers.list.error_deleting_dialog_content'.tr()
      );
    }
  }

  _showDeleteDialog(Customer customer, BuildContext context) {
    showDeleteDialog(
      'customers.list.delete_dialog_title'.tr(),
      'customers.list.delete_dialog_content'.tr(),
      context, () => _doDelete(customer));
  }

  Row _showSearchRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 220, child:
          TextField(
            controller: _searchController,
          ),
        ),
        createBlueElevatedButton(
          'generic.action_search'.tr(),
          () => _doSearch(_searchController.text)
        ),
      ],
    );
  }

  Row _getListButtons(Customer customer) {
    Row row;

    if(_isPlanning) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
            'generic.action_edit'.tr(),
            () => _navEditCustomer(customer.id)
          ),
          SizedBox(width: 10),
          createBlueElevatedButton(
            'generic.action_delete'.tr(),
            () => _showDeleteDialog(customer, context),
            primaryColor: Colors.red),
        ],
      );
    } else {
      // sales user
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
            'generic.action_edit'.tr(),
            () => _navEditCustomer(customer.id)
          )
        ],
      );
    }

    return row;
  }

  _doSearch(String query) async {
    setState(() {
      _fetchDone = false;
      _error = false;
    });

    try {
      Customers result = await fetchCustomers(http.Client(), query: query);

      setState(() {
        _fetchDone = true;
        _customers = result.results;
      });
    } catch(e) {
      setState(() {
        _fetchDone = true;
        _error = true;
      });
    }
  }

  _doFetchCustomers() async {
    setState(() {
      _fetchDone = false;
      _error = false;
    });

    try {
      Customers result = await fetchCustomers(http.Client());

      setState(() {
        _fetchDone = true;
        _customers = result.results;
      });
    } catch(e) {
      setState(() {
        _fetchDone = true;
        _error = true;
      });
    }
  }

  Widget _buildList() {
    if (_error) {
      return RefreshIndicator(
        child: Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                Text('customers.list.exception_fetch'.tr())
              ],
            )
        ), onRefresh: () => _doFetchCustomers(),
      );
    }

    if (_customers.length == 0 && _fetchDone) {
      return RefreshIndicator(
        child: Center(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Text('customers.list.notice_no_customers'.tr())
                      ],
                    )
                )
              ]
          )
        ),
        onRefresh: () => _doFetchCustomers()
      );
    }

    if (_customers.length == 0 && !_fetchDone) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(8),
            itemCount: _customers.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  ListTile(
                      title: createCustomerListHeader(_customers[index]),
                      subtitle: createCustomerListSubtitle(_customers[index]),
                      onTap: () async {
                        // store order_pk
                        await _storeCustomerPk(_customers[index].id);

                        // navigate to detail page
                        Navigator.push(context,
                            new MaterialPageRoute(builder: (context) => CustomerDetailPage())
                        );
                      } // onTab
                  ),
                  SizedBox(height: 10),
                  _getListButtons(_customers[index]),
                  SizedBox(height: 10)
                ],
              );
            } // itemBuilder
        ),
        onRefresh: () => _doFetchCustomers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isPlanning ?
          'customers.list.app_bar_title_planning'.tr() :
          'customers.list.app_bar_title_no_planning'.tr()
        ),
      ),
      body: Container(
        child: Column(
          children: [
            _showSearchRow(),
            SizedBox(height: 20),
            Expanded(child: _buildList()),
          ]
        )
      ),
      drawer: _drawer,
    );
  }
}
