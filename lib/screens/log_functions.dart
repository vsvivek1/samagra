void logFunctionInfo(String functionName, String className, String lineNumber) {
  print('Function: $functionName, Class: $className, Line: $lineNumber');
}

void logCurrentFunction() {
  final stackTrace = StackTrace.current;
  final traceLines = stackTrace.toString().split('\n');

  // Extract the relevant line containing the function information
  final functionLine = traceLines[2];

  // Use regular expressions to parse the function information
  final match =
      RegExp(r'([a-zA-Z_]+)\.([a-zA-Z_]+)\s+\(').firstMatch(functionLine);
  if (match != null) {
    final className = match.group(1);
    final functionName = match.group(2);
    final lineNumber = functionLine; //.split(':')[1];
    logFunctionInfo(functionName!, className!, lineNumber);
  }
}
