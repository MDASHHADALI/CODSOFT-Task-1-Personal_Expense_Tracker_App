import 'package:hive_flutter/hive_flutter.dart';
import 'models/model.dart';

class HiveDatabase{
  final _myBox=Hive.box("expense_database");
  //write data
  void saveData(List<ExpenseModel>allExpense)
  {
   List<List<dynamic>>allExpensesFormatted=[];
   for(var expense in allExpense)
     {
       List<dynamic>expenseFormatted=[
         expense.item,
         expense.desc,
         expense.amount,
         expense.isIncome,
         expense.date,
       ];
       allExpensesFormatted.add(expenseFormatted);
     }
   _myBox.put("ALL_EXPENSES", allExpensesFormatted);
  }
  void saveData2(int monthlyBudget)
  {
   _myBox.put("Monthly_Budget", monthlyBudget) ;
  }
  List<ExpenseModel> readData()
  {
    List savedExpenses= _myBox.get("ALL_EXPENSES")??[];
    List<ExpenseModel>allExpenses=[];
    for(int i=0;i<savedExpenses.length;i++) {
      String item = savedExpenses[i][0];
      String desc = savedExpenses[i][1];
      int amount = savedExpenses[i][2];
      bool isIncome = savedExpenses[i][3];
      DateTime date = savedExpenses[i][4];

      ExpenseModel expense = ExpenseModel(
          item: item,
          desc: desc,
          amount: amount,
          isIncome: isIncome,
          date: date);
      allExpenses.add(expense);
    }
    return allExpenses;
  }
  int? readData2()
  {
    int? data=_myBox.get("Monthly_Budget");
    print(data);
    return data;
  }

}