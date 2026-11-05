import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart'; // External package for expression evaluation

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter calculator Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Calculator Home Page'),
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
  int _counter = 0;

  //Stores expression

  String _expression = '';

  //Stores result

  String _display = '0';

  //Used to determine whether the last action was "=".

  bool _calculationComplete = false;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  //Determines whether a character is an arithmetic operator or not

  bool _isOperator(String value) {
    return value == '+' || value == '-' || value == '*' || value == '/';
  }

  //Handles the numbers and the operator button presses

  void _buttonPressed(String value) {
    setState(() {
      // If a previous calculation was completed and the user presses
      // a number, start a new calculation

      if (_calculationComplete && !_isOperator(value)) {
        _expression = '';
        _display = '0';
        _calculationComplete = false;
      }

      // If a previous calculation was completed and an operator is
      // pressed, continue calculating using the previous result

      if (_calculationComplete && _isOperator(value)) {
        String previousResult = _display.split('=').last.trim();
        _expression = previousResult;
        _calculationComplete = false;
      }

      // Prevents an expression from starting with *, or /

      if (_expression.isEmpty && (value == '*' || value == '/')) {
        return;
      }

      // Prevents multiple operators from being entered consecutively

      if (_expression.isNotEmpty &&
          _isOperator(value) &&
          _isOperator(_expression[_expression.length - 1])) {
        // Replaces the previous operator with the newly selected operator

        _expression = _expression.substring(0, _expression.length - 1) + value;
      } else {
        _expression += value;
      }

      _display = _expression;
    });
  }

  //Calculates the expression using the expressions package.

  void _calculateResult() {
    if (_expression.isEmpty) {
      return;
    }

    // Prevents the calculation if the expression ends with an operator

    if (_isOperator(_expression[_expression.length - 1])) {
      setState(() {
        _display = 'Error: Incomplete expression';
      });

      return;
    }

    try {
      // Parses the mathematical expression

      Expression expression = Expression.parse(_expression);

      // Creates the evaluator

      final evaluator = const ExpressionEvaluator();

      // Evaluates the expression

      dynamic result = evaluator.eval(expression, {});

      // Checks for invalid numeric result

      if (result is double && (result.isInfinite || result.isNaN)) {
        setState(() {
          _display = 'Error: Cannot divide by zero';
          _calculationComplete = true;
        });

        return;
      }

      // Formats whole numbers

      String formattedResult;

      if (result is double && result == result.roundToDouble()) {
        formattedResult = result.toInt().toString();
      } else {
        formattedResult = result.toString();
      }

      setState(() {
        // Shows the expression and the result in the accumulator

        _display = '$_expression = $formattedResult';
        _calculationComplete = true;
      });
    } catch (e) {
      setState(() {
        _display = 'Error: Invalid expression';
        _calculationComplete = true;
      });
    }
  }

  // Squares the current number displayed in the calculator

  void _squareNumber() {
    if (_expression.isEmpty) {
      return;
    }

    try {
      // If a previous calculation was completed, use its result

      String currentValue = _expression;

      if (_calculationComplete) {
        currentValue = _display.split('=').last.trim();
      }

      // Evaluate the current expression
      Expression expression = Expression.parse(currentValue);
      final evaluator = const ExpressionEvaluator();

      dynamic number = evaluator.eval(expression, {});

      // Square the number

      dynamic result = number * number;

      // Format the result to remove unnecessary decimals

      String formattedResult;

      if (result is double && result == result.roundToDouble()) {
        formattedResult = result.toInt().toString();
      } else {
        formattedResult = result.toString();
      }

      setState(() {
        _display = '($currentValue)² = $formattedResult';
        _expression = formattedResult;
        _calculationComplete = true;
      });
    } catch (e) {
      setState(() {
        _display = 'Error: Invalid expression';
        _calculationComplete = true;
      });
    }
  }

  //Clears the calculator

  void _clearCalculator() {
    setState(() {
      _expression = '';
      _display = '0';
      _calculationComplete = false;
    });
  }

  //Reusable button

  Widget _calculatorButton(String text, {VoidCallback? onPressed}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            onPressed: onPressed ?? () => _buttonPressed(text),
            child: Text(
              text,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        // Displays your name as the title of the calculator
        title: Text(widget.title),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Calculator display / accumulator
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.bottomRight,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _display,

                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Clear button
              Row(
                children: [
                  _calculatorButton('C', onPressed: _clearCalculator),

                  _calculatorButton('x²', onPressed: _squareNumber),
                ],
              ),

              // 7 8 9 /
              Row(
                children: [
                  _calculatorButton('7'),
                  _calculatorButton('8'),
                  _calculatorButton('9'),
                  _calculatorButton('/'),
                ],
              ),

              // 4 5 6 *
              Row(
                children: [
                  _calculatorButton('4'),
                  _calculatorButton('5'),
                  _calculatorButton('6'),
                  _calculatorButton('*'),
                ],
              ),

              // 1 2 3 -
              Row(
                children: [
                  _calculatorButton('1'),
                  _calculatorButton('2'),
                  _calculatorButton('3'),
                  _calculatorButton('-'),
                ],
              ),

              // 0 + =
              Row(
                children: [
                  _calculatorButton('0'),
                  _calculatorButton('+'),
                  _calculatorButton('=', onPressed: _calculateResult),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
