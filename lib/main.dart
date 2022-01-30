// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(FlutterBlueApp());
}

class FlutterBlueApp extends StatefulWidget {
  FlutterBlueApp({Key? key}) : super(key: key);
  List<ScanResult> results = [];
  List<BluetoothDevice> devices = [];

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  int spo2 = 0;
  int pr = 0;
  String data = "";
  @override
  void initState() {
    flutterBlue.connectedDevices.then((value) {
      if (value.length == 0) {
        flutterBlue.startScan();
        flutterBlue.scanResults.listen((event) {
          setState(() {
            widget.results = event;
            print(event);
          });
        });
      } else {
        value[0].discoverServices().then((value) {
          value.forEach((e) async {
            await e.characteristics[1].setNotifyValue(true);
            e.characteristics[1].value.listen((event) {
              setState(() {
                spo2 = event[6];
                pr = event[7];
                data = event.toString();
              });
            });
          });
        });
        setState(() {
          widget.devices = value;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: Text(spo2.toString()),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: Text(pr.toString()),
                  ),
                ],
              ),
              Text(data),
              Expanded(
                  child: Column(
                children: widget.results.map((e) {
                  return Row(
                    children: [
                      Text(e.device.name.toString() == "" ? e.device.id.toString() : e.device.name.toString()),
                      ElevatedButton(
                          onPressed: () async {
                            await e.device.connect();
                            print('connected');
                          },
                          child: Text("Connect")),
                    ],
                  );
                }).toList(),
              )),
              Expanded(
                  child: Column(
                children: widget.devices.map((e) {
                  return Row(
                    children: [
                      Text(e.name.toString() == "" ? e.id.toString() : e.name.toString()),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              e.disconnect();
                              data = "";
                            });
                          },
                          child: Text("Disconnect")),
                    ],
                  );
                }).toList(),
              )),
            ],
          ),
        ),
      ),
    ));
  }
}
