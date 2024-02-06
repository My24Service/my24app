import 'package:my24_flutter_core/models/base_models.dart';

class Members extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<Member>? results;

  Members({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Members.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<Member> results = list.map((i) => Member.fromJson(i)).toList();

    return Members(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}

class Member extends BaseModel {
  final int? pk;
  final String? companycode;
  final String? companylogo;
  final String? companylogoUrl;
  final String? name;
  final String? address;
  final String? postal;
  final String? city;
  final String? countryCode;
  final String? tel;
  final String? email;
  final bool? hasBranches;

  Member({
    this.pk,
    this.companycode,
    this.companylogo,
    this.companylogoUrl,
    this.name,
    this.address,
    this.postal,
    this.city,
    this.countryCode,
    this.tel,
    this.email,
    this.hasBranches
  });

  factory Member.fromJson(Map<String, dynamic> parsedJson) {
    return Member(
      pk: parsedJson['id'],
      companycode: parsedJson['companycode'],
      companylogo: parsedJson['companylogo'],
      companylogoUrl: parsedJson['companylogo_url'],
      name: parsedJson['name'],
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
      tel: parsedJson['tel'],
      email: parsedJson['email'],
      hasBranches: parsedJson['has_branches'],
    );
  }

  @override
  String toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
