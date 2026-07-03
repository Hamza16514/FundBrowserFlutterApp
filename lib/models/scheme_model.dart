class SchemeModel {
  final int schemeCode;
  final String schemeName;
  final String? isinGrowth;
  final String? isinDivReinvestment;

  // Mock fields derived from schemeCode for stability and high fidelity
  late final double mockNav;
  late final double mockChange;
  late final String category; // Derived category: Equity, Debt, Hybrid, etc.

  SchemeModel({
    required this.schemeCode,
    required this.schemeName,
    this.isinGrowth,
    this.isinDivReinvestment,
  }) {
    // Generate stable NAV between 10.00 and 600.00
    mockNav = 10.00 + (schemeCode % 590) + (schemeCode % 99) / 100.0;
    
    // Generate stable change between -3.5% and +4.5%
    final changeVal = ((schemeCode % 9) - 4) + (schemeCode % 10) / 10.0;
    mockChange = changeVal == 0.0 ? 0.4 : changeVal;

    // Distribute stable categories based on schemeCode
    final catIndex = schemeCode % 4;
    switch (catIndex) {
      case 0:
        category = 'Equity';
        break;
      case 1:
        category = 'Debt';
        break;
      case 2:
        category = 'Hybrid';
        break;
      default:
        category = 'Others';
        break;
    }
  }

  factory SchemeModel.fromJson(Map<String, dynamic> json) {
    return SchemeModel(
      schemeCode: json['schemeCode'] as int,
      schemeName: json['schemeName'] as String,
      isinGrowth: json['isinGrowth'] as String?,
      isinDivReinvestment: json['isinDivReinvestment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemeCode': schemeCode,
      'schemeName': schemeName,
      'isinGrowth': isinGrowth,
      'isinDivReinvestment': isinDivReinvestment,
    };
  }
}
