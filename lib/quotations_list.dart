import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models.dart';
import 'utils.dart';


Future<Quotations> _fetchQuotations(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // make call
  final String token = newToken.token;
  final url = await getUrl('/quotation/quotation/');
  final response = await client.get(
    url,
    headers: getHeaders(token)
  );
  
  if (response.statusCode == 200) {
    refreshTokenBackground(client);
    Quotations results = Quotations.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('Failed to load quotations: ${response.statusCode}, ${response.body}');
}


class QuotationsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QuotationsState();
  }
}

class _QuotationsState extends State<QuotationsListPage> {
  List<Quotation> _quotations = [];
  bool _fetchDone = false;
  Widget _drawer;
  String _submodel;

  _getSubmodel() async {
    String submodel = await getUserSubmodel();

    setState(() {
      _submodel = submodel;
    });
  }

  _getDrawerForUser() async {
    Widget drawer = await getDrawerForUser(context);

    setState(() {
      _drawer = drawer;
    });
  }

  _doFetchQuotations() async {
    Quotations result = await _fetchQuotations(http.Client());

    setState(() {
      _fetchDone = true;
      _quotations = result.results;
    });
  }

  Widget _buildList() {
    if (_quotations.length == 0 && _fetchDone) {
      return RefreshIndicator(
        child: Center(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Text('No quotations.')
                      ],
                    )
                )
              ]
          )
        ),
        onRefresh: () => _doFetchQuotations()
      );
    }

    if (_quotations.length == 0 && !_fetchDone) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      child: ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: _quotations.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
                children: [
                  ListTile(
                      title: createQuotationListHeader(_quotations[index]),
                      subtitle: createQuotationListSubtitle(_quotations[index]),
                      onTap: () {
                      } // onTab
                  ),
                  SizedBox(height: 10),
                ]
            );
          } // itemBuilder
      ),
      onRefresh: () => _doFetchQuotations(),
    );
  }

  @override
  void initState() {
    super.initState();
    _doFetchQuotations();
    _getDrawerForUser();
    _getSubmodel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quotations'),
      ),
      body: Container(
        child: _buildList(),
      ),
      drawer: _drawer,
    );
  }
}
