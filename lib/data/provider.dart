import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as c;
import 'package:firedart/auth/user_gateway.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Page;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sibupel/data/movie.dart';
import 'package:firedart/firedart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as native_auth;
import 'package:cloud_firestore/cloud_firestore.dart' as native_store;

class DataProvider with ChangeNotifier {
  bool isAuth = false;
  List<Movie> movies = [];
  List<Movie> totalMovies = [];
  List<WaitMovie> waitList = [];
  bool isLoading = true;
  AdaptiveUser? user;
  List<int> years = [];
  CollectionReference? windowsReadyRef;
  native_store.CollectionReference? macReadyRef;
  CollectionReference? windowsWaitRef;
  native_store.CollectionReference? macWaitRef;
  CollectionReference? windowsSagasRef;
  native_store.CollectionReference? macSagasRef;
  late SharedPreferences sharedPreferences;
  late StreamSubscription authState;
  late FirebaseAuth windowsAuth;
  late native_auth.FirebaseAuth macAuth;
  String version = '1.0.0';

  Movie? _selectedMovie;
  Movie? get selectedMovie => _selectedMovie;
  set selectedMovie(Movie? movie) {
    _selectedMovie = movie;
    notifyListeners();
  }

  Map<String, Saga> sagas = {};

  void init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    PackageInfo info = await PackageInfo.fromPlatform();
    version = info.version;
    if (Platform.isWindows) {
      FirebaseAuth.initialize(dotenv.env["APIKEY"] ?? "", VolatileStore());
      Firestore.initialize(dotenv.env["PROJECTID"] ?? "");
      windowsAuth = FirebaseAuth.instance;
      authState = windowsAuth.signInState.listen((isSigned) async {
        isAuth = isSigned;
        if (user != null && isSigned) {
          windowsReadyRef = Firestore.instance
              .collection(user?.id ?? '')
              .document("pelis")
              .collection("ready");
          windowsWaitRef = Firestore.instance
              .collection(user?.id ?? '')
              .document("pelis")
              .collection("wait");
          windowsSagasRef = Firestore.instance
              .collection(user?.id ?? '')
              .document("pelis")
              .collection("sagas");
          getMovies();
        }
        notifyListeners();
      });
    } else {
      macAuth = native_auth.FirebaseAuth.instance;
      authState = macAuth.authStateChanges().listen((user) {
        isAuth = user != null;
        if (user != null) {
          macReadyRef = native_store.FirebaseFirestore.instance
              .collection(user.uid)
              .doc('pelis')
              .collection('ready');
          macWaitRef = native_store.FirebaseFirestore.instance
              .collection(user.uid)
              .doc('pelis')
              .collection('wait');
          macSagasRef = native_store.FirebaseFirestore.instance
              .collection(user.uid)
              .doc('pelis')
              .collection('sagas');
          getMovies();
          this.user = AdaptiveUser.mac(user);
        }
        notifyListeners();
      });
    }
    for (int i = 1920; i <= DateTime.now().year; i++) {
      years.add(i);
    }
    years = years.reversed.toList();
    await getHidedData();
  }

  void close() {
    authState.cancel();
  }

  Future<AdaptiveUser?> login(
      String email, String password, bool isSigned) async {
    AdaptiveUser? user_;
    try {
      if (Platform.isWindows) {
        var user = await windowsAuth.signIn(email, password);
        user_ = AdaptiveUser.windows(user);
        String hidedData = await hideData(email, password);
        await sharedPreferences.setString("token", hidedData);
      } else {
        await macAuth.signInWithEmailAndPassword(
            email: email, password: password);
      }
      isLoading = true;
      notifyListeners();
    } catch (e) {
      print(e);
      getLocalMovies();
      notifyListeners();
      showToast(e.toString(), backgroundColor: Colors.red);
    }
    return user_;
  }

  Future<void> signOut() async {
    if (Platform.isWindows) {
      windowsAuth.signOut();
    } else {
      macAuth.signOut();
    }
    movies.clear();
    waitList.clear();
    user = null;
    await sharedPreferences.clear();
  }

  void getMovies() async {
    getLocalMovies();
    try {
      List<Movie> totalMovies = [];
      List<WaitMovie> waitList = [];
      if (Platform.isWindows) {
        List<Document> fullData = [];
        Page<Document>? last;
        for (int i = 0; i < 10; i++) {
          last = await windowsReadyRef!
              .get(pageSize: 300, nextPageToken: last?.nextPageToken ?? '');
          fullData.addAll(last);
          if (!last.hasNextPage) break;
        }
        totalMovies = fullData.map((e) => Movie.fromJson(e.map, e.id)).toList();
        var waitData = await windowsWaitRef!.get();
        waitList = waitData
            .map((element) => WaitMovie(element.map['title'], element.id))
            .toList();
        Page<Document> sagas = await windowsSagasRef!.get();
        for (Document saga in sagas) {
          this.sagas[saga.id] = Saga.fromJson(
              saga.map,
              saga.id,
              totalMovies
                  .where((movie) => movie.sagas.contains(saga.id))
                  .toList());
        }
      } else {
        native_store.QuerySnapshot<Object?>? ready = await macReadyRef?.get();
        print(ready?.docs[0].data());
        if (ready != null) {
          totalMovies = ready.docs
              .map((e) => Movie.fromJson(e.data() as Map, e.id))
              .toList();
        }
        native_store.QuerySnapshot<Object?>? wait = await macWaitRef?.get();
        if (wait != null) {
          waitList = wait.docs
              .map((e) => WaitMovie((e.data() as Map)['title'], e.id))
              .toList();
        }
        native_store.QuerySnapshot<Object?>? sagas = await macSagasRef?.get();
        if (sagas != null) {
          for (var saga in sagas.docs) {
            this.sagas[saga.id] = Saga.fromJson(
                saga.data() as Map,
                saga.id,
                totalMovies
                    .where((movie) => movie.sagas.contains(saga.id))
                    .toList());
          }
        }
      }
      for (Movie movie in totalMovies) {
        await sharedPreferences.setString(
            "ready_${movie.id}", jsonEncode(movie.toJson()));
      }

      for (WaitMovie movie in waitList) {
        await sharedPreferences.setString("wait_${movie.id}", movie.name);
      }
      this.totalMovies = totalMovies;
      movies = totalMovies;
      this.waitList = waitList;
    } catch (e) {
      showToast('get movies: ${e.toString()}', backgroundColor: Colors.red);
    }
    isLoading = false;
    notifyListeners();
  }

  void getLocalMovies() async {
    for (String movieKey in sharedPreferences.getKeys()) {
      var encoded = sharedPreferences.getString(movieKey);
      if (encoded == null) return;
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

  Future<bool> saveMovie(Movie movie) async {
    try {
      String id = '';
      if (Platform.isWindows) {
        var movieData = await windowsReadyRef!.add(movie.toJson());
        id = movieData.id;
      } else {
        var movieData = await macReadyRef!.add(movie.toJson());
        id = movieData.id;
      }
      await sharedPreferences.setString(
          "ready_$id", jsonEncode(movie.toJson()));
      var movieToAdd = Movie.fromJson(movie.toJson(), id);
      movies.add(movieToAdd);
      movies = movies.toSet().toList();
      totalMovies.add(movieToAdd);
      totalMovies = totalMovies.toSet().toList();
      for (String saga in movie.sagas) {
        addMovieToSaga(saga, movie);
      }
      notifyListeners();
      return true;
    } catch (e) {
      showToast(e.toString(), backgroundColor: Colors.red);
    }
    return false;
  }

  Future<bool> updateMovie(Movie movie) async {
    try {
      if (Platform.isWindows) {
        await windowsReadyRef!.document(movie.id).update(movie.toJson());
      } else {
        await macReadyRef?.doc(movie.id).update(movie.toJson());
      }
      await sharedPreferences.setString(
          "ready_${movie.id}", jsonEncode(movie.toJson()));
          
      int totalIndex = totalMovies.indexWhere((old) => old.id == movie.id);
      int dataIndex = movies.indexWhere((old) => old.id == movie.id);
      List<dynamic> sagas = totalMovies[totalIndex].sagas;
      for(String saga in sagas){
        if(this.sagas[saga] != null){
          int sagaIndex = this.sagas[saga]!.movies.indexWhere((element) => element.id == movie.id);
          if(sagaIndex > -1){
            this.sagas[saga]!.movies[sagaIndex] = movie;
          }
        }
      }
      if(selectedMovie?.id == movie.id){
        selectedMovie = movie;
      }
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
      if (Platform.isWindows) {
        await windowsReadyRef!.document(id).delete();
      } else {
        await macReadyRef!.doc(id).delete();
      }
      await sharedPreferences.remove("ready_$id}");
      int totalIndex = totalMovies.indexWhere((old) => old.id == id);
      int dataIndex = movies.indexWhere((old) => old.id == id);
      List<dynamic> sagas = totalMovies[totalIndex].sagas;
      for(String saga in sagas){
        if(this.sagas[saga] != null){
          this.sagas[saga]!.movies.removeWhere((element) => element.id == id);
        }
      }
      totalMovies.removeAt(totalIndex);
      movies.removeAt(dataIndex);
      notifyListeners();
    } catch (e) {
      showToast(e.toString(), backgroundColor: Colors.red);
    }
  }

  Future<bool> saveMovieToWait(String title) async {
    try {
      var newMovie = await windowsWaitRef!.add({"title": title});
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
      await windowsWaitRef!.document(id).delete();
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
    if (genders_.isNotEmpty) {
      for (String gender in genders_) {
        for (Movie movie in totalMovies) {
          var contains = movie.genders.contains(gender);
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

  void orderMovies(OrderBy orderBy) {
    switch (orderBy) {
      case OrderBy.random:
        movies.sort((a, b) => a.id.compareTo(b.id));
        totalMovies.sort((a, b) => a.id.compareTo(b.id));
        break;
      case OrderBy.year:
        movies.sort((a, b) => a.launchDate.compareTo(b.launchDate));
        totalMovies.sort((a, b) => a.launchDate.compareTo(b.launchDate));
        break;
      case OrderBy.originalTitle:
        movies.sort((a, b) => a.originalTitle.compareTo(b.originalTitle));
        totalMovies.sort((a, b) => a.originalTitle.compareTo(b.originalTitle));
        break;
      case OrderBy.title:
        movies.sort((a, b) => a.title.compareTo(b.title));
        totalMovies.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    // moviesNavigatorKey = GlobalKey();
    notifyListeners();
  }

  Future<void> createSaga(String name, Movie movie, [String? cover]) async {
    try {
      String? id;
      if (Platform.isWindows) {
        var saga = await windowsSagasRef!.add({'name': name, 'cover': cover});
        id = saga.id;
        movie.sagas.add(id);
        await windowsReadyRef!.document(movie.id).update(movie.toJson());
      } else {
        var saga = await macSagasRef!.add({'name': name, ' cover': cover});
        id = saga.id;
        await macReadyRef!.doc(movie.id).update({
          'sagas': native_store.FieldValue.arrayUnion([id])
        });
        movie.sagas.add(id);
      }
      sagas[id] = Saga(id, name, [movie]);
      await sharedPreferences.setString(
          "ready_${movie.id}", jsonEncode(movie.toJson()));
      int totalIndex = totalMovies.indexWhere((old) => old.id == movie.id);
      int dataIndex = movies.indexWhere((old) => old.id == movie.id);
      totalMovies[totalIndex] = movie;
      movies[dataIndex] = movie;
      notifyListeners();
    } catch (e) {
      showToast(e.toString(), backgroundColor: Colors.red);
      notifyListeners();
    }
  }

  Future<bool?> addMovieToSaga(String id, Movie movie) async {
    if (sagas[id]?.movies.contains(movie) ?? false) return null;
    try {
      movie.sagas.add(id);
      if (Platform.isWindows) {
        await windowsReadyRef!.document(movie.id).update(movie.toJson());
      }else{
        await macReadyRef!.doc(movie.id).update(movie.toJson());
      }
      sagas[id]!.movies.add(movie);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class CompleteLocalData {
  List<Movie> ready;
  List<String> wait;
  CompleteLocalData(this.ready, this.wait);
}

enum OrderBy {
  random('Aleatorio'),
  year('Por año'),
  originalTitle("Título original"),
  title("Título en español");

  const OrderBy(this.label);
  final String label;
}

class AdaptiveUser {
  final String id;
  final String? displayName;
  final String? email;

  AdaptiveUser.windows(User user)
      : id = user.id,
        displayName = user.displayName,
        email = user.email;
  AdaptiveUser.mac(native_auth.User? user)
      : id = user?.uid ?? '',
        displayName = user?.displayName,
        email = user?.email;
}
