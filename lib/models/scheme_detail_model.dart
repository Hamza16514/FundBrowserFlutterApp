class SchemeDetailModel {
  final Map<String, dynamic> meta;
  final List<NavHistoryItem> data;

  SchemeDetailModel({
    required this.meta,
    required this.data,
  });

  factory SchemeDetailModel.fromJson(Map<String, dynamic> json) {
    final metaData = json['meta'] as Map<String, dynamic>? ?? {};
    final rawDataList = json['data'] as List<dynamic>? ?? [];
    
    final dataList = rawDataList
        .map((item) => NavHistoryItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return SchemeDetailModel(
      meta: metaData,
      data: dataList,
    );
  }
}

class NavHistoryItem {
  final String date;
  final double nav;

  NavHistoryItem({
    required this.date,
    required this.nav,
  });

  factory NavHistoryItem.fromJson(Map<String, dynamic> json) {
    // Nav from API is a string, e.g. "47.23"
    final navStr = json['nav']?.toString() ?? '0.0';
    return NavHistoryItem(
      date: json['date']?.toString() ?? '',
      nav: double.tryParse(navStr) ?? 0.0,
    );
  }
}
