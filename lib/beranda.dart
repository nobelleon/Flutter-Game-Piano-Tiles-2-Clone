import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';

import 'model/node_model.dart';
import 'provider/game_state.dart';
import 'provider/mission_provider.dart';
import 'screen/widgets/line.dart';
import 'screen/widgets/line_divider.dart';

class Beranda extends StatefulWidget {
  const Beranda({Key key}) : super(key: key);

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> with SingleTickerProviderStateMixin {
  List<Note> notes = mission();
  AudioCache player = new AudioCache();
  AnimationController animationController;
  int currentNoteIndex = 0;
  int points = 0;
  bool hasStarted = false;
  bool isPlaying = true;
  NoteState state;
  int time = 6000;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 0));
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying) {
        if (notes[currentNoteIndex].state != NoteState.tapped) {
          //game over
          setState(() {
            isPlaying = false;
            notes[currentNoteIndex].state = NoteState.missed;
          });
          animationController.reverse().then((_) => _showFinishDialog());
        } else if (currentNoteIndex == notes.length - 5) {
          //song finished
          _showFinishDialog();
        } else {
          setState(() => ++currentNoteIndex);
          animationController.forward(from: 0);
        }
      }
    });
    animationController.forward(from: -1);
  }

  void _onTap(Note note) {
    bool areAllPreviousTapped = notes
        .sublist(0, note.orderNumber)
        .every((n) => n.state == NoteState.tapped);

    if (areAllPreviousTapped) {
      if (!hasStarted) {
        setState(() => hasStarted = true);
        animationController.forward();
      }
      _playNote(note);
      setState(() {
        note.state = NoteState.tapped;
        ++points;
        if (points == 10) {
          // kecepatan sangat lambat
          animationController.duration = Duration(milliseconds: 700);
        } else if (points == 15) {
          // kecepatan lambat
          animationController.duration = Duration(milliseconds: 500);
        } else if (points == 30) {
          // kecepatan sedang
          animationController.duration = Duration(milliseconds: 400);
        } else if (points == 40) {
          // kecepatan cepat
          animationController.duration = Duration(milliseconds: 200);
        } else if (points == 50) {
          // kecepatan sangat cepat
          animationController.duration = Duration(milliseconds: 90);
        }
      });
    }
  }

  _playNote(Note note) {
    switch (note.line) {
      case 0:
        player.play('a.wav');
        return;
      case 1:
        player.play('b.wav');
        return;
      case 2:
        player.play('c.wav');
        return;
      case 3:
        player.play('d.wav');
        return;
    }
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              "assets/background.gif",
              fit: BoxFit.cover,
            ),
          ),
          Row(
            children: <Widget>[
              _drawLine(0),
              LineDivider(),
              _drawLine(1),
              LineDivider(),
              _drawLine(2),
              LineDivider(),
              _drawLine(3),
            ],
          ),
          _drawPoints(),
          _drawCompleteTile()
        ],
      ),
    );
  }

  //-------------
  // Piano Tiles
  //-------------
  _drawLine(int lineNumber) {
    return Expanded(
      child: Line(
        lineNumber: lineNumber,
        currentNotes: notes.sublist(currentNoteIndex, currentNoteIndex + 5),
        animation: animationController,
        onTileTap: _onTap,
      ),
    );
  }

  //---------
  // Points
  //---------
  _drawPoints() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Text(
          "$points",
          style: TextStyle(color: Colors.red, fontSize: 60),
        ),
      ),
    );
  }

  //----------------------------
  // Bintang & Garis Horizontal
  //----------------------------
  Widget _drawCompleteTile() {
    return Positioned(
      top: 25,
      right: 20,
      left: 28,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _tileWidget(Icons.star,
                color: points >= 10 ? Colors.amber : Colors.white),
            _tileHorizontalLine(
                points >= 10 ? Colors.amber : Colors.amber[200]),
            _tileWidget(Icons.star,
                color: points >= 20 ? Colors.amber : Colors.white),
            _tileHorizontalLine(
                points >= 30 ? Colors.amber : Colors.amber[200]),
            _tileWidget(Icons.star,
                color: points >= 40 ? Colors.amber : Colors.white),
            _tileHorizontalLine(
                points >= 50 ? Colors.amber : Colors.amber[200]),
            _tileWidget(Icons.star,
                color: points >= 51 ? Colors.amber : Colors.white),
          ],
        ),
      ),
    );
  }

  _tileWidget(IconData icon, {Color color}) {
    return Container(
      child: Icon(
        icon,
        color: color,
      ),
    );
  }

  _tileHorizontalLine(Color color) {
    return Container(
      width: 80,
      height: 4,
      color: color,
    );
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //-------------
                // Tombol Play
                //-------------
                Container(
                  height: 100,
                  width: 100,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(150)),
                  ),
                  child: const Icon(Icons.play_arrow, size: 50),
                ),
                const SizedBox(
                  height: 10,
                ),
                //-------
                // Score
                //-------
                Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(150)),
                  ),
                  child: Text(
                    "Score: $points",
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                _startWidget(), // Score Stars
              ],
            ),
          ),
        );
      },
    ).then((_) => _restart());
  }

  //--------------
  // Score Stars
  //--------------
  Widget _startWidget() {
    if (points >= 10 && points < 20)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
          Icon(
            Icons.star,
            color: Colors.white,
          ),
          Icon(
            Icons.star,
            color: Colors.white,
          ),
          Icon(
            Icons.star,
            color: Colors.white,
          ),
        ],
      );
    else if (points >= 20 && points < 30)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
          Icon(
            Icons.star,
            color: Colors.white,
          ),
          Icon(
            Icons.star,
            color: Colors.white,
          ),
        ],
      );
    else if (points >= 30 && points < 40)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
          Icon(
            Icons.star,
            color: Colors.white,
          ),
        ],
      );
    else if (points >= 40 && points <= 50)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
          Icon(
            Icons.star,
            color: Colors.white,
          ),
        ],
      );
    else if (points >= 51)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
          Icon(
            Icons.star,
            color: Colors.purple,
          ),
        ],
      );
    else
      return Container();
  }

  void _restart() {
    setState(() {
      hasStarted = false;
      isPlaying = true;
      notes = mission();
      points = 0;
      currentNoteIndex = 0;
      animationController.duration = const Duration(milliseconds: 1000);
    });
    animationController.reset();
  }
}
