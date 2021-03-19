import 'dart:async';
import 'dart:io';

import 'package:zx_tape_player/services/backend_service.dart';

class ConverterComputationData {
  final String filePath;
  final bool isRemote;
  final File file;
  final BackendService backendService;
  final StreamController<dynamic> controller;

  ConverterComputationData(this.filePath, this.isRemote, this.file,
      this.backendService, this.controller);
}
