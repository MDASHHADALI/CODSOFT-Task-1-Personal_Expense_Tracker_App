import 'package:personal_expense_tracker/hive_database.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/material.dart';
import 'models/model.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
List options = ["expense", "income"];
List<String> items = <String>[];
List<ExpenseModel> expenses = [];
final db=HiveDatabase();

class _MyHomePageState extends State<MyHomePage> {

  final itemController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final budgetController=TextEditingController();
  var amount=0;
  int totalMoney = 0;
  int spentMoney = 0;
  int income = 0;
  bool validateamount= false;
  bool validateitem= false;
  bool validatedate=false;
  DateTime? pickedDate;
  String currentOption = "no";
  String? selectedValue;
  int monthlyexpense=0;
  int monthlyincome=0;
  int monthlybudget=0;

  void prepareData()
  {
    if(db.readData().isNotEmpty)
      {
        expenses=db.readData();
      }
  }
  void prepareData2()
  {
    int? c=db.readData2();
    if(!(c==null||c==0))
      {
        monthlybudget=c;
      }
  }
  void del(int i)
  {
    if(!expenses[i].isIncome)
    {
      spentMoney-=expenses[i].amount;
      if(DateFormat('MMMM yyyy').format(expenses[i].date)==DateFormat('MMMM yyyy').format(DateTime.now()))
        monthlyexpense=monthlyexpense-expenses[i].amount;
    }
    else
    {
      income-=expenses[i].amount;
      if(DateFormat('MMMM yyyy').format(expenses[i].date)==DateFormat('MMMM yyyy').format(DateTime.now()))
        monthlyincome=monthlyincome-expenses[i].amount;
    }
    expenses.removeAt(i);
  }
  @override
  void initState() {
    // TODO: implement initState
    prepareData();
    prepareData2();
    for(var i=0;i<expenses.length;i++)
    {
      if(!expenses[i].isIncome)
      {
        spentMoney+=expenses[i].amount;
        if(DateFormat('MMMM yyyy').format(expenses[i].date)==DateFormat('MMMM yyyy').format(DateTime.now()))
        monthlyexpense=monthlyexpense+expenses[i].amount;
      }
      else
        {
          income+=expenses[i].amount;
          if(DateFormat('MMMM yyyy').format(expenses[i].date)==DateFormat('MMMM yyyy').format(DateTime.now()))
            monthlyincome=monthlyincome+expenses[i].amount;
        }
    }
    super.initState();
  }
  Future openDialog()=>showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
          builder: (context,setState) {
            return SizedBox(
              height: 400,
              child: AlertDialog(
                backgroundColor: Colors.white,
                title: const Padding(
                  padding: EdgeInsets.only(left: 1.6),
                  child: Text("ADD TRANSACTION"),
                ),
                actions: [
                  TextButton(
                    onPressed: () {

                      validateamount = amountController.text.isEmpty;
                      validateitem= itemController.text.isEmpty;
                      validatedate= dateController.text.isEmpty;
                      print(amountController.text);
                      var check=int.tryParse(amountController.text);
                      if(validateitem)
                      {
                        QuickAlert.show(context: context, type: QuickAlertType.error,title: "Enter the Description");
                      }
                      else if(validateamount)
                      {
                        QuickAlert.show(context: context, type: QuickAlertType.error,title: "Enter the amount");
                      }
                      else if(check==null)
                      {
                        QuickAlert.show(context: context, type: QuickAlertType.error,title: "Enter only number in amount");
                      }
                      else if(validatedate)
                      {
                        QuickAlert.show(context: context, type: QuickAlertType.error,title: "Enter the date");
                      }
                      else if(currentOption==null)
                      {
                        QuickAlert.show(context: context, type: QuickAlertType.error,title: "Select Income or Expense");
                      }
                      else if(selectedValue==null)
                      {
                        QuickAlert.show(context: context, type: QuickAlertType.error,title: "Select Category");
                      }
                      else
                      {
                        amount=int.parse(amountController.text);
                        // adding a new item
                        final expense = ExpenseModel(
                          item: itemController.text,
                          desc: selectedValue!,
                          amount: amount,
                          isIncome: currentOption == "income" ? true : false,
                          date: pickedDate!,
                        );
                        print(expense.item);
                        expenses.add(expense);
                        db.saveData(expenses);
                        print(expense.isIncome);
                        if (expense.isIncome) {
                          income += expense.amount;
                          totalMoney += expense.amount;
                          setState(() {print(expenses.length);});
                        } else if (!expense.isIncome) {
                          spentMoney += expense.amount;
                          totalMoney -= expense.amount;
                          setState(() {
                            print(expenses.length);
                          });
                        }

                        itemController.clear();
                        amountController.clear();
                        dateController.clear();
                        Navigator.pop(context);}
                    },
                    child: const Text(
                      "ADD",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      itemController.clear();
                      amountController.clear();
                      dateController.clear();
                      selectedValue=null;
                      currentOption = "no";
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],

                content: SizedBox(
                  height: double.infinity,
                  width: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: itemController,
                          decoration: const InputDecoration(
                            hintText: "Enter the Description",
                            labelText: "Description",
                            hintStyle: TextStyle(
                              color: Colors.blueGrey,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration:  InputDecoration(
                            hintText: "Enter the Amount",
                            labelText: "Amount",
                            hintStyle: TextStyle(
                              color: Colors.blueGrey,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            onTap: () async {
                              // user can pick date
                              pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              String date =
                              DateFormat.yMMMMd().format(pickedDate!);
                              dateController.text = date;
                              setState(() {});
                            },
                    
                            controller: dateController,
                            decoration: const InputDecoration(
                              labelText: "DATE",
                              hintStyle: TextStyle(
                                color: Colors.blueGrey,
                              ),
                              filled: true,
                              prefixIcon: Icon(Icons.calendar_today),
                              prefixIconColor: Colors.blue,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(height: 15),
                        RadioMenuButton(
                          value: options[0],
                          groupValue: currentOption,
                          onChanged: (expense) {
                            setState(() {
                              currentOption = expense.toString();
                              selectedValue=null;
                              items=["Food","Travel","Shopping","Home","Entertainment","Insurance","Education","Miscellaneous"];
                            });
                    
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Text(
                              "Expense",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.4,
                              ),
                            ),
                          ),
                        ),
                        RadioMenuButton(
                          style: ButtonStyle(
                            iconSize: MaterialStateProperty.all(20),
                          ),
                          value: options[1],
                          groupValue: currentOption,
                          onChanged: (income) {
                            setState(() {
                              currentOption = income.toString();
                              selectedValue=null;
                              items=["Salary","Pension","Rental","Pocket Money","Gift card","Others"];
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Text(
                              "Income",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'Select Category',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            items: items
                                .map((String item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black
                                ),
                              ),
                            ))
                                .toList(),
                            value: selectedValue,
                            onChanged:(currentOption!="no")? (String? value) =>
                                setState(() =>
                                selectedValue = value
                                ):null,
                            buttonStyleData:  ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              height: 40,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Colors.black),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      );
    },
  );
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Expense Tracker"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
          
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(padding: const EdgeInsets.all(25.0),
              child:Container(
              height:200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue[200],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey,
                      offset: const Offset(
                        5.0,
                        5.0,
                      ), //Offset
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ), //BoxShadow
                    BoxShadow(
                      color: Colors.white,
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ), //BoxShadow
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('TOTAL',style:TextStyle(color:Colors.black54,fontSize: 16)),
                      Text('B A L A N C E',style:TextStyle(color:Colors.black54,fontSize: 16)),
                      Text((income-spentMoney).toString(),
                        style: TextStyle(color: Colors.grey[800],fontSize: 40),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding:EdgeInsets.all(10),
                                    decoration:BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[200],
                                    ),
                                    child: Center(child: Icon(Icons.arrow_upward,color: Colors.green,))),
                                SizedBox(width: 10.0,),
                                Column(
                                  children: [
                                    Text('Income',style: TextStyle(color: Colors.grey[700]),),
                                    Text(income.toString(),style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                    padding: EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,

                                    ),
                                    child: Icon(Icons.arrow_downward,color: Colors.red,)),
                                SizedBox(width: 10.0,),
                                Column(
                                  children: [
                                    Text('Expense',style: TextStyle(color: Colors.grey[700])),
                                    Text(spentMoney.toString(),style: TextStyle(fontWeight: FontWeight.bold
                                    ),),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        )),

              Padding(padding: const EdgeInsets.only(left: 25.0,right: 25.0,top: 10.0,bottom: 25.0),
                  child:Container(
                    height:200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.orangeAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.shade500,
                          offset: const Offset(
                            5.0,
                            5.0,
                          ), //Offset
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                        ), //BoxShadow
                        BoxShadow(
                          color: Colors.white,
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(DateFormat('MMMM yyyy').format(DateTime.now()),style:TextStyle(color:Colors.black54,fontSize: 16)),
                          Text('B A L A N C E',style:TextStyle(color:Colors.black54,fontSize: 16)),
                          Text((monthlyincome-monthlyexpense).toString(),
                            style: TextStyle(color: Colors.grey[800],fontSize: 40),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        padding:EdgeInsets.all(10),
                                        decoration:BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey[200],
                                        ),
                                        child: Center(child: Icon(Icons.arrow_upward,color: Colors.green,))),
                                    SizedBox(width: 10.0,),
                                    Column(
                                      children: [
                                        Text('Income',style: TextStyle(color: Colors.grey[700]),),
                                        Text(monthlyincome.toString(),style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,

                                        ),
                                        child: Icon(Icons.arrow_downward,color: Colors.red,)),
                                    SizedBox(width: 10.0,),
                                    Column(
                                      children: [
                                        Text('Expense',style: TextStyle(color: Colors.grey[700])),
                                        Text(monthlyexpense.toString(),style: TextStyle(fontWeight: FontWeight.bold
                                        ),),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            SizedBox(
              height:10,
            ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("Monthly Expense Budget",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Text("Budget : "+((monthlybudget>0)?((monthlybudget).toString()):"Not Set"),style: TextStyle(fontSize: 20),),
                          ],
                        ),
                        SizedBox(height: (monthlybudget!=0)?10:0),
                        Stack(
                          children: [
                            Container(
                              height: (monthlybudget!=0)?20:0,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(15),

                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: (monthlyexpense<monthlybudget)?(monthlyexpense/monthlybudget):1,
                              child: Container(
                                height: (monthlybudget!=0)?20:0,
                                width:monthlybudget!=0?((MediaQuery.of(context).size.width/monthlybudget)*monthlyexpense):0,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(15),

                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: (monthlybudget!=0)?10:0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                          Text((monthlybudget!=0)?("Remaining Budget : "+(monthlybudget-monthlyexpense).toString()):"",style: TextStyle(fontSize: 20),),
                        ],),

                        SizedBox(height: 10,),
                        FilledButton(onPressed: ()async {
                        await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                        return AlertDialog(
                        title: const Text("Budget"),
                        content: SizedBox(
                          height: 80,
                          width: 400,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: budgetController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Enter the Amount",
                                    labelText: "Amount",
                                    hintStyle: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        actions: <Widget>[
                        FilledButton(
                        onPressed: () {
                          var ch=int.tryParse(budgetController.text);
                          if(ch==0||ch==null)
                            {
                              monthlybudget=0;
                              db.saveData2(monthlybudget);
                              Navigator.of(context).pop();
                            }
                          else{
                            monthlybudget=ch;
                            db.saveData2(monthlybudget);
                          Navigator.of(context).pop(true);
                          }
                          },
                        child: const Text("SET")
                        ),
                        FilledButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCEL"),
                        ),
                        ],
                        );
                        },
                        );
                        setState(() {

                        });
                        }, child:  Text((monthlybudget==0)?"Set Budget":"Change Budget")),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(
                height:10,
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child:
                  Column(
                    children: [
                      Text("All Transactions",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                      Text((expenses.length==0)?"\nNo Recent Transaction\n\n\n":"",textAlign: TextAlign.center,),
                      Ink(
                        height: 150.0*expenses.length,

                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: expenses.length,
                          itemBuilder:(context,index ){
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                splashColor: Colors.amber,
                                highlightColor: Colors.green,
                                hoverColor: Colors.pinkAccent,
                                onTap: (){
                                },

                                child: Dismissible(
                                  child:
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [BoxShadow(blurRadius:10.0,color: Colors.white70)],
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: ListTile(leading:Text(DateFormat.yMMMMd().format(expenses[index].date),style: TextStyle(color: Colors.orange,fontSize: 15)),
                                      title: Text(expenses[index].item,style: TextStyle(color: Colors.deepPurple,fontSize: 15),softWrap: true,textAlign: TextAlign.center,),
                                      subtitle: Text(expenses[index].desc,style:TextStyle(color: Colors.purple,fontSize: 15,fontWeight: FontWeight.bold),softWrap: true,textAlign: TextAlign.center,),
                                      trailing: Text((expenses[index].amount).toString(),style: TextStyle(color: (expenses[index].isIncome)?Colors.green:Colors.red,fontSize: 15,fontWeight: FontWeight.bold),softWrap: true,textAlign: TextAlign.center,),
                                    ),
                                  ),
                                  background: Container(color: Colors.redAccent,child: Row(
                                    children: [
                                      SizedBox(width: 10,),
                                      Icon(Icons.delete),
                                    ],
                                  ),),
                                  key: UniqueKey(),
                                  direction: DismissDirection.startToEnd,
                                  confirmDismiss: (DismissDirection direction) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm"),
                                          content: const Text("Are you sure you wish to delete this item?"),
                                          actions: <Widget>[
                                            FilledButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text("DELETE")
                                            ),
                                            FilledButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text("CANCEL"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  onDismissed: (DismissDirection direction) {
                                    del(index);
                                    setState(()  {
                                      db.saveData(expenses);
                                    });
                                  }, ),
                              ),
                            );
                          },),
                      )
                    ],
                  ),
                ),
              ),
          
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: ()async{
            selectedValue=null;
            currentOption = "no";
            await openDialog();
        setState(() {
             monthlyexpense=0;
             monthlyincome=0;
            for(var i=0;i<expenses.length;i++)
              {
                if(!expenses[i].isIncome&&DateFormat('MMMM yyyy').format(expenses[i].date)==DateFormat('MMMM yyyy').format(DateTime.now()))
                {
                  monthlyexpense=monthlyexpense+expenses[i].amount;
                }
                if(expenses[i].isIncome&&DateFormat('MMMM yyyy').format(expenses[i].date)==DateFormat('MMMM yyyy').format(DateTime.now()))
                {
                  monthlyincome=monthlyincome+expenses[i].amount;
                }
                print(monthlyexpense);
              }
        });
        },
          tooltip: 'Add new Transaction',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );


  }
}