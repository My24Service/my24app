import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';
import 'quotation_images.dart';


Future<bool> _acceptQuotation(http.Client client, int quotationPk) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final String token = newToken.token;
  final url = await getUrl('/quotation/quotation/$quotationPk/set_quotation_accepted/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {};

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  // return
  if (response.statusCode == 200) {
    return true;
  }

  return null;
}

Future<bool> _deleteQuotation(http.Client client, Quotation quotation) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/quotation/quotation/${quotation.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<Quotations> _fetchNotAcceptedQuotations(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final String token = newToken.token;
  final url = await getUrl('/quotation/quotation/get_not_accepted/');
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


class QuotationNotAcceptedListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QuotationNotAcceptedState();
  }
}

class _QuotationNotAcceptedState extends State<QuotationNotAcceptedListPage> {
  List<Quotation> _quotations = [];
  bool _fetchDone = false;
  bool _saving = false;
  Widget _drawer;
  String _submodel;
  bool _isPlanning = false;
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
    await _setIsPlanning();
    await _doFetchQuotationsNotAccepted();
  }

  _setIsPlanning() async {
    _isPlanning = _submodel == 'planning_user';
  }

  _getSubmodel() async {
    _submodel = await getUserSubmodel();
  }

  _getDrawerForUser() async {
    _drawer = await getDrawerForUser(context);
  }

  _storeQuotationPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quotation_pk', pk);
  }

  _doFetchQuotationsNotAccepted() async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    try {
      Quotations result = await _fetchNotAcceptedQuotations(http.Client());
      _quotations = result.results;

      setState(() {
        _fetchDone = true;
      });
    } catch(e) {
      setState(() {
        _error = true;
      });
    }
  }

  _doDelete(Quotation quotation) async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    bool result = await _deleteQuotation(http.Client(), quotation);

    // fetch and rebuild widgets
    if (result) {
      createSnackBar(context, 'quotations.snackbar_deleted'.tr());
      setState(() {
        _inAsyncCall = false;
      });
      _doFetchQuotationsNotAccepted();
    } else {
      setState(() {
        _inAsyncCall = false;
      });
      displayDialog(context,
        'generic.error_dialog_title'.tr(),
        'quotations.error_deleting_dialog_content'.tr());
    }
  }

  _showDeleteDialog(Quotation quotation) {
    showDeleteDialog(
        'quotations.delete_dialog_title'.tr(),
        'quotations.delete_dialog_content'.tr(),
        context, () => _doDelete(quotation));
  }

  _navImages(int quotationPk) async {
    await _storeQuotationPk(quotationPk);

    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => QuotationImagePage())
    );
  }

  _doAcceptQuotation(int quotationPk) async {
    final bool result = await _acceptQuotation(http.Client(), quotationPk);

    if (result) {
      createSnackBar(context, 'quotations.snackbar_accepted'.tr());
      await _doFetchQuotationsNotAccepted();
    } else {
      displayDialog(context, 'generic.error_dialog_title'.tr(),
        'quotations.error_accepting'.tr());
    }
  }

  Row _getRowNotEngineer(int quotationPk) {
    Row row = Row();

    if (_isPlanning) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'quotations.button_accept'.tr(),
              () => _doAcceptQuotation(quotationPk)
          ),
        ],
      );
    }

    return row;
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
        ), onRefresh: () => _doFetchQuotationsNotAccepted(),
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
        onRefresh: () => _doFetchQuotationsNotAccepted()
      );
    }

    if (_quotations.length == 0 && !_fetchDone) {
      return Center(child: CircularProgressIndicator());
    }

    if (_submodel == 'engineer') {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        createBlueElevatedButton(
                            'quotations.button_images'.tr(),
                            () => _navImages(_quotations[index].id)
                        ),
                        SizedBox(width: 10),
                        createBlueElevatedButton(
                            'quotations.button_delete'.tr(),
                            () => _showDeleteDialog(_quotations[index]),
                            primaryColor: Colors.red
                        ),
                      ],
                    ),
                    SizedBox(height: 10)
                  ]
              );
            } // itemBuilder
        ),
        onRefresh: () => _doFetchQuotationsNotAccepted(),
      );
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
                  _getRowNotEngineer(_quotations[index].id),
                ]
            );
          } // itemBuilder
      ),
      onRefresh: () => _doFetchQuotationsNotAccepted(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('quotations.not_yet_accepted.app_bar_title'.tr()),
      ),
      body: Container(
        child: _buildList(),
      ),
      drawer: _drawer,
    );
  }
}
