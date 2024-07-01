import 'dart:math';

import 'package:game_piano_tiles_2_app/provider/game_state.dart';

class Note {
  final int orderNumber;
  final int line;
  NoteState state = NoteState.ready;

  Note(this.orderNumber, this.line);
}
