import 'package:my24_flutter_core/models/base_models.dart';

class PrivateMembers extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<PrivateMember>? results;

  PrivateMembers({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory PrivateMembers.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<PrivateMember> results = list.map((i) => PrivateMember.fromJson(i)).toList();

    return PrivateMembers(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}

class PrivateMember extends BaseModel {
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
  final Map<String, dynamic>? settings;

  PrivateMember({
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
    this.hasBranches,
    this.settings
  });

  factory PrivateMember.fromJson(Map<String, dynamic> parsedJson) {
    return PrivateMember(
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
      settings: parsedJson['settings'],
    );
  }

  @override
  String toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
