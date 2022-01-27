import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:solidity_flutter/get_checkpoint/custom_textfield.dart';
import 'package:web3dart/web3dart.dart';

class GetItemDetails extends StatefulWidget {
  GetItemDetails({Key? key}) : super(key: key);

  @override
  _GetItemDetailsState createState() => _GetItemDetailsState();
}

class _GetItemDetailsState extends State<GetItemDetails> {
  TextEditingController itemId = TextEditingController();
  late Client httpClient;
  late Web3Client ethClient;
  String status = 'Processing';
  String shipment = 'Domestic';
  var time = 0;
  bool data = false;
  late var myData;
  final String myAddress = '0x57FC2415edaB478B0B9e7B5A93A1930064205776';
  //Infura url
  final String blockchainUrl =
      'https://ropsten.infura.io/v3/379d8731e04f4b1eb4c5bba1726b0c94';

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(blockchainUrl, httpClient);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString('assets/contract.json');
    String contractAddress = '0xEB3741e05Cd22f44d6dC0Ba29FdE4CB44f90a1FD';

    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "CourierCompany"),
        EthereumAddress.fromHex(contractAddress));
    //print(contract);
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<void> getItemDetails(
      String callFunction, String myAddress, var itemId) async {
    List<dynamic> result =
        await query(callFunction, [BigInt.from(int.parse(itemId.text))]);
    myData = result[0];
    data = true;
    setState(() {
      if (myData[4].toInt() == 1) {
        status = 'Ongoing';
      } else if (myData[4].toInt() == 2) {
        status = 'Completed';
      } else {
        status = 'Lost in Transit';
      }

      if (myData[1].toInt() == 1) {
        shipment = 'International';
      }

      if (myData[7].toInt() != 0) {
        time = myData[7].toInt();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomTextField(itemId),
                ElevatedButton(
                  onPressed: () {
                    getItemDetails("getItemOf", myAddress, itemId);
                  },
                  child: const Text('Get Details'),
                ),
              ],
            ),
          ),
          data //Text(myData.toString()
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Table(border: TableBorder.all(), children: [
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Shipment Type: '),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(shipment),
                      ),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Destination: '),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(myData[3][1][0].toString()),
                      ),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Item Status: '),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(
                              8.0), //Text(myData[4].toString())
                          child: Text(status)),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Date Created: '),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              DateFormat('EEEE, \ndd-MMM-yyy \nHH:mm:ss')
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                                  myData[6].toInt() * 1000)
                                              .toUtc()) +
                                  " GMT+0000")),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Date Completed: '),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: time != 0
                              ? Text(DateFormat('EEEE, \ndd-MMM-yyy \nHH:mm:ss')
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                                  myData[7].toInt() * 1000)
                                              .toUtc()) +
                                  " GMT+0000")
                              : Text('Not Arrived')),
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Price: '),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(myData[9].toString() + " Wei"),
                      ),
                    ]),
                  ]),
                )
              : const Text('Item details will be displayed here...'),
        ],
      ),
    );
  }
}
