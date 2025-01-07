import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:simple_currency_converter/extensions/text_editing_controller_ext.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Quick KRW to MYR Converter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? _debounce;

  final TextEditingController _krwController = TextEditingController();
  final TextEditingController _myrController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  double _convertedAmount = 0.0;

  final String _exchangeRateKey = 'EXCHANGE_RATE';

  void _onChangeForKrw(text) {
    _convertCurrency(true);
  }

  void _onChangeForMyr(text) {
    _convertCurrency(false);
  }

  void _convertCurrency(bool isKrwToMyr) {
    double krw = double.tryParse(_krwController.text) ?? 0.0;
    double myr = double.tryParse(_myrController.text) ?? 0.0;
    double rate = double.tryParse(_rateController.text) ?? 0.0;

    if (isKrwToMyr) {
      _convertedAmount = krw / 1000 * rate;
    } else {
      _convertedAmount = myr * 1000 / rate;
    }

    setState(() {
      if (isKrwToMyr) {
        _myrController.text = _convertedAmount.toStringAsFixed(2);
      } else {
        _krwController.text = _convertedAmount.round().toString();
      }
    });
  }

  void _setDefaultRate() async {
    setState(() {
      _rateController.text = '3.195';
    });
    await _saveExchangeRate('3.195');
  }

  void _onChangeForRate(String text) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () async {
      _saveExchangeRate(text);
    });
  }

  Future<void> _saveExchangeRate(String text) async {
    double rate = double.tryParse(text) ?? 0.0;

    // Load and obtain the shared preferences for this app.
    final prefs = await SharedPreferences.getInstance();

    // Save the exchange rate value to persistent storage under the 'EXCHANGE_RATE' key.
    await prefs.setDouble(_exchangeRateKey, rate);
  }

  Future<void> _getExchangeRateAsync() async {
    final prefs = await SharedPreferences.getInstance();

    // Try reading the counter value from persistent storage.
    // If not present, null is returned, so default to 0.
    final exchangeRate = prefs.getDouble(_exchangeRateKey) ?? 3.195;

    _rateController.text = exchangeRate.toString();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getExchangeRateAsync();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Exchange Rate',
                        style: themeData.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '1000 KRW to',
                            style: themeData.textTheme.bodyLarge,
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 150,
                            child: TextField(
                              controller: _rateController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9.]+')),
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'MYR',
                              ),
                              onTap: _rateController.selectAll,
                              onChanged: _onChangeForRate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('We exchanged at 3.195',
                          style: themeData.textTheme.bodyLarge),
                      FilledButton(
                        onPressed: _setDefaultRate,
                        child: const Text('Reset to Default'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Convert', style: themeData.textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _krwController,
                              style: const TextStyle(fontSize: 28),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'KRW',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9.]+')),
                              ],
                              autofocus: true,
                              onTap: _krwController.selectAll,
                              onChanged: _onChangeForKrw,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('<>', style: themeData.textTheme.bodyLarge),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _myrController,
                              style: const TextStyle(fontSize: 28),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'MYR',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9.]+')),
                              ],
                              onTap: _myrController.selectAll,
                              onChanged: _onChangeForMyr,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
