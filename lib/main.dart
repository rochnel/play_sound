import 'dart:async';
import 'dart:wasm';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:com/musique.dart';
import 'package:audioplayer/audioplayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'play song',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'play song'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Musique> maListeDeMusique = [
    new Musique('je suis dans le Tieks', 'Damso', 'assets/song1.jpg', 'https://cf-hls-media.sndcdn.com/media/318901/478561/QPQOsgphEdC8.128.mp3?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiKjovL2NmLWhscy1tZWRpYS5zbmRjZG4uY29tL21lZGlhLyovKi9RUFFPc2dwaEVkQzguMTI4Lm1wMyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTU5MTU5NjczOX19fV19&Signature=Za50fUwxihgE7LZeMYQGYKZGLhJ~mklExphi2a8kGxpnppGfZZA26tfP39lLx7BTQinqGNriR-hgplmQewYMgLjshHt64DFiLYX-5OTBloKccAlJawlJvNLKx1XqdgVLCCnzNZ1TEwFqUhIBD-A4fl6tuRRF-iFW27-exH1F8mYsm68iG35jAqBFqXnDd2vyRPzwMB2UiUFxjIqchWkabGZZLJEK9aGRs2nX8uwTRNkBX0LcINCG7cV5x~TfKvFuOWp02cC6UI~8HZGQvnsBf2xFoM~Mji-kiwnsflU5p-IUDuDk0dpFXrGQkswx39pBHCgdeLte2Ej~2ussjwXV7Q__&Key-Pair-Id=APKAI6TU7MMXM5DG6EPQ'),
    new Musique('BAD', 'XXXTENTACTION', 'assets/song2.jpg', 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3'),

  ];
  Musique maMusiqueActuelle;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 10);
  int index = 0;
  PlayerSate satus = PlayerSate.stopped;
  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription sateSubscription;
  @override
  void initState(){
    super.initState();
    maMusiqueActuelle = maListeDeMusique[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[800],
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 10.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 2.5,
                child: new Image.asset(maMusiqueActuelle.imagePath),
              ),
            ),
            texteAvecStyle(maMusiqueActuelle.titre, 1.5),
            texteAvecStyle(maMusiqueActuelle.artiste, 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                bouton((satus == PlayerSate.playing) ?Icons.pause: Icons.play_arrow, 45.0, (satus == PlayerSate.playing) ? ActionMusic.pause: ActionMusic.pay),
                bouton(Icons.fast_forward, 30.0, ActionMusic.forward),

              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                texteAvecStyle(formDuration(position), 0.8),
                texteAvecStyle(formDuration(duree), 0.8),
              ],
            ),
           new Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged:(double d){
                  setState(() {
                   audioPlayer.seek(d);
                  });
                }
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  IconButton bouton(IconData icone, double taille, ActionMusic action){
    return new IconButton(
        iconSize: taille,
        color: Colors.white,
        icon: new Icon(icone),
        onPressed:(){
          switch(action){
            case ActionMusic.pay:
              play();
              break;
            case ActionMusic.pause:
              pause();
              break;
            case ActionMusic.forward:
            forward();
              break;
            case ActionMusic.rewind:
              rewind();
              break;
          }
        }
    );
  }
  Text texteAvecStyle(String data, double scale){
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontStyle: FontStyle.italic
      ),
    );
  }
  void configurationAudioPlayer(){
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
        (pos) => setState(() => position = pos)
    );
    sateSubscription = audioPlayer.onAudioPositionChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          satus = PlayerSate.stopped;
        });
      }
    },  onError: (message){
      print('erreur: $message');
      setState(() {
        satus = PlayerSate.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    }
    );
  }
  Future play() async {
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    setState(() {
      satus = PlayerSate.playing;
    });
  }
  Future pause() async{
    await audioPlayer.pause();
    setState(() {
      satus = PlayerSate.paused;
    });
  }
  void forward(){
    if(index == maListeDeMusique.length - 1){
      index = 0;
    } else{
      index++;
    }
    maMusiqueActuelle = maListeDeMusique[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }
  void rewind(){
    if(position > Duration(seconds: 3)){
      audioPlayer.seek(0.0);
    } else{
      if (index == 0){
        index = maListeDeMusique.length - 1;
      }else{
        index--;
      }
      maMusiqueActuelle = maListeDeMusique[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }
  String formDuration(Duration duree){
    print(duree);
    return duree.toString().split('.').first;
  }
}
enum ActionMusic{
  pay,
  pause,
  rewind,
  forward
}
enum PlayerSate{
  playing,
  stopped,
  paused,
}
