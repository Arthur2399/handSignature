import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hand_signature/signature.dart';
import 'package:hands_in_action/src/widget/hands_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

HandSignatureControl control = new HandSignatureControl(
  threshold: 0.01,
  smoothRatio: 0.65,
  velocityRange: 2.0,
);
ValueNotifier<String?> svg = ValueNotifier<String?>(null);

ValueNotifier<ByteData?> rawImage = ValueNotifier<ByteData?>(null);

ValueNotifier<ByteData?> rawImageFit = ValueNotifier<ByteData?>(null);
final _globalKey = GlobalKey();

class _MyHomePageState extends State<MyHomePage> {
  @override
void initState(){
  super.initState();
  SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
  ]);
}
@override
dispose(){
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  super.dispose();
}
  bool get scrollTest => false;
  Uint8List? pngBytes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text('Firma del cliente'),
      ),
      backgroundColor: Colors.orange,
      body: scrollTest
          ? ScrollTest()
          : SafeArea(
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 2.0,
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  constraints: BoxConstraints.expand(),
                                  color: Colors.white,
                                  child: HandSignaturePainterView(
                                    control: control,
                                    type: SignatureDrawType.shape,
                                  ),
                                ),
                                CustomPaint(
                                  painter: DebugSignaturePainterCP(
                                    control: control,
                                    cp: false,
                                    cpStart: false,
                                    cpEnd: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  //        onClickCreateClient();
                                },
                                child: Text('Registrar cobro'),
                              ),
                              CupertinoButton(
                                onPressed: () {
                                  control.clear();
                                  svg.value = null;
                                  rawImage.value = null;
                                  rawImageFit.value = null;
                                },
                                child: Text('clear'),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImageView() => Container(
        width: 192.0,
        height: 96.0,
        decoration: BoxDecoration(
          border: Border.all(),
          color: Colors.white30,
        ),
        child: ValueListenableBuilder<ByteData?>(
          valueListenable: rawImage,
          builder: (context, data, child) {
            if (data == null) {
              return Container(
                color: Colors.red,
                child: const Center(
                  child: Text('not signed yet (png)\nscaleToFill: false'),
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.memory(data.buffer.asUint8List()),
              );
            }
          },
        ),
      );
  Widget _buildScaledImageView() => Container(
        width: 192.0,
        height: 96.0,
        decoration: BoxDecoration(
          border: Border.all(),
          color: Colors.white30,
        ),
        child: ValueListenableBuilder<ByteData?>(
          valueListenable: rawImageFit,
          builder: (context, data, child) {
            if (data == null) {
              return Container(
                color: Colors.red,
                child: Center(
                  child: Text('not signed yet (png)\nscaleToFill: true'),
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.memory(data.buffer.asUint8List()),
              );
            }
          },
        ),
      );
  Widget _buildSvgView() => Container(
        width: 192.0,
        height: 96.0,
        decoration: BoxDecoration(
          border: Border.all(),
          color: Colors.white30,
        ),
        child: ValueListenableBuilder<String?>(
          valueListenable: svg,
          builder: (context, data, child) {
            return HandSignatureView.svg(
              data: data,
              padding: const EdgeInsets.all(8.0),
              placeholder: Container(
                color: Colors.red,
                child: const Center(
                  child: Text('not signed yet (svg)'),
                ),
              ),
            );
          },
        ),
      );
}
