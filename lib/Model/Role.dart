class Role {
  String? name;
  String? description;

  Role(String nm , String des )
  {
    name = nm;
    description = des;
  }
  Role.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'];
}