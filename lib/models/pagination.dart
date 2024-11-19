class Pagination<T> {
  final List<T> items;
  final bool hasMore;

  Pagination({
    required this.items,
    required this.hasMore,
  });
}
