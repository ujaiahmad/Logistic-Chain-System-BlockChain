import 'package:flutter/material.dart';
import 'package:solidity_flutter/item_details/getItemDetails.dart';
import 'get_checkpoint/getCheckpoint.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracking Parcel',
      theme: ThemeData(
          primaryColor: Colors.purple,
          primarySwatch: Colors.purple,
          secondaryHeaderColor: Colors.amberAccent),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Courier Company Smart Contract.'),
            centerTitle: true,
            elevation: 3,
            bottom: const TabBar(tabs: [
              Tab(child: Text('Item Details')),
              Tab(child: Text('Track Item')),
            ]),
          ),
          body:
              TabBarView(children: [GetItemDetails(), GetCheckpointsWidget()])),
    );
  }
}
