import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:solidity_flutter/get_checkpoint/custom_textfield.dart';
import 'package:web3dart/web3dart.dart';

class GetCheckpointsWidget extends StatefulWidget {
  const GetCheckpointsWidget({Key? key}) : super(key: key);

  @override
  _GetCheckpointsWidgetState createState() => _GetCheckpointsWidgetState();
}

class _GetCheckpointsWidgetState extends State<GetCheckpointsWidget> {
  TextEditingController itemId = TextEditingController();
  late Client httpClient;
  late Web3Client ethClient;
  bool data = false;
  late var myData;
  final String myAddress = '0x57FC2415edaB478B0B9e7B5A93A1930064205776';
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

  Future<void> getCheckpointsOf(
      String callFunction, String myAddress, var itemId) async {
    List<dynamic> result =
        await query(callFunction, [BigInt.from(int.parse(itemId.text))]);
    myData = result[0];
    print(myData);
    data = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomTextField(itemId),
                ElevatedButton(
                  onPressed: () {
                    getCheckpointsOf("getCheckpointsOf", myAddress, itemId);
                  },
                  child: const Text('Track Item'),
                ),
              ],
            ),
          ),
          data
              ? Expanded(
                  child: ListView.builder(
                    itemCount: myData.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(5), //card padding
                        child: Card(
                          elevation: 4,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                                child: Column(
                                  children: [
                                    Text(
                                      'Timestamp: ' + (index + 1).toString(),
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    Text(DateFormat(
                                                '\nEEEE, \ndd-MMM-yyy \nHH:mm:ss')
                                            .format(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        myData[index][4]
                                                                .toInt() *
                                                            1000)
                                                .toUtc()) +
                                        "\nGMT+0000")
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 1))),
                                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Status:',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      Text(myData[index][0]),
                                      Divider(
                                        thickness: 1,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      Text('Description:',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      Text(myData[index][1]),
                                      Divider(
                                        thickness: 1,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      Text('Operator Address:',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      Text(
                                        myData[index][2].toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                      Divider(
                                        thickness: 1,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      Text('Location:',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      Text(myData[index][3][0]),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const Text('Item checkpoints will be displayed here...'),
        ],
      ),
    );
  }
}
