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
    );
  }
}

class PicturePublic {
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
}

class PicturesPublic {
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

class MemberDetailData {
  final bool isLoggedIn;
  final String submodel;
  final MemberPublic member;

  MemberDetailData({
    this.isLoggedIn,
    this.submodel,
    this.member,
  });
}
