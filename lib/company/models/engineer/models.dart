
import '../models.dart';

class EngineerProperty {
  final String? address;
  final String? postal;
  final String? city;
  final String? countryCode;
  final String? mobile;
  final int? preferredLocation;

  EngineerProperty({
    this.address,
    this.postal,
    this.city,
    this.countryCode,
    this.mobile,
    this.preferredLocation,
  });

  factory EngineerProperty.fromJson(Map<String, dynamic> parsedJson) {
    return EngineerProperty(
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
      mobile: parsedJson['mobile'],
      preferredLocation: parsedJson['preferred_location'],
    );
  }
}

class EngineerUser extends BaseUser {
  final int? id;
  final String? email;
  final String? username;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  EngineerProperty? engineer;
  final UserSick? userSick;

  EngineerUser({
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.firstName,
    this.lastName,
    this.engineer,
    this.userSick
  });

  factory EngineerUser.fromJson(Map<String, dynamic> parsedJson) {
    EngineerProperty? engineer;
    UserSick? userSick;

    if(parsedJson.containsKey('engineer') && parsedJson['engineer'] != null) {
      engineer = EngineerProperty.fromJson(parsedJson['engineer']);
    }

    if(parsedJson.containsKey('user_sick') && parsedJson['user_sick'] != null) {
      userSick = UserSick(startDate: parsedJson['user_sick']);
    }

    return EngineerUser(
      id: parsedJson['id'],
      email: parsedJson['email'],
      username: parsedJson['username'],
      fullName: parsedJson['full_name'],
      firstName: parsedJson['first_name'],
      lastName: parsedJson['last_name'],
      userSick: userSick,
      engineer: engineer,
    );
  }
}

class EngineerUsers {
  final int? count;
  final String? next;
  final String? previous;
  final List<EngineerUser>? results;

  EngineerUsers({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory EngineerUsers.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<EngineerUser> results = list.map((i) => EngineerUser.fromJson(i)).toList();

    return EngineerUsers(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}

class EngineerForSelect {
  final int? user_id;
  final String? fullNane;

  EngineerForSelect({
    this.user_id,
    this.fullNane
  });

  factory EngineerForSelect.fromJson(Map<String, dynamic> parsedJson) {
    return EngineerForSelect(
        user_id: parsedJson['user_id'],
        fullNane: parsedJson['full_name'],
    );
  }
}

class EngineersForSelect {
  final List<EngineerForSelect>? engineers;

  EngineersForSelect({
    this.engineers,
  });

  factory EngineersForSelect.fromJson(List<dynamic> parsedJson) {
    List<EngineerForSelect> results = parsedJson.map((i) => EngineerForSelect.fromJson(i)).toList();

    return EngineersForSelect(
      engineers: results
    );
  }
}
