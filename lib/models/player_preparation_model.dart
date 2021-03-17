
import 'package:zx_tape_player/models/software_model.dart';

enum PreparationState { Converting, Ready, Error }

class PreparationModel {
  final PreparationState state;
  final String message;
  final FileModel model;

  PreparationModel(this.state, this.model, {this.message});
}