import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/member/blocs/fetch_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:my24app/member/models/models.dart';
import 'package:my24app/member/pages/detail.dart';


// ignore: must_be_immutable
class OrderListWidget extends StatelessWidget {
  final Orders orders;

  OrderListWidget({
    Key key,
    @required this.orders,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
  	return FutureBuilder<String>(
      future: utils.getOrderListTitleForUser(),
      builder: (ctx, snapshot) {
      	final String title = snapshot.data;

				return FutureBuilder<String>(
		      future: utils.getDrawerForUser(context),
		      builder: (ctx, snapshot) {
		      	final Widget drawer = snapshot.data;

				    return Scaffold(
				      appBar: AppBar(
				        title: Text(title),
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
				      drawer: drawer,
				    );
		      }
	      );
			}
		);
	}

  _storeOrderPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('order_pk', pk);
  }

  _navEditOrder(int orderPk) {
    _storeOrderPk(orderPk);

    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => OrderEditFormPage())
    );
  }

  _doDelete(Order order) async {
    bool result = await _deleteOrder(http.Client(), order);

    // fetch and rebuild widgets
    if (result) {
      createSnackBar(context, 'orders.snackbar_deleted'.tr());

      _doFetchOrders();
    } else {
      displayDialog(context,
        'generic.error_dialog_title'.tr(),
        'orders.error_deleting_dialog_content'.tr()
      );
    }
  }

  _showDeleteDialog(Order order, BuildContext context) {
    showDeleteDialog(
      'orders.delete_dialog_title'.tr(),
      'orders.delete_dialog_content'.tr(),
      context, () => _doDelete(order));
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

  Row _getListButtons(Order order) {
    Row row;

    if(_isPlanning) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'generic.action_edit'.tr(),
              () => _navEditOrder(order.id)
          ),
          SizedBox(width: 10),
          createBlueElevatedButton(
              'generic.action_delete'.tr(),
              () => _showDeleteDialog(order, context),
              primaryColor: Colors.red),
        ],
      );
    } else {
      row = Row();
    }

    return row;
  }

  _doSearch(String query) async {
    setState(() {
      _fetchDone = false;
      _error = false;
    });

    try {
      Orders result = await fetchOrders(http.Client(), query: query);

      setState(() {
        _fetchDone = true;
        _orders = result.results;
      });
    } catch(e) {
      setState(() {
        _fetchDone = true;
        _error = true;
      });
    }
  }

  _doFetchOrders() async {
    setState(() {
      _fetchDone = false;
      _error = false;
    });

    try {
      Orders result = await fetchOrders(http.Client());

      setState(() {
        _fetchDone = true;
        _orders = result.results;
      });
    } catch(e) {
      setState(() {
        _fetchDone = true;
        _error = true;
      });
    }
  }

  Widget _buildList() {
    return RefreshIndicator(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(8),
            itemCount: _orders.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  ListTile(
                      title: createOrderListHeader(_orders[index]),
                      subtitle: createOrderListSubtitle(_orders[index]),
                      onTap: () async {
                        // store order_pk
                        await _storeOrderPk(_orders[index].id);

                        // navigate to detail page
                        Navigator.push(context,
                            new MaterialPageRoute(builder: (context) => OrderDetailPage())
                        );
                      } // onTab
                  ),
                  SizedBox(height: 10),
                  _getListButtons(_orders[index]),
                  SizedBox(height: 10)
                ],
              );
            } // itemBuilder
        ),
        onRefresh: () => _doFetchOrders(),
    );
  }
}
