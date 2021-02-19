enum PlayerArgsTypeEnum { file, network }

class PlayerArgs {
  final PlayerArgsTypeEnum type;
  final String id;
  final String title;
  PlayerArgs(this.type, this.id, this.title);
}
