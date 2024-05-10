import 'package:coffeeshop_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'home.dart';
import 'dart:convert';
import 'dart:io';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  _authenticationSuccess(Response response) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => HomePage(
                  authenticationToken:
                      (jsonDecode(response.body) as Map<String, dynamic>)
                          .values
                          .firstOrNull,
                )));
  }

  _authenticationFailed(String authenticationError) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Authentication Failed",
            textAlign: TextAlign.center,
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  authenticationError,
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

  _performAuthentication() {
    post(Uri.parse("${Constants.apiUrl}/api/v1/authorize"),
            headers: {
              HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8",
              "Access-Control-Allow-Origin": "*",
              HttpHeaders.acceptHeader: "application/json",
            },
            body: jsonEncode(<String, String>{
              'username': usernameController.text,
              'password': passwordController.text,
            }))
        .then((response) => response.statusCode == 200
            ? _authenticationSuccess(response)
            : _authenticationFailed(
                "Please check your username and password combinations it looks like you mispelled some of those"))
        .onError((error, stackTrace) => _authenticationFailed(
            "Server unavailable or other infrastructure error, please retry in a few minutes"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login to Coffeeshop"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: SizedBox(
                    width: 200,
                    height: 150,
                    child: Image.asset('asset/images/flutter-logo.png')),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter your username'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: _performAuthentication,
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            const SizedBox(
              height: 130,
            ),
          ],
        ),
      ),
    );
  }
}
