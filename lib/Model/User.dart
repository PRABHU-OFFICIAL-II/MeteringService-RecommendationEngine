import 'Role.dart';

class User {
  String? id;
  String? orgId;
  String? orgUuid;
  String? name;
  String? description;
  String? createTime;
  String? updateTime;
  String? createdBy;
  String? updatedBy;
  String? sfUsername;
  String? firstName;
  String? lastName;
  String? title;
  String? password;
  String? phone;
  String? emails;
  String? timezone;
  String? serverUrl;
  String? icSessionId;
  String? securityQuestion;
  String? securityAnswer;
  String? uuid;
  bool? forceChangePassword;
  List<Role>? roles;
  List<dynamic>? usergroups; // Assuming usergroups can be of any type
  String? spiUrl;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        orgId = json['orgId'],
        orgUuid = json['orgUuid'],
        name = json['name'],
        description = json['description'],
        createTime = json['createTime'],
        updateTime = json['updateTime'],
        createdBy = json['createdBy'],
        updatedBy = json['updatedBy'],
        sfUsername = json['sfUsername'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        title = json['title'],
        password = json['password'],
        phone = json['phone'],
        emails = json['emails'],
        timezone = json['timezone'],
        serverUrl = json['serverUrl'],
        icSessionId = json['icSessionId'],
        securityQuestion = json['securityQuestion'],
        securityAnswer = json['securityAnswer'],
        uuid = json['uuid'],
        forceChangePassword = json['forceChangePassword'],
        roles = (json['roles'] as List?)
            ?.map((role) => Role.fromJson(role))
            .toList(),
        usergroups = json['usergroups'],
        spiUrl = json['spiUrl'];
}
