import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';


Future<Quotations> _fetchQuotations(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

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

  throw Exception('quotations.exception_fetch'.tr());
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
  bool _inAsyncCall = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    await _getDrawerForUser();
    await _getSubmodel();
    await _doFetchQuotations();
  }

  _getSubmodel() async {
    _submodel = await getUserSubmodel();
  }

  _getDrawerForUser() async {
    _drawer = await getDrawerForUser(context);
  }

  _doFetchQuotations() async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    try {
      Quotations result = await _fetchQuotations(http.Client());
      _quotations = result.results;

      setState(() {
        _inAsyncCall = false;
      });
    } catch(e) {
      setState(() {
        _inAsyncCall = false;
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
                Text('quotations.exception_fetch'.tr())
              ],
            )
        ), onRefresh: () => _doFetchQuotations(),
      );
    }

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
                        Text('quotations.notice_no_quotations'.tr())
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('quotations.app_bar_title'.tr()),
      ),
      body: Container(
        child: _buildList(),
      ),
      drawer: _drawer,
    );
  }
}
