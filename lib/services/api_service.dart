import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://api.mfapi.in';

  /// Fetches the full list of mutual fund schemes.
  /// Throws an exception if the API fails or times out.
  Future<List<dynamic>> fetchSchemes() async {
    print('ApiService: Fetching mutual fund schemes from API...');
    final response = await _client
        .get(Uri.parse('$baseUrl/mf'))
        .timeout(const Duration(seconds: 90)); // Large timeout for 5.4MB payload

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        print('ApiService: API call successful! Loaded ${decoded.length} schemes.');
        return decoded;
      } else {
        throw const FormatException('Invalid API response format');
      }
    } else {
      throw HttpException('Server returned status code ${response.statusCode}');
    }
  }

  /// Fetches NAV details and history for a specific scheme code.
  /// Throws an exception if the API fails or times out.
  Future<Map<String, dynamic>> fetchSchemeDetail(int schemeCode) async {
    final uri = Uri.parse('$baseUrl/mf/$schemeCode');
    print('ApiService: Fetching details for scheme: $schemeCode...');
    final response = await _client.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        print('ApiService: Details API call successful for scheme: $schemeCode.');
        return decoded;
      } else {
        throw const FormatException('Invalid details response format');
      }
    } else {
      throw HttpException('Server returned status code ${response.statusCode}');
    }
  }

  /// Helper to get local fallback schemes list when API fails.
  static List<Map<String, dynamic>> get offlineCache => _offlineCache;

  /// Helper to generate local fallback details when API fails.
  static Map<String, dynamic> getOfflineDetail(int schemeCode, String schemeName) {
    final baseNav = 10.00 + (schemeCode % 590) + (schemeCode % 99) / 100.0;
    final List<Map<String, dynamic>> mockDataList = [];
    final today = DateTime.now();
    
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final dateFactor = (schemeCode + i) % 15 - 7;
      final walkNav = baseNav + (dateFactor * 0.12);
      
      final dayStr = date.day < 10 ? '0${date.day}' : '${date.day}';
      final monthStr = date.month < 10 ? '0${date.month}' : '${date.month}';
      final dateStr = '$dayStr-$monthStr-${date.year}';
      
      mockDataList.add({
        "date": dateStr,
        "nav": walkNav.toStringAsFixed(4),
      });
    }

    return {
      "meta": {
        "fund_house": "FundBrowser Asset Management",
        "scheme_type": "Open Ended Schemes",
        "scheme_category": "Growth Option",
        "scheme_code": schemeCode,
        "scheme_name": schemeName,
      },
      "data": mockDataList,
    };
  }

  // Pre-loaded offline cache containing a rich list of popular Indian mutual fund schemes
  // distributed across Equity, Debt, Hybrid, and Others.
  static final List<Map<String, dynamic>> _offlineCache = [
    // --- EQUITY ---
    {
      "schemeCode": 119598,
      "schemeName": "SBI Bluechip Fund - Direct Plan - Growth",
      "isinGrowth": "INF200K01UT1",
      "isinDivReinvestment": "INF200K01UU9"
    },
    {
      "schemeCode": 119063,
      "schemeName": "HDFC Mid-Cap Opportunities Fund - Direct Plan - Growth",
      "isinGrowth": "INF179K01GY8",
      "isinDivReinvestment": "INF179K01GZ5"
    },
    {
      "schemeCode": 120594,
      "schemeName": "ICICI Prudential Bluechip Fund - Direct Plan - Growth",
      "isinGrowth": "INF109K01FY2",
      "isinDivReinvestment": "INF109K01FZ9"
    },
    {
      "schemeCode": 118778,
      "schemeName": "Nippon India Small Cap Fund - Direct Plan - Growth",
      "isinGrowth": "INF204K01HY1",
      "isinDivReinvestment": "INF204K01HZ8"
    },
    {
      "schemeCode": 120465,
      "schemeName": "Axis Bluechip Fund - Direct Plan - Growth",
      "isinGrowth": "INF846K01DP8",
      "isinDivReinvestment": "INF846K01DQ6"
    },
    {
      "schemeCode": 122639,
      "schemeName": "Parag Parikh Flexi Cap Fund - Direct Plan - Growth",
      "isinGrowth": "INF669K01193",
      "isinDivReinvestment": "INF669K01201"
    },
    {
      "schemeCode": 119018,
      "schemeName": "Mirae Asset Large Cap Fund - Direct Plan - Growth",
      "isinGrowth": "INF769K01DG4",
      "isinDivReinvestment": "INF769K01DH2"
    },
    {
      "schemeCode": 120847,
      "schemeName": "Quant Active Fund - Direct Plan - Growth",
      "isinGrowth": "INF964M01166",
      "isinDivReinvestment": "INF964M01174"
    },
    {
      "schemeCode": 135794,
      "schemeName": "Tata Digital India Fund - Direct Plan - Growth",
      "isinGrowth": "INF277K012D1",
      "isinDivReinvestment": "INF277K012E9"
    },
    {
      "schemeCode": 120716,
      "schemeName": "UTI Nifty 50 Index Fund - Direct Plan - Growth",
      "isinGrowth": "INF227K01IL9",
      "isinDivReinvestment": "INF227K01IM7"
    },
    {
      "schemeCode": 120586,
      "schemeName": "Canara Robeco Bluechip Equity Fund - Direct Plan - Growth",
      "isinGrowth": "INF760K01EJ8",
      "isinDivReinvestment": "INF760K01EK6"
    },

    // --- DEBT ---
    {
      "schemeCode": 119813,
      "schemeName": "SBI Magnum Constant Maturity Fund - Direct Plan - Growth",
      "isinGrowth": "INF200K01VW0",
      "isinDivReinvestment": "INF200K01VX8"
    },
    {
      "schemeCode": 120165,
      "schemeName": "HDFC Corporate Debt Fund - Direct Plan - Growth",
      "isinGrowth": "INF179KB1298",
      "isinDivReinvestment": "INF179KB1306"
    },
    {
      "schemeCode": 119128,
      "schemeName": "ICICI Prudential Gilt Fund - Direct Plan - Growth",
      "isinGrowth": "INF109K01JT4",
      "isinDivReinvestment": "INF109K01JU2"
    },
    {
      "schemeCode": 118554,
      "schemeName": "Nippon India Gilt Securities Fund - Direct Plan - Growth",
      "isinGrowth": "INF204K01EN2",
      "isinDivReinvestment": "INF204K01EO0"
    },
    {
      "schemeCode": 120301,
      "schemeName": "Axis Treasury Advantage Fund - Direct Plan - Growth",
      "isinGrowth": "INF846K01912",
      "isinDivReinvestment": "INF846K01920"
    },
    {
      "schemeCode": 120254,
      "schemeName": "Aditya Birla Sun Life Medium Term Plan - Direct Plan - Growth",
      "isinGrowth": "INF109K012X1",
      "isinDivReinvestment": "INF109K012Y9"
    },

    // --- HYBRID ---
    {
      "schemeCode": 119801,
      "schemeName": "SBI Arbitrage Opportunities Fund - Direct Plan - Growth",
      "isinGrowth": "INF200K01UX3",
      "isinDivReinvestment": "INF200K01UY1"
    },
    {
      "schemeCode": 120143,
      "schemeName": "HDFC Balanced Advantage Fund - Direct Plan - Growth",
      "isinGrowth": "INF179K01844",
      "isinDivReinvestment": "INF179K01851"
    },
    {
      "schemeCode": 119114,
      "schemeName": "ICICI Prudential Equity & Debt Fund - Direct Plan - Growth",
      "isinGrowth": "INF109K01IL9",
      "isinDivReinvestment": "INF109K01IM7"
    },
    {
      "schemeCode": 118523,
      "schemeName": "Nippon India Arbitrage Fund - Direct Plan - Growth",
      "isinGrowth": "INF204K01DY8",
      "isinDivReinvestment": "INF204K01DZ5"
    },
    {
      "schemeCode": 120351,
      "schemeName": "Axis Equity Hybrid Fund - Direct Plan - Growth",
      "isinGrowth": "INF846K01W65",
      "isinDivReinvestment": "INF846K01W73"
    },
    {
      "schemeCode": 112140,
      "schemeName": "Edelweiss Balanced Advantage Fund - Direct Plan - Growth",
      "isinGrowth": "INF332M01529",
      "isinDivReinvestment": "INF332M01537"
    },

    // --- OTHERS / INDEX / SPECIAL ---
    {
      "schemeCode": 145346,
      "schemeName": "Motilal Oswal Nasdaq 100 FOF - Direct Plan - Growth",
      "isinGrowth": "INF247L01AK4",
      "isinDivReinvestment": "INF247L01AL2"
    },
    {
      "schemeCode": 135798,
      "schemeName": "SBI Nifty Index Fund - Direct Plan - Growth",
      "isinGrowth": "INF200K01V42",
      "isinDivReinvestment": "INF200K01V59"
    },
    {
      "schemeCode": 120842,
      "schemeName": "Quant Infrastructure Fund - Direct Plan - Growth",
      "isinGrowth": "INF964M01125",
      "isinDivReinvestment": "INF964M01133"
    },
    {
      "schemeCode": 119819,
      "schemeName": "Sundaram Mid Cap Fund - Direct Plan - Growth",
      "isinGrowth": "INF903J01HQ6",
      "isinDivReinvestment": "INF903J01HR4"
    },
    {
      "schemeCode": 128952,
      "schemeName": "PGIM India Midcap Opportunities Fund - Direct Plan - Growth",
      "isinGrowth": "INF663L01235",
      "isinDivReinvestment": "INF663L01243"
    },
    {
      "schemeCode": 125198,
      "schemeName": "Union Small Cap Fund - Direct Plan - Growth",
      "isinGrowth": "INF811K01CR0",
      "isinDivReinvestment": "INF811K01CS8"
    }
  ];
}
