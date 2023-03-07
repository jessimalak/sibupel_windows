class Movie {
  String title;
  String originalTitle;
  String director;
  List<dynamic> genders;
  int launchDate;
  bool subtitles;
  String duration;
  String folder;
  String format;
  String language;
  String? poster;
  String id;
  List<dynamic> sagas;

  Movie(this.title, this.originalTitle, this.director, this.genders, this.launchDate, this.duration, this.subtitles, this.folder,
      this.format, this.language, this.poster, this.sagas, this.id);

  Movie.fromJson(Map data, String id_)
      : title = data["title"],
        originalTitle = data["originalTitle"],
        director = data["director"],
        genders = data["genders"],
        launchDate = data["launchDate"],
        subtitles = data["subtitles"],
        folder = data["folder"],
        duration = data["duration"],
        format = data["format"],
        language = data["language"],
        poster = data["poster"],
        sagas = data["sagas"] ?? [],
        id = id_;

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "originalTitle": originalTitle,
      "director": director,
      "genders": genders,
      "launchDate": launchDate,
      "subtitles": subtitles,
      "folder": folder,
      "duration": duration,
      "format": format,
      "language": language,
      "poster": poster,
      "sagas": sagas
    };
  }
}

class WaitMovie {
  String name;
  String id;

  WaitMovie(this.name, this.id);
}

List<String> formats = ["avi", "mp4", "mkv"];

List<Map<String, String>> genders = [
  {"name": "Terror", "emoji": "😱"},
  {"name": "Comedia", "emoji": "😂"},
  {"name": "Musical", "emoji": "🎶"},
  {"name": "Acción", "emoji": "🔥"},
  {"name": "Slasher", "emoji": "🔪"},
  {"name": "Fantasia", "emoji": "🦄"},
  {"name": "Ciencia Ficción", "emoji": "👾"},
  {"name": "Superheroes", "emoji": "🦹🏻‍♀️"},
  {"name": "Romance", "emoji": "💜"},
  {"name": "Animación", "emoji": "🖌️"},
  {"name": "Drama", "emoji": "😥"},
];

enum SearchField { title, director, year }

class Saga {
  String id;
  String name;
  List<Movie> movies;
  String? cover;

  Saga(this.id, this.name, this.movies, [this.cover]);
  Saga.fromJson(Map data, this.id, this.movies)
      : name = data['name'],
        cover = data['cover'];
}
