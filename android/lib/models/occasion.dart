class Occasion {
    final int id;
    final String name;
    final String thumbnail;
    final String bannerImage;
    final DateTime startDate;
    final DateTime endDate;

    Occasion({
      required this.id,
      required this.name,
      required this.thumbnail,
      required this.bannerImage,
      required this.startDate,
      required this.endDate,
    });

    factory Occasion.fromJson(Map<String, dynamic> json) {
      return Occasion(
        id: json['id'],
        name: json['name'],
        thumbnail: json['thumbnail'],
        bannerImage: json['bannerImage'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
      );
    }
}