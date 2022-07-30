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
  List<WaitMovie> waitList = [];
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
      getLocalMovies();
      notifyListeners();
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
    getLocalMovies();
    var fullData = await readyRef!.get();
    for (Document movie in fullData) {
      bool isDownloaded =
          totalMovies.indexWhere((element) => element.id == movie.id) > -1
              ? true
              : false;
      if (!isDownloaded) {
        var movieData = movie.map;
        await sharedPreferences.setString(
            "ready_${movie.id}", jsonEncode(movieData));
        movies.add(Movie.fromJson(movieData, movie.id));
        totalMovies.add(Movie.fromJson(movieData, movie.id));
      }
    }
    var waitData = await waitRef!.get();
    for (Document movie in waitData) {
      bool isDownloaded =
          waitList.indexWhere((element) => element.id == movie.id) > -1
              ? true
              : false;
      if (!isDownloaded) {
        var movieData = movie.map;
        await sharedPreferences.setString(
            "wait_${movie.id}", movieData["title"]);
        waitList.add(WaitMovie(movieData["title"], movie.id));
      }
    }
    isLoading = false;
    notifyListeners();
  }

  void getLocalMovies() async {
    for (String movieKey in sharedPreferences.getKeys()) {
      var encoded = sharedPreferences.getString(movieKey);
      if (encoded != null) {
        if (movieKey.contains("ready_")) {
          Movie movie = Movie.fromJson(
              jsonDecode(encoded), movieKey.replaceFirst("ready_", ""));
          totalMovies.add(movie);
          movies.add(movie);
        } else {
          WaitMovie movie =
              WaitMovie(encoded, movieKey.replaceFirst("wait_", ""));
          waitList.add(movie);
          waitList = waitList.toSet().toList();
        }
      }
    }
  }

  Future<bool> saveMovie(Movie movie) async {
    try {
      var newMovie = await readyRef!.add(movie.toJson());
      await sharedPreferences.setString(
          "ready_${newMovie.id}", jsonEncode(movie.toJson()));
      var movieToAdd = Movie.fromJson(movie.toJson(), newMovie.id);
      movies.add(movieToAdd);
      movies = movies.toSet().toList();
      totalMovies.add(movieToAdd);
      totalMovies = totalMovies.toSet().toList();
      notifyListeners();
      return true;
    } catch (e) {
      showToast(e.toString(), backgroundColor: Colors.red);
    }
    return false;
  }

  Future<bool> updateMovie(Movie movie) async {
    try {
      await readyRef!.document(movie.id).update(movie.toJson());
      await sharedPreferences.setString(
          "ready_${movie.id}", jsonEncode(movie.toJson()));
      int totalIndex = totalMovies.indexWhere((old) => old.id == movie.id);
      int dataIndex = movies.indexWhere((old) => old.id == movie.id);
      totalMovies[totalIndex] = movie;
      movies[dataIndex] = movie;
      notifyListeners();
      return true;
    } catch (e) {
      showToast(e.toString(), backgroundColor: Colors.red);
    }
    return false;
  }

  Future<void> deleteMovie(String id) async {
    try {
      await readyRef!.document(id).delete();
      await sharedPreferences.remove("ready_$id}");
      int totalIndex = totalMovies.indexWhere((old) => old.id == id);
      int dataIndex = movies.indexWhere((old) => old.id == id);
      totalMovies.removeAt(totalIndex);
      movies.removeAt(dataIndex);
      notifyListeners();
    } catch (e) {
      showToast(e.toString(), backgroundColor: Colors.red);
    }
  }

  Future<bool> saveMovieToWait(String title) async {
    try {
      var newMovie = await waitRef!.add({"title": title});
      await sharedPreferences.setString("wait_${newMovie.id}", title);
      waitList.add(WaitMovie(title, newMovie.id));
      notifyListeners();
      return true;
    } catch (e) {
      showToast(e.toString(), backgroundColor: Colors.red);
    }
    return false;
  }

  Future<void> deleteWaitMovie(String id) async {
    try {
      await waitRef!.document(id).delete();
      await sharedPreferences.remove("wait_$id");
      int index = waitList.indexWhere((element) => element.id == id);
      waitList.removeAt(index);
      notifyListeners();
    } catch (e) {
      showToast(e.toString(), backgroundColor: Colors.red);
    }
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
      isAuth = true;
      await login(m.split("|").reversed.join("@"),
          p.split("").reversed.join(""), false);
    }
  }

  void searchByData(String value) {
    List<Movie> results = [];
    var value_ = value.toLowerCase().replaceAll(RegExp(r'(-|\s|:)'), "");
    var withTitle = totalMovies.where((movie) {
      var title = movie.title.toLowerCase().replaceAll(RegExp(r'(-|\s|:)'), "");
      return title.contains(value_);
    });
    var withOriginalTitle = totalMovies.where((movie) {
      var title =
          movie.originalTitle.toLowerCase().replaceAll(RegExp(r'(-|\s|:)'), "");
      return title.toLowerCase().contains(value_);
    });
    var byYear = totalMovies
        .where((movie) => movie.launchDate.toString() == value)
        .toList();
    var byDirector = totalMovies
        .where((movie) => movie.director.toLowerCase().contains(value))
        .toList();
    results.addAll(withTitle);
    results.addAll(withOriginalTitle);
    results.addAll(byYear);
    results.addAll(byDirector);
    movies = results.toSet().toList();
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
    movies = result.toSet().toList();
    notifyListeners();
  }

  void resetSearch() {
    movies = totalMovies;
    notifyListeners();
  }
}
