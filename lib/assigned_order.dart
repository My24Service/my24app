import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'models.dart';
import 'utils.dart';


Future<AssignedOrder> fetchAssignedOrder(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final token = await getAccessToken();
  final url = await getUrl('/mobile/assignedorder/$assignedorderPk/detail_device/?json');
  final response = await client.get(
      url,
      headers: {'Authorization': 'Bearer $token'}
  );

  if (response.statusCode == 200) {
    return AssignedOrder.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load assigned order');
}

class AssignedOrderPage extends StatelessWidget {
  Widget _buildInfoCard(assignedOrder) => SizedBox(
    height: 210,
    width: 1000,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(assignedOrder.order.orderName, style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${assignedOrder.order.orderCountryCode}-${assignedOrder.order.orderPostal}\n${assignedOrder.order.orderCity}'),
            leading: Icon(
              Icons.restaurant_menu,
              color: Colors.blue[500],
            ),
          ),
          Divider(),
          ListTile(
            title: Text(assignedOrder.order.orderTel,
                style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.contact_phone,
              color: Colors.blue[500],
            ),
          ),
          ListTile(
            title: Text(assignedOrder.order.orderEmail),
            leading: Icon(
              Icons.contact_mail,
              color: Colors.blue[500],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildOrderDetails(assignedOrder) => SizedBox(
      height: 210,
      width: 1000,
      child: Expanded(
          flex: 2,
          child: Text('Order id')
      )
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Order details'),
        ),
        body: Center(
            child: FutureBuilder<AssignedOrder>(
                future: fetchAssignedOrder(http.Client()),
                // ignore: missing_return
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: Center(
                            child: Text("Loading...")
                        )
                    );
                  } else {
                    AssignedOrder assignedOrder = snapshot.data;
                    return Align(
                      alignment: Alignment.topRight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                              child: _buildInfoCard(assignedOrder)
                          ),
                          Divider(),
                          Flexible(
                            child: _buildOrderDetails(assignedOrder),
                          )
                        ] // children
                      )
                    );
                  } // else
                } // builder
            )
        )
    );
  }
}
