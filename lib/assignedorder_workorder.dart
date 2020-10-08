import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'utils.dart';
import 'models.dart';


Future<AssignedOrderWorkOrderSign> fetchAssignedOrderWorkOrderSign(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  await storeLastPosition(http.Client());

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorder/$assignedorderPk/get_workorder_sign_details/');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return AssignedOrderWorkOrderSign.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load assigned order activity');
}

class AssignedOrderWorkOrderPage extends StatefulWidget {
  @override
  AssignedOrderWorkOrderPageState createState() => AssignedOrderWorkOrderPageState();
}

class AssignedOrderWorkOrderPageState extends State<AssignedOrderWorkOrderPage> {
  ByteData _imgUser = ByteData(0);
  ByteData _imgCustomer = ByteData(0);
  var color = Colors.black;
  var strokeWidth = 2.0;
  final _signUser = GlobalKey<SignatureState>();
  final _signCustomer = GlobalKey<SignatureState>();
  var _equimentController = TextEditingController();
  var _descriptionWorkController = TextEditingController();
  var _customerEmailsController = TextEditingController();
  AssignedOrderWorkOrderSign _signData;

  Future<void> _setOrientation() async {
    // WidgetsFlutterBinding.ensureInitialized();
    // await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  void initState() {
    super.initState();
    _setOrientation();
  }

  Widget _createSignatureUser() {
    return Container(
      width: 300,
      height: 100,
      child: Signature(
          color: color,
          key: _signUser,
          onSign: () {
          },
          // backgroundPainter: _WatermarkPaint("2.0", "2.0"),
          strokeWidth: strokeWidth,
        ),
      color: Colors.black12,
    );
  }

  Widget _createSignatureCustomer() {
    return Container(
      width: 300,
      height: 100,
        child: Signature(
          color: color,
          key: _signCustomer,
          onSign: () {
          },
          // backgroundPainter: _WatermarkPaint("2.0", "2.0"),
          strokeWidth: strokeWidth,
        ),
      color: Colors.black12,
    );
  }

  Widget _createButtonsRowUser() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MaterialButton(
            color: Colors.green,
            onPressed: () async {
              final sign = _signUser.currentState;
              //retrieve image data, do whatever you want with it (send to server, save locally...)
              final image = await sign.getData();
              var data = await image.toByteData(format: ui.ImageByteFormat.png);
              sign.clear();
              final encoded = base64.encode(data.buffer.asUint8List());
              setState(() {
                _imgUser = data;
              });
              debugPrint("onPressed " + encoded);
            },
            child: Text("Save")),
        MaterialButton(
            color: Colors.grey,
            onPressed: () {
              final sign = _signUser.currentState;
              sign.clear();
              setState(() {
                _imgUser = ByteData(0);
              });
              debugPrint("cleared");
            },
            child: Text("Clear")),
      ],
    );
  }

  Widget _createButtonsRowCustomer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MaterialButton(
            color: Colors.green,
            onPressed: () async {
              final sign = _signCustomer.currentState;
              //retrieve image data, do whatever you want with it (send to server, save locally...)
              final image = await sign.getData();
              var data = await image.toByteData(format: ui.ImageByteFormat.png);
              sign.clear();
              final encoded = base64.encode(data.buffer.asUint8List());
              setState(() {
                _imgCustomer = data;
              });
              debugPrint("onPressed " + encoded);
            },
            child: Text("Save")),
        MaterialButton(
            color: Colors.grey,
            onPressed: () {
              final sign = _signCustomer.currentState;
              sign.clear();
              setState(() {
                _imgCustomer = ByteData(0);
              });
              debugPrint("cleared");
            },
            child: Text("Clear")),
      ],
    );
  }

  Widget _createTextFieldEquipment() {
    return Container(
        width: 300.0,
        child: TextFormField(
          controller: _equimentController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        )
    );
  }

  Widget _createTextFieldDescriptionWork() {
    return Container(
        width: 300.0,
        child: TextFormField(
          controller: _descriptionWorkController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        )
    );
  }

  Widget _createTextFieldCustomerEmails() {
    return Container(
        width: 300.0,
        child: TextFormField(
          controller: _customerEmailsController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        )
    );
  }

  Widget _buildLogo(member) => SizedBox(
      width: 100,
      height: 210,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<dynamic>(
              future: getUrl(member.companylogo),
              builder: (context, snapshot) {
                return Image.network(snapshot.data, cacheWidth: 100);
              }
            )
          ]
      )
  );

  Widget _buildMemberInfoCard(member) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(member),
        Flexible(
          child: _buildInfoCard(member)
        ),
      ]
  );

  Widget _buildInfoCard(member) {
    return SizedBox(
      height: 210,
      width: 1000,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ListTile(
              title: Text(member.address,
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(
                  '${member.countryCode}-${member.postal}\n${member.city}'),
              leading: Icon(
                Icons.restaurant_menu,
                color: Colors.blue[500],
              ),
            ),
            Divider(),
            ListTile(
              title: Text(member.tel,
                  style: TextStyle(fontWeight: FontWeight.w500)),
              leading: Icon(
                Icons.contact_phone,
                color: Colors.blue[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Workorder'),
        ),
        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SingleChildScrollView(
                child: FutureBuilder<AssignedOrderWorkOrderSign>(
                    future: fetchAssignedOrderWorkOrderSign(http.Client()),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Container(
                            child: Center(
                                child: Text("Loading...")
                            )
                        );
                      } else {
                        _signData = snapshot.data;
                        return Column(
                            children: <Widget>[
                              _buildMemberInfoCard(_signData.member),
                              _createTextFieldEquipment(),
                              Divider(),
                              _createTextFieldDescriptionWork(),
                              Divider(),
                              _createTextFieldCustomerEmails(),
                              Divider(),
                              _createSignatureUser(),
                              _createButtonsRowUser(),
                              _imgUser.buffer.lengthInBytes == 0 ? Container() : LimitedBox(maxHeight: 200.0, child: Image.memory(_imgUser.buffer.asUint8List())),
                              Divider(),
                              _createSignatureCustomer(),
                              _createButtonsRowCustomer(),
                              _imgCustomer.buffer.lengthInBytes == 0 ? Container() : LimitedBox(maxHeight: 200.0, child: Image.memory(_imgCustomer.buffer.asUint8List())),
                              ]
                            );
                      }
                    }
                ),
            )
          )
        )
    );
  }
}
