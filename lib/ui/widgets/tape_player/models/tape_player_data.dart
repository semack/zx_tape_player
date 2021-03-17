
import 'package:zx_tape_player/models/software_model.dart';

enum TapePlayerState { IndexChanged, Loading, Idle, Error }

class TapePlayerData {
  final TapePlayerState state;
  final String message;
  final FileModel model;

  TapePlayerData(this.state, this.model, {this.message});
}