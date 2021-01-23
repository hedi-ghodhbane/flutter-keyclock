import 'package:flutter/material.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String userAccessToken;

  String userName;
  dynamic authenticator;
  authenticate() async {
    var uri = Uri.parse('http://key-clock-url/auth/realms/myrealm');
    var clientId = 'client-id';
    var scopes = List<String>.of(['openid', 'profile']);
    var port = 8080;
    var issuer = await Issuer.discover(uri);
    var client = new Client(issuer, clientId);
    urlLauncher(String url) async {
      if (await canLaunch(url)) {
        await launch(url, forceWebView: true);
      } else {
        throw 'Could not launch $url';
      }
    }

    authenticator = new Authenticator(
      client,
      scopes: scopes,
      port: port,
      urlLancher: urlLauncher,
    );
    var c = await authenticator.authorize();
    closeWebView();
    var token = await c.getTokenResponse();
    var userInformation = await c.getUserInfo();
    setState(() {
      userAccessToken = token.accessToken;
      userName = userInformation.preferredUsername;
    });
    print(token);
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Text("open"),
              onPressed: () async {
                authenticate();
              },
            ),
            appBar: AppBar(title: Text("keyclock")),
            body: Text("body")));
  }
}
