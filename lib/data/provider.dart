import 'dart:async';
import 'dart:convert';

import 'package:encrypt/encrypt.dart' as c;
import 'package:firedart/auth/user_gateway.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sibupel/data/movie.dart';
import 'package:firedart/firedart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataProvider with ChangeNotifier {
  bool isAuth = false;
  List<Movie> movies = [];
  List<String> waitList = [];
  bool isLoading = false;
  User? user;
  List<int> years = [];
  CollectionReference? ref;
  late SharedPreferences sharedPreferences;
  late StreamSubscription<bool> authState;
  late FirebaseAuth auth;

  void init() async {
    FirebaseAuth.initialize(dotenv.env["APIKEY"] ?? "", VolatileStore());
    Firestore.initialize(dotenv.env["PROJECTID"] ?? "");
    auth = FirebaseAuth.instance;
    sharedPreferences = await SharedPreferences.getInstance();
    authState = auth.signInState.listen((isSigned) async {
      isAuth = isSigned;
      print(isSigned);
      if (isSigned) {
        ref = Firestore.instance.collection(user?.id ?? "");
      }
      notifyListeners();
    });
    for (int i = 1920; i <= DateTime.now().year; i++) {
      years.add(i);
    }
    years = years.reversed.toList();
    await getHidedData();
  }

  void close() {
    authState.cancel();
  }

  Future<User?> login(String email, String password, bool isSigned) async {
    User? user_;
    try {
      user_ = await auth.signIn(email, password);
      user = user_;
      print(user_.toMap());
      if (!isSigned) {
        String hidedData = await hideData(email, password);
        await sharedPreferences.setString("token", hidedData);
      }
      ref = Firestore.instance.collection(user_.id);
      isLoading = true;
      notifyListeners();
      getMovies();
    } catch (e) {
      print(e);
      showToast(e.toString(), backgroundColor: Colors.red);
    }
    return user_;
  }

  Future<void> signOut() async {
    auth.signOut();
    movies.clear();
    waitList.clear();
    await sharedPreferences.clear();
  }

  void getMovies() async {
    var data = await ref!.get();
    for (Document movie in data) {
      var movieData = movie.map;
      movies.add(Movie.fromJson(movieData));
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveMovie(Movie movie) async {
    try {
      await ref!.add(movie.toJson());
      movies.add(movie);
      notifyListeners();
      return true;
    } catch (e) {
      showToast(e.toString(), backgroundColor: Colors.red);
    }
    return false;
  }

  Future<String> hideData(String m, String p) async {
    String data = jsonEncode({
      "m": m.split("@").reversed.join("|"),
      "p": p.split("").reversed.join("")
    });
    var k = c.Key.fromUtf8("S1bup3lP4ssw0rd!Fr0mTh3D3vel()p3");
    var enc = c.Encrypter(c.AES(k));
    String r = enc.encrypt(data, iv: c.IV.fromLength(16)).base64;
    return r;
  }

  Future<void> getHidedData() async {
    String d = sharedPreferences.getString("token") ?? "";
    if (d.isNotEmpty) {
      var k = c.Key.fromUtf8("S1bup3lP4ssw0rd!Fr0mTh3D3vel()p3");
      var enc = c.Encrypter(c.AES(k));
      String r =
          enc.decrypt(c.Encrypted.fromBase64(d), iv: c.IV.fromLength(16));
      var data = jsonDecode(r);
      String m = data["m"] ?? "";
      String p = data["p"] ?? "";
      await login(m.split("|").reversed.join("@"),
          p.split("").reversed.join(""), false);
    }
  }
}
