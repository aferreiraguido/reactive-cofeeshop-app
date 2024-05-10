import 'package:coffeeshop_app/constants.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:coffeeshop_app/pages/login.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.authenticationToken});

  final String authenticationToken;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _customerNameController = TextEditingController();
  final List<String> _coffeTypes = [
    "Espresso",
    "Americano",
    "Cappuccino",
    "Mocha",
    "Latte"
  ];
  final List<String> _coffeStatus = ["Received", "Preparation", "Ready"];
  bool _pickYourRequest = true;
  int _bottomNavigationBarItemSelected = 0;
  int _selectedCoffeeToBrew = -1;
  int _brewingCoffeStatus = -1;

  _requestCoffee(int selectedCoffeeToBrew, String customerName) {
    setState(() {
      _bottomNavigationBarItemSelected = selectedCoffeeToBrew;
      _pickYourRequest = false;
    });

    SSEClient.subscribeToSSE(
        method: SSERequestType.POST,
        url: '${Constants.apiUrl}/api/v3/request',
        header: {
          HttpHeaders.authorizationHeader:
              "Bearer ${widget.authenticationToken}",
          HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8",
          HttpHeaders.acceptHeader: "text/event-stream",
          HttpHeaders.cacheControlHeader: "no-cache",
        },
        body: {
          "coffee": _coffeTypes[_selectedCoffeeToBrew],
          "customer": customerName,
        }).listen(
      (event) {
        setState(() {
          _brewingCoffeStatus = _coffeStatus.indexOf(jsonDecode(event.data!)
              .entries
              .firstWhere((element) => element.key == "status")
              .value);
          if (_brewingCoffeStatus == 2) {
            _customerNameController.clear();
            _selectedCoffeeToBrew = -1;
            _pickYourRequest = true;
          }
        });
      },
    );
  }

  _requestCoffeeFailed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Can't Accept Order",
            textAlign: TextAlign.center,
          ),
          content: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  "Please pick your coffee and add your name before submitting your order",
                  textAlign: TextAlign.justify,
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Brew My Coffee"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButtonFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  value: _selectedCoffeeToBrew,
                  disabledHint: const Text("disabled"),
                  items: const [
                    DropdownMenuItem(
                      value: -1,
                      child: Text("--- Pick your coffee ---"),
                    ),
                    DropdownMenuItem(
                      value: 0,
                      child: Text("Espresso"),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text("Americano"),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text("Cappuccino"),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text("Mocha"),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text("Latte"),
                    ),
                  ],
                  onChanged: _pickYourRequest
                      ? (value) =>
                          _selectedCoffeeToBrew = int.parse(value.toString())
                      : null),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  enabled: _pickYourRequest,
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                      labelText: 'Name', hintText: 'Please tell us your name'),
                ),
              ),
              if (_brewingCoffeStatus >= 0) ...[
                const SizedBox(height: 20),
                Image.asset(
                    'asset/images/coffee-${_coffeStatus[_brewingCoffeStatus].toLowerCase()}.png'),
                const SizedBox(height: 20),
                Text(
                    "Your order status is ${_coffeStatus[_brewingCoffeStatus]}"),
              ]
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.coffee),
            label: 'Brew',
          ),
        ],
        currentIndex: _bottomNavigationBarItemSelected,
        selectedItemColor: Colors.amber[800],
        onTap: (int index) {
          switch (index) {
            case 0:
              SSEClient.unsubscribeFromSSE();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginPage()));
            case 1:
              if (index >= 0 && _customerNameController.text.length > 2) {
                _requestCoffee(index, _customerNameController.text);
              } else {
                _requestCoffeeFailed();
              }
          }
        },
      ),
    );
  }
}
