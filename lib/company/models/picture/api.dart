import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:my24app/core/api/base_crud.dart';
import 'models.dart';

class PicturePublicApi extends BaseCrud<PicturePublic, PicturesPublic> {
  final String basePath = "/company/public-pictures";

  @override
  PicturePublic fromJsonDetail(Map<String, dynamic> parsedJson) {
    return PicturePublic.fromJson(parsedJson);
  }

  @override
  PicturesPublic fromJsonList(Map<String, dynamic> parsedJson) {
    return PicturesPublic.fromJson(parsedJson);
  }

  Future<String> getRandomPicture({http.Client httpClientOverride}) async {
    PicturesPublic pictures = await list(httpClientOverride: httpClientOverride);
    String memberPicture;
    if (pictures.results.length > 1) {
      int randomPos = Random().nextInt(pictures.results.length);
      memberPicture = pictures.results[randomPos].picture;
    } else if (pictures.results.length == 1) {
      memberPicture = pictures.results[0].picture;
    }

    return memberPicture;
  }
}
