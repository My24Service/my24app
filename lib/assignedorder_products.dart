import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

import 'models.dart';
import 'utils.dart';

BuildContext localContext;

Future<AssignedOrderProducts> fetchAssignedOrderProducts(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorderproduct/?assigned_order=$assignedorderPk');
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  if (response.statusCode == 200) {
    return AssignedOrderProducts.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load assigned order products');
}

class AssignedOrderProductPage extends StatefulWidget {
  @override
  _AssignedOrderProductPageState createState() => _AssignedOrderProductPageState();
}

class _AssignedOrderProductPageState extends State<AssignedOrderProductPage> {
  bool _isEditMode = false;
  AssignedOrderProducts _assignedOrderProducts;

  Widget _buildForm() {

  }

  @override
  Widget build(BuildContext context) {
    localContext = context;

    return Scaffold(
        appBar: AppBar(
          title: Text('Materials'),
        ),
        body: Center(
            child: FutureBuilder<AssignedOrderProducts>(
                future: fetchAssignedOrderProducts(http.Client()),
                // ignore: missing_return
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: Center(
                            child: Text("Loading...")
                        )
                    );
                  } else {
                    AssignedOrderProducts assignedOrderProducts = snapshot.data;
                    _assignedOrderProducts = assignedOrderProducts;

                    return Align(

                    );
                  } // else
                } // builder
            )
        )
    );
  }
}
