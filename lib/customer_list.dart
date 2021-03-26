import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'utils.dart';
import 'order_detail.dart';
import 'customer_edit_form.dart';
import 'customer_detail.dart';


Future<bool> deleteCustomer(http.Client client, Customer customer) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  final url = await getUrl('/customer/customer/${customer.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<Customers> fetchCustomers(http.Client client, { query=''}) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // make call
  final String token = newToken.token;
  String url = await getUrl('/customer/customer/?orders=&page=1');
  if (query != '') {
    url += '&q=$query';
  }

  final response = await client.get(
    url,
    headers: getHeaders(token)
  );

  if (response.statusCode == 401) {
    Map<String, dynamic> reponseBody = json.decode(response.body);

    if (reponseBody['code'] == 'token_not_valid') {
      throw TokenExpiredException('token expired');
    }
  }

  if (response.statusCode == 200) {
    Customers results = Customers.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('Failed to load customers: ${response.statusCode}, ${response.body}');
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

  _doFetchCustomers() async {
    Customers result = await fetchCustomers(http.Client());

    setState(() {
      _fetchDone = true;
      _customers = result.results;
    });
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

    // fetch and refresh screen
    if (result) {
      createSnackBar(context, 'Customer deleted');

      _doFetchCustomers();
    } else {
      displayDialog(context, 'Error', 'Error deleting customer');
    }
  }

  _showDeleteDialog(Customer customer, BuildContext context) {
    showDeleteDialog(
        'Delete customer', 'Do you want to delete this customer?',
        context, () => _doDelete(customer));
  }

  _doSearch(String query) async {
    Customers result = await fetchCustomers(http.Client(), query: query);

    setState(() {
      _fetchDone = true;
      _customers = result.results;
    });
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
            'Search',
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
              'Edit', () => _navEditCustomer(customer.id)
          ),
          SizedBox(width: 10),
          createBlueElevatedButton(
              'Delete', () => _showDeleteDialog(customer, context),
              primaryColor: Colors.red),
        ],
      );
    } else {
      // sales user
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'Edit', () => _navEditCustomer(customer.id)
          )
        ],
      );
    }

    return row;
  }

  Widget _buildList() {
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
                        Text('No customers.')
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
        title: Text(_isPlanning ? 'All customers' : 'Your customers'),
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
