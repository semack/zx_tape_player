import 'package:zx_tape_player/models/software_model.dart';

class LoadingProgressData {
  final double percent;
  final FileModel fileModel;

  LoadingProgressData(this.fileModel, this.percent);
}
