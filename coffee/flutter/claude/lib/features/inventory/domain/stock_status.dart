/// Stock, reorder point and reach of one bean (SPEC R4, R5).
class StockStatus {
  /// Creates a status.
  const StockStatus({
    required this.consumptionPerDay,
    required this.minStockG,
    required this.orderPoint,
    required this.totalStockG,
    required this.daysOfCover,
    required this.restDays,
    required this.orderNow,
  });

  /// Average grams used per day over the last 28 days (not rounded).
  final double consumptionPerDay;

  /// Minimum stock in grams: the bean's value, else twice the daily
  /// consumption, else 100 g.
  final double minStockG;

  /// Stock in grams at or below which a reorder is due.
  final double orderPoint;

  /// Remaining grams of live packs that are not too old (resting included).
  final double totalStockG;

  /// Days the stock lasts (total / consumption); null without consumption.
  final double? daysOfCover;

  /// Resting days of the bean (espresso or filter by its kind and roast).
  final int restDays;

  /// Whether the total stock is at or below the order point.
  final bool orderNow;
}
