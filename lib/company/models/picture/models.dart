import 'package:my24app/core/models/base_models.dart';

class PicturePublic extends BaseModel {
  final String picture;
  final String name;

  PicturePublic({
    this.picture,
    this.name,
  });

  factory PicturePublic.fromJson(Map<String, dynamic> parsedJson) {

    return PicturePublic(
      picture: parsedJson['picture'],
      name: parsedJson['name'],
    );
  }

  @override
  String toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class PicturesPublic extends BaseModelPagination {
  final int count;
  final String next;
  final String previous;
  final List<PicturePublic> results;

  PicturesPublic({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory PicturesPublic.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<PicturePublic> results = list.map((i) => PicturePublic.fromJson(i)).toList();

    return PicturesPublic(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}
