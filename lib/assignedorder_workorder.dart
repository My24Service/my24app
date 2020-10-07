import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';


class AssignedOrderWorkOrderPage extends StatefulWidget {
  @override
  AssignedOrderWorkOrderPageState createState() => AssignedOrderWorkOrderPageState();
}

class _WatermarkPaint extends CustomPainter {
  final String price;
  final String watermark;

  _WatermarkPaint(this.price, this.watermark);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 10.8, Paint()..color = Colors.blue);
  }

  @override
  bool shouldRepaint(_WatermarkPaint oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _WatermarkPaint && runtimeType == other.runtimeType && price == other.price && watermark == other.watermark;

  @override
  int get hashCode => price.hashCode ^ watermark.hashCode;
}

class AssignedOrderWorkOrderPageState extends State<AssignedOrderWorkOrderPage> {
  ByteData _imgUser = ByteData(0);
  ByteData _imgCustomer = ByteData(0);
  var color = Colors.black;
  var strokeWidth = 2.0;
  final _signUser = GlobalKey<SignatureState>();
  final _signCustomer = GlobalKey<SignatureState>();

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
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Signature(
          color: color,
          key: _signUser,
          onSign: () {
            final sign = _signUser.currentState;
            debugPrint('${sign.points.length} points in the signature');
          },
          // backgroundPainter: _WatermarkPaint("2.0", "2.0"),
          strokeWidth: strokeWidth,
        ),
      ),
      color: Colors.black12,
    );
  }

  Widget _createSignatureCustomer() {
    return Container(
      width: 300,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(1.1),
        child: Signature(
          color: color,
          key: _signCustomer,
          onSign: () {
            final sign = _signCustomer.currentState;
            debugPrint('${sign.points.length} points in the signature');
          },
          // backgroundPainter: _WatermarkPaint("2.0", "2.0"),
          strokeWidth: strokeWidth,
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
              children: <Widget>[
                Divider(),
                _createSignatureUser(),
                _createButtonsRowUser(),
                _imgUser.buffer.lengthInBytes == 0 ? Container() : LimitedBox(maxHeight: 200.0, child: Image.memory(_imgUser.buffer.asUint8List())),
                Divider(),
                _createSignatureCustomer(),
                _createButtonsRowCustomer(),
                _imgCustomer.buffer.lengthInBytes == 0 ? Container() : LimitedBox(maxHeight: 200.0, child: Image.memory(_imgCustomer.buffer.asUint8List())),
                Column(
                  children: <Widget>[
                  ],
                )
              ],
      )
    );
  }
}
