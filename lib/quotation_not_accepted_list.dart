import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'utils.dart';
import 'order_detail.dart';
import 'order_document.dart';
import 'order_edit_form.dart';


Future<bool> _deleteQuotation(http.Client client, Quotation quotation) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  final url = await getUrl('/quotation/quotation/${quotation.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<Quotations> _fetchNotAcceptedQuotations(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // make call
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

  throw Exception('Failed to load quotations: ${response.statusCode}, ${response.body}');
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

  _storeQuotationPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('order_pk', pk);
  }

  void _doFetch() async {
    Quotations result = await _fetchNotAcceptedQuotations(http.Client());

    setState(() {
      _fetchDone = true;
      _quotations = result.results;
    });
  }

  _showDeleteDialog(Quotation quotation) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context, false);
      },
    );
    Widget deleteButton = TextButton(
      child: Text("Delete"),
      onPressed:  () async {
        Navigator.pop(context, true);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete order"),
      content: Text("Do you want to delete this quotation?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    ).then((dialogResult) async {
      if (dialogResult == null) return;

      if (dialogResult) {
        setState(() {
          _saving = true;
        });

        bool result = await _deleteQuotation(http.Client(), quotation);

        // fetch and refresh screen
        if (result) {
          _doFetch();
        } else {
          displayDialog(context, 'Error', 'Error deleting quotation');
        }
      }
    });
  }
  
  _navEditQuotation(int quotationPk) {
    _storeQuotationPk(quotationPk);

    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => OrderEditFormPage())
    );
  }

  _navImages(int quotationPk) {
    _storeQuotationPk(quotationPk);

    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => OrderDocumentPage())
    );
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
        onRefresh: _getData
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // createBlueElevatedButton(
                        //     'Edit',
                        //     () => _navEditQuotation(_quotations[index].id)
                        // ),
                        // SizedBox(width: 10),
                        createBlueElevatedButton(
                            'Images',
                            () => _navImages(_quotations[index].id)),
                        SizedBox(width: 10),
                        createBlueElevatedButton(
                            'Delete',
                            () => _showDeleteDialog(_quotations[index]),
                            primaryColor: Colors.red),
                      ],
                    ),
                    SizedBox(height: 10)
                  ]
              );
            } // itemBuilder
        ),
        onRefresh: _getData,
    );
  }

  Future<void> _getData() async {
    setState(() {
      _doFetch();
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
    _doFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Not yet accepted quotations'),
      ),
      body: Container(
        child: _buildList(),
      ),
      drawer: createEngineerDrawer(context),
    );
  }
}
