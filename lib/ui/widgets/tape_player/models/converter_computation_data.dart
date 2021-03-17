import 'dart:async';
import 'dart:io';

import 'package:zx_tape_player/models/software_model.dart';
import 'package:zx_tape_player/services/backend_service.dart';

class ConverterComputationData {
  final FileModel fileModel;
  final File file;
  final BackendService backendService;
  final StreamController<dynamic> controller;

  ConverterComputationData(
      this.fileModel, this.file, this.backendService, this.controller);
}