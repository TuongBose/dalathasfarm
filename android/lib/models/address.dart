class Province {
  final String name;
  final int code;
  final List<District> districts;

  Province({required this.name, required this.code, required this.districts});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      name: json['name'] as String,
      code: json['code'] as int,
      districts: (json['districts'] as List).map((d) => District.fromJson(d)).toList(),
    );
  }
}

class District {
  final String name;
  final int code;
  final List<Ward> wards;

  District({required this.name, required this.code, required this.wards});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      name: json['name'] as String,
      code: json['code'] as int,
      wards: (json['wards'] as List).map((w) => Ward.fromJson(w)).toList(),
    );
  }
}

class Ward {
  final String name;
  final int code;

  Ward({required this.name, required this.code});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      name: json['name'] as String,
      code: json['code'] as int,
    );
  }
}