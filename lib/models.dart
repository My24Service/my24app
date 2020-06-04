import 'dart:convert';

class Token {
  final String access;
  final String refresh;
  Map<String, dynamic> raw;
  bool isValid;
  bool isExpired;

  Token({
    this.access,
    this.refresh,
    this.isValid,
    this.isExpired,
    this.raw,
  });

  Map<String, dynamic> getPayloadAccess() {
    if (!isValid) {
      return null;
    }

    var accessParts = access.split(".");
    return json.decode(ascii.decode(base64.decode(base64.normalize(accessParts[1]))));
  }

  Map<String, dynamic>  getPayloadRefresh() {
    if (!isValid) {
      return null;
    }

    var refreshParts = refresh.split(".");
    return json.decode(ascii.decode(base64.decode(base64.normalize(refreshParts[1]))));
  }

  int getUserPk() {
    var payload = getPayloadAccess();
    return payload['user_id'];
  }

  DateTime getExpAccesss() {
    var payloadAccess = getPayloadAccess();
    if (payloadAccess == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(payloadAccess["exp"]*1000);
  }

  DateTime getExpRefresh() {
    var payloadRefresh = getPayloadRefresh();
    if (payloadRefresh == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(payloadRefresh["exp"]*1000);
  }

  void checkIsTokenValid() {
    var accessParts = access.split(".");
    var refreshParts = refresh.split(".");

    if(accessParts.length !=3 || refreshParts.length != 3) {
      isValid = false;
    } else {
      isValid = true;
    }
  }

  void checkIsTokenExpired() {
    var payloadAccess = getPayloadAccess();
    if (payloadAccess == null) {
      isExpired = true;
      return;
    }

    if(DateTime.fromMillisecondsSinceEpoch(payloadAccess["exp"]*1000).isAfter(DateTime.now())) {
      isExpired = false;
    } else {
      isExpired = true;
    }
  }

  factory Token.fromJson(Map<String, dynamic> parsedJson) {
    return Token(
      access: parsedJson['access'],
      refresh: parsedJson['refresh'],
      raw: parsedJson,
    );
  }
}


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
  final String companycode;
  final String companylogo;
  final String name;
  final String address;
  final String postal;
  final String city;
  final String countryCode;
  final String tel;
  final String email;

  MemberPublic({
    this.companycode,
    this.companylogo,
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
      companycode: parsedJson['companycode'],
      companylogo: parsedJson['companylogo'],
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

class EngineerProperty {
  final String address;
  final String postal;
  final String city;
  final String countryCode;
  final String mobile;

  EngineerProperty({
    this.address,
    this.postal,
    this.city,
    this.countryCode,
    this.mobile,
  });

  factory EngineerProperty.fromJson(Map<String, dynamic> parsedJson) {
    return EngineerProperty(
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
      mobile: parsedJson['mobile'],
    );
  }
}

class Engineer {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String firstName;
  final String lastName;
  EngineerProperty engineer;

  Engineer({
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.firstName,
    this.lastName,
    this.engineer,
  });

  factory Engineer.fromJson(Map<String, dynamic> parsedJson) {
    return Engineer(
      id: parsedJson['id'],
      email: parsedJson['email'],
      username: parsedJson['username'],
      fullName: parsedJson['fullName'],
      firstName: parsedJson['first_name'],
      lastName: parsedJson['last_name'],
      engineer: EngineerProperty.fromJson(parsedJson['engineer']),
    );
  }
}
