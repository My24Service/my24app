import 'package:latlong2/latlong.dart';
import 'package:my24app/customer/models/models.dart';

import '../../order/models/order/models.dart';

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

class StreamInfo {
  final String apiKey;
  final String token;
  final String channelId;
  final String channelTitle;
  final String memberUserId;
  final MinimalUser user;

  StreamInfo({
    this.apiKey,
    this.token,
    this.channelId,
    this.channelTitle,
    this.memberUserId,
    this.user
  });

  factory StreamInfo.fromJson(Map<String, dynamic> parsedJson) {
    MinimalUser user = MinimalUser.fromJson(parsedJson['user']);

    return StreamInfo(
      apiKey: parsedJson['api_key'],
      token: parsedJson['token'],
      channelId: parsedJson['channel_id'],
      channelTitle: parsedJson['channel_title'],
      memberUserId: parsedJson['member_user_id'],
      user: user
    );
  }
}

class EngineerProperty {
  final String address;
  final String postal;
  final String city;
  final String countryCode;
  final String mobile;
  final int preferedLocation;

  EngineerProperty({
    this.address,
    this.postal,
    this.city,
    this.countryCode,
    this.mobile,
    this.preferedLocation
  });

  factory EngineerProperty.fromJson(Map<String, dynamic> parsedJson) {
    return EngineerProperty(
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
      mobile: parsedJson['mobile'],
      preferedLocation: parsedJson['prefered_location'],
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
  StreamInfo streamInfo;

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

class EmployeeProperty {
  final int branch;

  EmployeeProperty({
    this.branch,
  });

  factory EmployeeProperty.fromJson(Map<String, dynamic> parsedJson) {
    return EmployeeProperty(
      branch: parsedJson['branch'],
    );
  }
}

class EmployeeUser {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String firstName;
  final String lastName;
  final EmployeeProperty employee;

  EmployeeUser({
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.firstName,
    this.lastName,
    this.employee
  });

  factory EmployeeUser.fromJson(Map<String, dynamic> parsedJson) {
    return EmployeeUser(
      id: parsedJson['id'],
      email: parsedJson['email'],
      username: parsedJson['username'],
      fullName: parsedJson['fullName'],
      firstName: parsedJson['first_name'],
      lastName: parsedJson['last_name'],
      employee: EmployeeProperty.fromJson(parsedJson['employee_user']),
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
    List<LastLocation> locations = parsedJson.map((i) => LastLocation.fromJson(i)).toList();

    return LastLocations(
      locations: locations,
    );
  }
}

class UserOffHours {
  final String startDate;
  final String duration;
  final String offHoursType;
  final String description;

  UserOffHours({
    this.startDate,
    this.duration,
    this.offHoursType,
    this.description,
  });

  factory UserOffHours.fromJson(Map<String, dynamic> parsedJson) {
    return UserOffHours(
      startDate: parsedJson['start_date'],
      duration: parsedJson['duration'],
      offHoursType: parsedJson['off_hours_type'],
      description: parsedJson['description'],
    );
  }
}

class Branch {
  final int id;
  final String name;
  final String address;
  final String postal;
  final String city;
  final String countryCode;
  final String tel;
  final String email;
  final String contact;
  final String mobile;

  Branch({
    this.id,
    this.name,
    this.address,
    this.postal,
    this.city,
    this.countryCode,
    this.tel,
    this.email,
    this.contact,
    this.mobile
  });

  factory Branch.fromJson(Map<String, dynamic> parsedJson) {
    return Branch(
      id: parsedJson['id'],
      name: parsedJson['name'],
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
      tel: parsedJson['tel'],
      email: parsedJson['email'],
      contact: parsedJson['contact'],
      mobile: parsedJson['mobile'],
    );
  }
}

class BranchTypeAheadModel {
  final int id;
  final String name;
  final String address;
  final String postal;
  final String city;
  final String countryCode;
  final String tel;
  final String mobile;
  final String email;
  final String contact;
  final String value;

  BranchTypeAheadModel({
    this.id,
    this.name,
    this.address,
    this.postal,
    this.city,
    this.countryCode,
    this.tel,
    this.mobile,
    this.email,
    this.contact,
    this.value,
  });

  factory BranchTypeAheadModel.fromJson(Map<String, dynamic> parsedJson) {
    return BranchTypeAheadModel(
      id: parsedJson['id'],
      name: parsedJson['name'],
      address: parsedJson['address'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
      tel: parsedJson['tel'],
      mobile: parsedJson['mobile'],
      email: parsedJson['email'],
      contact: parsedJson['contact'],
      value: parsedJson['value'],
    );
  }
}
