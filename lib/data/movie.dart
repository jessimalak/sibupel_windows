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

  Movie(
      this.title,
      this.originalTitle,
      this.director,
      this.genders,
      this.launchDate,
      this.duration,
      this.subtitles,
      this.folder,
      this.format,
      this.language, this.poster);

  Movie.fromJson(Map<String, dynamic> data)
      : title = data["title"],
        originalTitle = data["originalTitle"],
        director = data["director"],
        genders = data["genders"],
        launchDate = data["launchDate"],
        subtitles = data["subtitles"],
        folder = data["folder"],
        duration = data["duration"],
        format = data["format"],
        language = data["language"], poster = data["poster"];

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
      "poster": poster
    };
  }
}

List<String> formats = ["avi", "mp4", "mkv"];

List<Map<String, String>> genders = [{"name": "Terror", "icon": "😱"}];