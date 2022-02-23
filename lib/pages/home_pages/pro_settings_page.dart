import 'package:flutter/material.dart';

class ProSettingsPage extends StatefulWidget {
  ProSettingsPage({Key? key}) : super(key: key);

  @override
  State<ProSettingsPage> createState() => _ProSettingsPageState();
}

class _ProSettingsPageState extends State<ProSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pro settings')),
      body: _bodyContainer(),
    );
  }

  Widget _bodyContainer() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              child: TextField(
                // controller: _passwordController,
                // focusNode: _passwordFocusNode,
                keyboardType: TextInputType.text,
                autofillHints: [AutofillHints.password],
                obscureText: true,
                decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.secondary,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    labelText: 'Search for Player',
                    icon: Icon(
                      Icons.person,
                    ),
                    border: InputBorder.none),
                onSubmitted: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
