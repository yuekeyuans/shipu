import "package:flutter/material.dart";
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePage extends StatefulWidget {
  @override
  _QrCodePageState createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("查看二维码")),
      body: QrImage(
        data: "1234567890",
        version: QrVersions.auto,
        size: 200.0,
      ),
    );
  }
}
