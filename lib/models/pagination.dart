class Pagination<T> {
  final List<T> items;
  final bool hasMore;

  Pagination({required this.items, required this.hasMore});

  factory Pagination.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final List<dynamic> content = json['content'] ?? [];
    List<T> items = content.map((item) => fromJsonT(item)).toList();

    bool hasMore = !(json['last'] as bool? ?? true);

    return Pagination(items: items, hasMore: hasMore);
  }
}
