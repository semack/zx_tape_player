enum TapePlayerState { IndexChanged, Loading, Idle, Error }

class TapePlayerData {
  final TapePlayerState state;
  final String message;
  final String filePath;

  TapePlayerData(this.state, this.filePath, {this.message});
}
