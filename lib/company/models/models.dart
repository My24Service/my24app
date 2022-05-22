import 'package:latlong2/latlong.dart';
import 'package:my24app/customer/models/models.dart';

import '../../order/models/models.dart';

class MinimalUser {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String firstName;
  final String lastName;

  MinimalUser({
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.firstName,
    this.lastName,
  });

  factory MinimalUser.fromJson(Map<String, dynamic> parsedJson) {
    return MinimalUser(
      id: parsedJson['pk'],
      email: parsedJson['email'],
      username: parsedJson['username'],
      fullName: parsedJson['full_name'],
      firstName: parsedJson['first_name'],
      lastName: parsedJson['last_name'],
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

class EngineerUser {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String firstName;
  final String lastName;
  EngineerProperty engineer;

  EngineerUser({
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.firstName,
    this.lastName,
    this.engineer,
  });

  factory EngineerUser.fromJson(Map<String, dynamic> parsedJson) {
    EngineerProperty engineer;

    if(parsedJson.containsKey('engineer') && parsedJson['engineer'] != null) {
      engineer = EngineerProperty.fromJson(parsedJson['engineer']);
    }

    return EngineerUser(
      id: parsedJson['id'],
      email: parsedJson['email'],
      username: parsedJson['username'],
      fullName: parsedJson['full_name'],
      firstName: parsedJson['first_name'],
      lastName: parsedJson['last_name'],
      engineer: engineer,
    );
  }
}

class EngineerUsers {
  final int count;
  final String next;
  final String previous;
  final List<EngineerUser> results;

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

class CustomerProperty {
  final int customer;

  CustomerProperty({
    this.customer,
  });

  factory CustomerProperty.fromJson(Map<String, dynamic> parsedJson) {
    return CustomerProperty(
      customer: parsedJson['customer'],
    );
  }
}

class CustomerUser {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String firstName;
  final String lastName;
  final CustomerProperty customer;
  final Customer customerDetails;

  CustomerUser({
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.firstName,
    this.lastName,
    this.customer,
    this.customerDetails,
  });

  factory CustomerUser.fromJson(Map<String, dynamic> parsedJson) {
    return CustomerUser(
      id: parsedJson['id'],
      email: parsedJson['email'],
      username: parsedJson['username'],
      fullName: parsedJson['fullName'],
      firstName: parsedJson['first_name'],
      lastName: parsedJson['last_name'],
      customer: CustomerProperty.fromJson(parsedJson['customer_user']),
      customerDetails: Customer.fromJson(parsedJson['customer_details'])
    );
  }
}

class PlanningUser {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String firstName;
  final String lastName;

  PlanningUser({
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.firstName,
    this.lastName,
  });

  factory PlanningUser.fromJson(Map<String, dynamic> parsedJson) {
    return PlanningUser(
        id: parsedJson['id'],
        email: parsedJson['email'],
        username: parsedJson['username'],
        fullName: parsedJson['fullName'],
        firstName: parsedJson['first_name'],
        lastName: parsedJson['last_name'],
    );
  }
}

class SalesUser {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String firstName;
  final String lastName;

  SalesUser({
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.firstName,
    this.lastName,
  });

  factory SalesUser.fromJson(Map<String, dynamic> parsedJson) {
    return SalesUser(
      id: parsedJson['id'],
      email: parsedJson['email'],
      username: parsedJson['username'],
      fullName: parsedJson['fullName'],
      firstName: parsedJson['first_name'],
      lastName: parsedJson['last_name'],
    );
  }
}

class SalesUserCustomer {
  final int id;
  final int user;
  final int customer;
  final Customer customerDetails;

  SalesUserCustomer({
    this.id,
    this.customer,
    this.user,
    this.customerDetails,
  });

  factory SalesUserCustomer.fromJson(Map<String, dynamic> parsedJson) {
    return SalesUserCustomer(
      id: parsedJson['id'],
      user: parsedJson['user'],
      customerDetails: Customer.fromJson(parsedJson['customer_details'])
    );
  }
}

class SalesUserCustomers {
  final int count;
  final String next;
  final String previous;
  final List<SalesUserCustomer> results;

  SalesUserCustomers({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory SalesUserCustomers.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<SalesUserCustomer> results = list.map((i) => SalesUserCustomer.fromJson(i)).toList();

    return SalesUserCustomers(
        count: parsedJson['count'],
        next: parsedJson['next'],
        previous: parsedJson['previous'],
        results: results
    );
  }
}

class LastLocation {
  final LatLng latLon;
  final double lat;
  final double lon;
  final String name;
  final String type;
  final Order order;
  final Order lastAssignedOrder;

  LastLocation({
    this.latLon,
    this.lat,
    this.lon,
    this.name,
    this.type,
    this.order,
    this.lastAssignedOrder,
  });

  factory LastLocation.fromJson(Map<String, dynamic> parsedJson) {
      Order order;

      if (parsedJson['order'] != null) {
        order = Order.fromJson(parsedJson['order']);
      }

      LatLng latLon;
      if (parsedJson['lat'] != null && parsedJson['lon'] != null) {
        latLon = LatLng(parsedJson['lat'], parsedJson['lon']);
      }

      return LastLocation(
          latLon: latLon,
          lat: parsedJson['lat'],
          lon: parsedJson['lon'],
          name: parsedJson['name'],
          type: parsedJson['type'],
          order: order,
          lastAssignedOrder: Order.fromJson(parsedJson['last_assigned_order'])
      );
    }
}

class LastLocations {
  List<LastLocation> locations;

  LastLocations({
    this.locations
  });

  factory LastLocations.fromJson(List parsedJson) {
    print(parsedJson);
    List<LastLocation> locations = parsedJson.map((i) => LastLocation.fromJson(i)).toList();

    return LastLocations(
      locations: locations,
    );
  }
}
