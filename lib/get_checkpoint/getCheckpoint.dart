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
  TextEditingController itemId = TextEditingController(); //gather user input
  //initialisation
  late Client httpClient;
  late Web3Client ethClient;
  bool data = false;
  late var myData;

  //sample address using metamask
  final String myAddress = '0x57FC2415edaB478B0B9e7B5A93A1930064205776';
  //using ropsten as the testnet
  final String blockchainUrl =
      'https://ropsten.infura.io/v3/379d8731e04f4b1eb4c5bba1726b0c94';

  //get and set the myAddress and  blockchain url
  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(blockchainUrl, httpClient);
  }

  //function to load the contract
  Future<DeployedContract> loadContract() async {
    //load abi of the contract 'couriercompany'
    String abi = await rootBundle.loadString('assets/contract.json');
    //sample contract address deployed on ropsten
    String contractAddress = '0xEB3741e05Cd22f44d6dC0Ba29FdE4CB44f90a1FD';

    //get contract
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "CourierCompany"),
        EthereumAddress.fromHex(contractAddress));
    //print(contract); for  debugging
    return contract;
  }

  //get specific function inside the contracts
  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    //get contract
    final contract = await loadContract();
    //get functionname
    final ethFunction = contract.function(functionName);
    //call the function inside the contract along with the arguments
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  //use the function get checkpointsof
  Future<void> getCheckpointsOf(
      String callFunction, String myAddress, var itemId) async {
    List<dynamic> result =
        await query(callFunction, [BigInt.from(int.parse(itemId.text))]);
    myData = result[0];
    //print(myData); for debuggin
    data = true; //finish loading
    setState(() {});
  }

  //buidling the user interface
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
                CustomTextField(itemId), //make custom user input
                ElevatedButton(
                  onPressed: () {
                    //call function getcheckpointsof, using my address and itemid as the input
                    getCheckpointsOf("getCheckpointsOf", myAddress, itemId);
                  },
                  child: const Text('Track Item'),
                ),
              ],
            ),
          ),
          data //loading
              ? Expanded(
                  child: ListView.builder(
                    //build the list based on myData.length
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
                                      //convert epoch to real time
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
                                      //display all the details
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
