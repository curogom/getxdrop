import 'dart:io';

import 'package:getxdrop_cli/getxdrop_cli.dart';

Future<void> main(List<String> arguments) async {
  final exitCodeValue = await GetXDropCli().run(arguments);
  exit(exitCodeValue);
}
