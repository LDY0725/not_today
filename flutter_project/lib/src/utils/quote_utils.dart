import 'dart:math';

enum QuoteType {
  homePage,
  resultTop,
  resultBottom,
  modal,
  resignation,
  humor,
}

class QuoteUtils {
  static const Map<QuoteType, List<String>> _quotes = {
    QuoteType.homePage: [
      '留下来，不等于失败',
      '今天不用做决定',
      '不走，也是一种选择',
      '你只是还没准备好',
      '先撑一下，也没关系',
      '你现在的情绪，值一个年终奖',
    ],
    QuoteType.resultTop: [
      '今天，你还是没走',
      '今天，你选择留下',
      '今天，决定被推迟了',
      '今天，事情没有发生',
      '今天，你还在这里',
    ],
    QuoteType.resultBottom: [
      '你不是没勇气，是现在的你更清楚代价',
      '并不轻松，但你撑住了',
      '每一天，都不算白过',
      '这不是一件容易的事',
    ],
    QuoteType.modal: [
      '有些坚持，老板永远看不见',
      'HR 不说话，我也不敢提',
      '不是热爱工作，是对钱还有幻想',
      '每天都想辞职，但每天都在算钱',
      '连辞职的情绪，都被延期了',
    ],
    QuoteType.humor: [
      '咖啡续命中，请勿打扰',
      '我的耐心比工资先花完',
      '工位是我的避风港（贫穷版）',
      '今天也是用爱发电的一天',
      '充电器比我的前途更靠谱',
      '工作中的我：没事，我很好',
      '表面平静，内心已辞职八百次',
    ],
  };

  static String getRandomQuote(QuoteType type) {
    final quotes = _quotes[type];
    if (quotes == null || quotes.isEmpty) {
      return '';
    }
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }

  static List<String> getQuotesByType(QuoteType type) {
    return _quotes[type] ?? [];
  }

  static List<QuoteType> getAllTypes() {
    return QuoteType.values;
  }
}
