class CliOptions {
  final String input;
  final bool append;
  final bool overwrite;

  CliOptions({
    required this.input,
    required this.append,
    required this.overwrite,
  });

  factory CliOptions.fromArgs(List<String> args) {
    final overwrite = args.contains('--overwrite');
    final append = args.contains('--append');

    return CliOptions(
      input: args.first,
      append: append || !overwrite, // ✅ centralized logic
      overwrite: overwrite,
    );
  }
}
