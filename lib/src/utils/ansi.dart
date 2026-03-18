class Ansi {
  static const reset = '\x1B[0m';

  static const redC = '\x1B[31m';
  static const greenC = '\x1B[32m';
  static const yellowC = '\x1B[33m';
  static const blueC = '\x1B[34m';
  static const cyanC = '\x1B[36m';
  static const brightCyanC = '\x1B[96m';
  static const magentaC = '\x1B[35m';

  static String _wrap(String code, String text) => '$code$text$reset';

  static String green(String text) => _wrap(greenC, text);
  static String red(String text) => _wrap(redC, text);
  static String yellow(String text) => _wrap(yellowC, text);
  static String blue(String text) => _wrap(blueC, text);
  static String cyan(String text) => _wrap(cyanC, text);
  static String brightCyan(String text) => _wrap(brightCyanC, text);
  static String magenta(String text) => _wrap(magentaC, text);
}
