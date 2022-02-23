class Filters {
  String title;
  Map<String, String> filter;
  bool isSelected;
  String? selectedFilter;

  Filters(
      {required this.title,
      required this.filter,
      required this.isSelected,
      this.selectedFilter});
}
