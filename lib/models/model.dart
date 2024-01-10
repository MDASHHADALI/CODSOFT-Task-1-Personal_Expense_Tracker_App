class ExpenseModel {
  String item;
  String desc;
  int amount;
  bool isIncome;
  DateTime date;
  ExpenseModel({
    required this.item,
    required this.desc,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}