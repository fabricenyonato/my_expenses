import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './utils.dart';

class SettingsPage extends StatefulWidget {
    @override
    _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
    bool _showHiddenExpenses = false;
    double _solde = 0.0;

    @override
    void initState() {
        super.initState();

        SharedPreferences.getInstance()
        .then((SharedPreferences prefs) {
            setState(() {
                _showHiddenExpenses = prefs.getBool(SettingKey.SHOW_HIDDEN_EXPENSES) ?? false;
            });
        })
        .catchError((e) {
            print(e);
        });
    }

    @override
    void dispose() {
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
                appBar: AppBar(
                    title: Text('Settings'),
                ),
                body: ListView(
                    children: ListTile.divideTiles(
                        context: context,
                        tiles: [
                            ListTile(
                                title: Text('Solde'),
                                subtitle: Text(_solde.toString()),
                            ),
                            CheckboxListTile(
                                title: Text('Show hidden expenses'),
                                value: _showHiddenExpenses,
                                onChanged: (bool value) {
                                    SharedPreferences.getInstance()
                                    .then((SharedPreferences prefs) {
                                        setState(() {
                                            prefs.setBool(SettingKey.SHOW_HIDDEN_EXPENSES, value);

                                            setState(() {
                                                _showHiddenExpenses = value;
                                            });
                                        });
                                    })
                                    .catchError((e) {
                                        print(e);
                                    });
                                },
                            )
                        ]
                    ).toList()
                ),
            ),
        );
    }

    Future<bool> _onWillPop() async {
        Navigator.pop(context, {
            'showHiddenExpenses': _showHiddenExpenses
        });
        return false;
    }
}
