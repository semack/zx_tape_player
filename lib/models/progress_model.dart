import 'package:zx_tape_player/models/software_model.dart';

class ProgressModel {
  final double percent;
  final FileModel fileModel;

  ProgressModel(this.fileModel, this.percent);
}