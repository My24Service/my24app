import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'utils.dart';


Future<AssignedOrders> fetchAssignedOrders(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int userId = prefs.getInt('user_id');
  final token = await getAccessToken();
  final url = await getUrl('/mobile/assignedorder/list_device/?user_pk=$userId&json');
  final response = await client.get(
    url,
      headers: {'Authorization': 'Bearer $token'}
  );

  if (response.statusCode == 200) {
    var results = AssignedOrders.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('Failed to load assigned orders');
}

class AssignedOrdersListWidget extends StatelessWidget {
  final EngineerUser engineer;

  AssignedOrdersListWidget(this.engineer);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders for ${engineer.firstName}')),
      body: Center(child: Text('My Page!')),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
