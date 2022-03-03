import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hand_signature/signature.dart';

import 'dart:io';

import 'package:path_provider/path_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

HandSignatureControl control = HandSignatureControl(
  threshold: 0.01,
  smoothRatio: 0.65,
  velocityRange: 2.0,
);



class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  late File file;
  Future<File> _gettemporaryImgae() async {
    final tempDir = await getExternalStorageDirectory();

    File file = await File('${tempDir!.path}/firma.png').create();
    return file;
  }

  bool get scrollTest => false;
  Uint8List? pngBytes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firma del cliente'),
      ),
      backgroundColor: Colors.indigo,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 4.0,
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                             
                              color: Colors.white,
                              child: SizedBox(
                                 width: double.infinity,
                                 height: 300,
                                child: HandSignaturePainterView(
                                  control: control,
                                  type: SignatureDrawType.shape,
                                ),
                              ),
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
                        FutureBuilder<File>(
                            future: _gettemporaryImgae(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: Text('Cargando'));
                              }
                              return ElevatedButton(
                                onPressed: () async {
                                  if (control.isFilled) {
                                    file = snapshot.data!;
                                    _buildImageView(file);
                                  }
                                  //        onClickCreateClient();
                                },
                                child: const Text('Registrar cobro'),
                              );
                            }),
                        ElevatedButton(
                          onPressed: () {
                            control.clear();
                          },
                          child: const Text('Limpiar'),
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

  _buildImageView(File file) async {
    ByteData? image = await control.toImage(
      width: 200,
      height: 200,
      background: Colors.white,
      color: Colors.black,
      format: ImageByteFormat.png,
    );
    final buffer = image!.buffer;
    file.writeAsBytes(
        buffer.asUint8List(image.offsetInBytes, image.lengthInBytes));
    print(file.path);
  }
}
