import '../utils/quote_utils.dart';

class QuoteService {
  static QuoteService? _instance;
  static bool _initialized = false;
  late String _resultTopText;
  late String _resultBottomText;

  QuoteService._();

  static Future<QuoteService> getInstance() async {
    if (!_initialized) {
      _instance ??= QuoteService._();
      await _instance!._init();
      _initialized = true;
    }
    return _instance!;
  }

  Future<void> _init() async {
    _resultTopText = QuoteUtils.getRandomQuote(QuoteType.resultTop);
    _resultBottomText = QuoteUtils.getRandomQuote(QuoteType.resultBottom);
  }

  String get resultTopText => _resultTopText;
  String get resultBottomText => _resultBottomText;
}
