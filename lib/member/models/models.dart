import 'dart:convert';

class Members {
  final int count;
  final String next;
  final String previous;
  final List<MemberPublic> results;

  Members({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory Members.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<MemberPublic> results = list.map((i) => MemberPublic.fromJson(i)).toList();

    return Members(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}

class MemberPublic {
  final int pk;
  final String companycode;
  final String companylogo;
  final String companylogoUrl;
  final String name;
  final String address;
  final String postal;
  final String city;
  final String countryCode;
  final String tel;
  final String email;
  final bool hasBranches;

  MemberPublic({
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

  factory MemberPublic.fromJson(Map<String, dynamic> parsedJson) {

    return MemberPublic(
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
}
