import 'package:cal1/calcButton.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  String equation = "0";
  String result = "0";
  String expression = "";
  double equationFontSize = 38.0;
  double resultFontSize = 48.0;

bool isResultDisplayed = false; //if the result is currently displayed

buttonPressed(String buttonText) {
  //check if the result contains unnecessary decimal places
  String doesContainDecimal(dynamic result) {
    if (result.toString().contains('.')) {
      List<String> splitDecimal = result.toString().split('.');
      if (!(int.parse(splitDecimal[1]) > 0)) {
        return splitDecimal[0];
      }
    }
    return result.toString();
  }

  setState(() {
    if (buttonText == "AC") {
      equation = "0";
      result = "0";
      isResultDisplayed = false;
    } else if (buttonText == "⌫") {
      if (isResultDisplayed) {
        equation = "0";
        isResultDisplayed = false;
      } else {
        equation = equation.substring(0, equation.length - 1);
        if (equation == "") {
          equation = "0";
        }
      }
    } else if (equation.length >= 13) {
      return;
    } else if (buttonText == "+/-") {
      if (equation[0] != '-') {
        equation = '-$equation';
      } else {
        equation = equation.substring(1);
      }
    } else if (buttonText == "=") {
      expression = equation;
      expression = expression.replaceAll('×', '*');
      expression = expression.replaceAll('÷', '/');

      // Handle percentage by replacing `n%` with `n/100`
      if (expression.contains('%')) {
        expression = expression.replaceAllMapped(
          RegExp(r'(\d+\.?\d*)%'),
          (match) => '(${match.group(1)}/100)',
        );
      }

      if (expression.startsWith('√')) {
        expression = '${expression.replaceAll('√', 'sqrt(')})';
      } else if (expression.contains('√')) {
        expression = '${expression.replaceAll('√', '*sqrt(')})';
      }

      try {
        Parser p = Parser();
        Expression exp = p.parse(expression);

        ContextModel cm = ContextModel();
        result = '${exp.evaluate(EvaluationType.REAL, cm)}';

        if (result.contains('NaN')) {
          result = "Error";
        } else if (result.contains('Infinity')) {
          result = "Can't divide by 0";
        } else {
          double tempResult = double.parse(result);
          result = tempResult.toStringAsFixed(5);
          result = doesContainDecimal(result);
        }

        // Shorten result if too long
        if (result.length > 8) {
          try {
            double tempResult = double.parse(result);
            result = tempResult.toStringAsExponential(3);
          } catch (e) {
            result = result;
          }
        }

        // Cleanup trailing zeros in decimal
        if (result.contains('.')) {
          result = result.replaceAll(RegExp(r'0*$'), '');
        }
        if (result.endsWith('.')) {
          result = result.substring(0, result.length - 1);
        }
        if (result.isEmpty) {
          result = "0";
        }

        isResultDisplayed = true; // Set flag after calculation
      } catch (e) {
        result = "Error";
      }
    } else {
      if (isResultDisplayed) {
        // Clear the equation if a new input is entered after showing the result
        equation = buttonText;
        isResultDisplayed = false;
      } else if (equation == "0") {
        if ("+-×÷%.".contains(buttonText)) {
          equation = equation + buttonText;
        } else {
          equation = buttonText;
        }
      } else {
        // Prevent multiple operators in sequence
        if ("+-×÷%√.".contains(equation[equation.length - 1]) &&
            "+-×÷%√.".contains(buttonText)) {
          // Do nothing
        } else {
          // Prevent multiple decimals in a single number
          if (buttonText == '.' &&
              equation.split(RegExp(r'[+\-×÷%√]')).last.contains('.')) {
            // Do nothing
          } else {
            equation = equation + buttonText;
          }
        }
      }
    }
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 244,245,247),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(result,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                        color: result.contains("divide") ? const Color.fromRGBO(226, 89, 79, 1) : Color.fromARGB(255, 103, 100, 132), 
                                        fontSize: result.contains("divide") ? 30 : 80))),
                          const SizedBox(width: 20),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(equation,
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Color.fromARGB(255, 73, 74, 103),
                                )),
                          ),
                          IconButton(
                            icon: const Icon(Icons.backspace_outlined,
                                color: Color.fromARGB(255, 73, 74, 103), size: 30),
                            onPressed: () {
                              buttonPressed("⌫");
                            },
                          ),
                          const SizedBox(width: 20),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  calcButton('AC', const Color.fromARGB(255, 142, 133, 203), () => buttonPressed('AC')),
                  calcButton('%', const Color.fromARGB(255, 142, 133, 203), () => buttonPressed('%')),
                  calcButton('÷', const Color.fromARGB(255, 142, 133, 203), () => buttonPressed('÷')),
                  calcButton("×", const Color.fromARGB(255, 142, 133, 203), () => buttonPressed('×')),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  calcButton('7', const Color.fromARGB(255, 121, 118, 143), () => buttonPressed('7')),
                  calcButton('8', const Color.fromARGB(255, 121, 118, 143), () => buttonPressed('8')),
                  calcButton('9', const Color.fromARGB(255, 121, 118, 143), () => buttonPressed('9')),
                  calcButton('-', const Color.fromARGB(255, 142, 133, 203), () => buttonPressed('-')),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  calcButton('4', const Color.fromARGB(255, 121, 118, 143), () => buttonPressed('4')),
                  calcButton('5', const Color.fromARGB(255, 121, 118, 143), () => buttonPressed('5')),
                  calcButton('6', const Color.fromARGB(255, 121, 118, 143), () => buttonPressed('6')),
                  calcButton('+', const Color.fromARGB(255, 142, 133, 203), () => buttonPressed('+')),
                ],
              ),
              const SizedBox(height: 10),
              // calculator number buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  calcButton('1', const Color.fromARGB(255, 121, 118, 143), () => buttonPressed('1')),
                  calcButton('2', const Color.fromARGB(255, 121, 118, 143), () => buttonPressed('2')),
                  calcButton('3', const Color.fromARGB(255, 121, 118, 143), () => buttonPressed('3')),
                  calcButton('√', const Color.fromARGB(255, 142, 133, 203), () => buttonPressed('√')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  calcButton('+/-', const Color.fromARGB(255, 121, 118, 143), () => buttonPressed('+/-')),
                  calcButton('0', const Color.fromARGB(255, 121, 118, 143), () => buttonPressed('0')),
                  calcButton('.', const Color.fromARGB(255, 121, 118, 143), () => buttonPressed('.')),
                  calcButton('=', const Color.fromARGB(255, 142, 133, 203), () => buttonPressed('=')),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ));
  }
}
