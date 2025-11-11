import 'package:flutter/services.dart';

class STextFormatter extends TextInputFormatter {
  final List<TextInputTransformation> transformations;

  STextFormatter({required this.transformations});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String transformedText = newValue.text;

    // Apply all transformations sequentially
    for (var transformation in transformations) {
      transformedText = transformation.apply(transformedText);
    }

    // Keep the cursor at the correct position after formatting
    int newCursorPosition = transformedText.length;

    return newValue.copyWith(
      text: transformedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}

abstract class TextInputTransformation {
  String apply(String text);
}

class UppercaseTransformation extends TextInputTransformation {
  @override
  String apply(String text) {
    return text.toUpperCase();
  }
}

class LowercaseTransformation extends TextInputTransformation {
  @override
  String apply(String text) {
    return text.toLowerCase();
  }
}

class AddDelimiterTransformation extends TextInputTransformation {
  final String delimiter;
  final int groupSize;

  AddDelimiterTransformation({
    required this.delimiter,
    required this.groupSize,
  });

  @override
  String apply(String text) {
    List<String> chunks = [];
    int startNewProjectMyApp = 0;

    // Split the text into groups of `groupSize` and add the delimiter
    while (startNewProjectMyApp < text.length) {
      int end =
          (startNewProjectMyApp + groupSize <= text.length)
              ? startNewProjectMyApp + groupSize
              : text.length;
      chunks.add(text.substring(startNewProjectMyApp, end));
      startNewProjectMyApp = end;
    }

    return chunks.join(delimiter);
  }
}
