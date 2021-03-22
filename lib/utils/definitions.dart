class Definitions {
  Definitions._();

  static const appTitle = 'ZX Tape Player';
  static const letterType = 'LETTER';
  static const pageSize = 30;
  static const supportedTapeExtensions = <String>['tap', 'tzx'];
  static const tapeDir = '%s/tapes';
  static const wafFilePath = '%s/%s.wav';
  static const wavFrequency = 44100;
  static const wavCacheLimitMb = 100;
  static const optimalVolumeIOS = 1.00;
  static const optimalVolumeAndroid = 0.75;
}
