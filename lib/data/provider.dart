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
  List<Movie> totalMovies = [];
  List<String> waitList = [];
  bool isLoading = false;
  User? user;
  List<int> years = [];
  CollectionReference? readyRef;
  CollectionReference? waitRef;
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
      readyRef = Firestore.instance
          .collection(user_.id)
          .document("pelis")
          .collection("ready");
      waitRef = Firestore.instance
          .collection(user_.id)
          .document("pelis")
          .collection("wait");
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
    user = null;
    await sharedPreferences.clear();
  }

  void getMovies() async {
    var fullData = await readyRef!.get();
    for (Document movie in fullData) {
      var movieData = movie.map;
      movies.add(Movie.fromJson(movieData, movie.id));
      totalMovies.add(Movie.fromJson(movieData, movie.id));
    }
    var waitData = await waitRef!.get();
    for (Document movie in waitData) {
      var movieData = movie.map;
      waitList.add(movieData["title"]);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveMovie(Movie movie) async {
    try {
      var newMovie = await readyRef!.add(movie.toJson());
      movies.add(Movie.fromJson(movie.toJson(), newMovie.id));
      notifyListeners();
      return true;
    } catch (e) {
      showToast(e.toString(), backgroundColor: Colors.red);
    }
    return false;
  }

  Future<bool> saveMovieToWait(String title) async {
    try {
      await waitRef!.add({"title": title});
      waitList.add(title);
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

  void searchByData(String value) {
    List<Movie> results = [];
    var withTitle = totalMovies.where(
        (movie) => movie.title.toLowerCase().contains(value.toLowerCase()));
    var withOriginalTitle = totalMovies.where((movie) =>
        movie.originalTitle.toLowerCase().contains(value.toLowerCase()));
    var byYear = totalMovies
        .where((movie) => movie.launchDate.toString() == value)
        .toList();
    var byDirector = totalMovies
        .where((movie) =>
            movie.director.toLowerCase().contains(value.toLowerCase()))
        .toList();
    results.addAll(withTitle);
    results.addAll(withOriginalTitle);
    results.addAll(byYear);
    results.addAll(byDirector);
    movies = results;
    notifyListeners();
  }

  void searchByGender(List<String> genders_) {
    List<Movie> result = [];
    print(genders_);
    if (genders_.isNotEmpty) {
      for (String gender in genders_) {
        print(gender);
        for (Movie movie in totalMovies) {
          var contains = movie.genders.contains(gender);
          print(contains);
          if (contains) {
            result.add(movie);
          }
        }
      }
    } else {
      result = totalMovies;
    }
    movies = result;
    notifyListeners();
  }

  void resetSearch() {
    movies = totalMovies;
    notifyListeners();
  }
}
