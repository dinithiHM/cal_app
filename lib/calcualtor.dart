// Dinithi Mahathanthri
// IM/2021/110
// CourseWork 02

import 'dart:math'; // Import for sqrt
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'button_values.dart';

class CalculatorScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const CalculatorScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = "";
  List<String> history = [];
  bool showHistory = false;
  bool isResultDisplayed = false; // To track if the result is currently displayed

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive UI
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        actions: [
          // Toggle light/dark mode button
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
            ),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      backgroundColor:
          widget.isDarkMode ? Colors.blueGrey.shade800 : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Toggle History Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade300,
                  ),
                  onPressed: () {
                    setState(() {
                      showHistory = !showHistory;
                    });
                  },
                  child: const Text(
                    'History',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            // Display History Section
            if (showHistory)
              Expanded(
                child: Container(
                  color: widget.isDarkMode
                      ? Colors.black54
                      : Colors.blue.shade50,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _confirmClearHistory(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text('Clear History'),
                      ),
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                history[index], // Display history item
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Display Calculation Section
            if (!showHistory)
              Expanded(
                child: Column(
                  children: [
                    // Display current input or result
                    Expanded(
                      child: SingleChildScrollView(
                        reverse: true,
                        child: Container(
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            input.isEmpty ? "0" : input,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Display calculator buttons
                    Wrap(
                      children: Btn.buttonValues
                          .map(
                            (value) => SizedBox(
                              width: screenSize.width / 4,
                              height: screenSize.width / 5,
                              child: buildButton(value),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getButtonColor(value),
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: InkWell(
          onTap: () => handleButtonPress(value),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Handles logic when a button is pressed
  void handleButtonPress(String value) {
    if (value == Btn.del) {
      deleteLast();
    } else if (value == Btn.clr) {
      clearInput();
    } else if (value == Btn.calculate) {
      evaluateExpression(); // Evaluate the mathematical expression
    } else if (value == "√") {
      calculateSquareRoot(); // Handle square root calculation
    } else {
      appendValue(value);
    }
  }

  // Clear all input
  void clearInput() {
    setState(() {
      input = "";
    });
  }

  // Delete the last character of the input
  void deleteLast() {
    if (input.isNotEmpty) {
      setState(() {
        input = input.substring(0, input.length - 1);
      });
    }
  }

  void appendValue(String value) {
    // Auto-clear input if a result is currently displayed
    if (isResultDisplayed) {
      setState(() {
        input = ""; // Clear the previous result
        isResultDisplayed = false; // Reset the flag
      });
    }

    // Prevent multiple dots in a row
    if (value == Btn.dot && input.endsWith(Btn.dot)) return;

    setState(() {
      input += value;
    });
  }

  // Evaluate the mathematical expression
  // No changes to imports or class definitions.

void evaluateExpression() {
  try {
    String formattedInput = input;

    // Replace custom operators for the parser.
    formattedInput = formattedInput
        .replaceAll(Btn.multiply, '*')
        .replaceAll(Btn.divide, '/');

    // Handle percentage (%) as a percentage of the preceding number.
    if (formattedInput.contains('%')) {
      // Replace '%' with '/100' for correct calculation.
      formattedInput = formattedInput.replaceAll('%', '/100');
    }

    // Parse and evaluate the mathematical expression.
    Parser parser = Parser();
    Expression expression = parser.parse(formattedInput);
    double result = expression.evaluate(EvaluationType.REAL, ContextModel());

    // Check floatings
    if (result.isInfinite || result.isNaN) {
      throw Exception("Division by zero or invalid operation");
    }

    setState(() {
      history.add("$input = $result"); // Add to history
      input = result.toString().replaceAll(RegExp(r"0*$"), "").replaceAll(RegExp(r"\.$"), "");
      isResultDisplayed = true; // Mark that a result is displayed
    });
  } catch (e) {
    setState(() {
      input = "Error"; // Display "Error" if input is invalid
    });
    autoClearInput(); // Clear error after a delay
  }
}


  // Handle square root calculation
  void calculateSquareRoot() {
    try {
      double number = double.parse(input);
      if (number < 0) {
        setState(() {
          input = "Error"; // Display error for negative numbers
        });
      } else {
        double result = sqrt(number); // Calculate the square root
        setState(() {
          history.add("√$input = $result"); // Add to history
          input = result.toString();
          isResultDisplayed = true; // Mark that a result is displayed
        });
      }
    } catch (e) {
      setState(() {
        input = "Error"; // Handle invalid input
      });
      autoClearInput(); // Clear error after a delay
    }
  }

  // Confirm before clearing the history
  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear History"),
        content: const Text("Are you sure you want to clear the history?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                history.clear();
              });
              Navigator.pop(context);
            },
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  // Automatically clear the input after an error
  void autoClearInput() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        input = "";
      });
    });
  }

  Color getButtonColor(String value) {
    if ([Btn.del, Btn.clr].contains(value)) return Colors.amber;
    if ([Btn.per, Btn.multiply, Btn.add, Btn.subtract, Btn.divide, Btn.calculate]
        .contains(value)) {
      return Colors.amber.shade300;
    }
    return widget.isDarkMode ? Colors.blueGrey.shade700 : Colors.amber.shade100;
  }
}
