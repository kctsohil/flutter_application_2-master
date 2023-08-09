import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive/hive.dart';
import 'package:hive_database_example/transaction_dialogue.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'boxes.dart';
import 'model/transaction.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final myController = TextEditingController();
  String name = '';
  String title = "purchases";
  bool toggle = true;
  String btnlabel = "sales";

  @override
  void dispose() {
    myController.dispose();
    Hive.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
        ),
        body: ValueListenableBuilder<Box<Transaction>>(
          valueListenable: Boxes.getTransactions().listenable(),
          builder: (context, box, _) {
            final transactions = box.values
                .where((Transaction) =>
                    Transaction.name!.toLowerCase().contains(name) &&
                    Transaction.isExpense == toggle)
                .toList()
                .cast<Transaction>();

            final transactions1 = box.values.toList().cast<Transaction>();

            return buildContent(transactions, transactions1);
          },
        ),
        floatingActionButton: SpeedDial(
          mini: true,
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
                child: Icon(Icons.mail),
                label: 'sales',
                onTap: () {
                  setState(() {
                    toggle = false;
                    title = "sales";
                  });
                }),
            SpeedDialChild(
                child: Icon(Icons.mail),
                label: 'purchases',
                onTap: () {
                  setState(() {
                    toggle = true;

                    title = "purchases";
                  });
                }),
            SpeedDialChild(
                child: Icon(Icons.add),
                label: 'add',
                onTap: () => showDialog(
                      context: context,
                      builder: (context) => TransactionDialog(
                        onClickedDone: addTransaction,
                      ),
                    ))
          ],
        ), // button second

        // button third

        // Add more buttons here
      );

  Widget buildContent(
      List<Transaction> transactions, List<Transaction> transactions1) {
    {
      final netExpense = transactions1.fold<double>(
        0,
        (previousValue, transaction1) => transaction1.isExpense
            ? previousValue + transaction1.amount
            : previousValue - transaction1.amount,
      );
      final newExpenseString = '\$${netExpense.toStringAsFixed(2)}';
      final color = netExpense > 0 ? Colors.green : Colors.red;

      return Column(
        children: [
          TextField(
            controller: myController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: suggest,
          ),
          Text(
            'Net Expense: $newExpenseString',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: transactions.length,
              itemBuilder: (BuildContext context, int index) {
                int itemCount = transactions.length;

                int reversedIndex = itemCount - 1 - index;
                final transaction = transactions[reversedIndex];

                return buildTransaction(context, transaction);
              },
            ),
          ),
        ],
      );
    }
  }

  Widget buildTransaction(
    BuildContext context,
    Transaction transaction,
  ) {
    final color = transaction.isExpense ? Colors.red : Colors.green;
    final date = DateFormat.yMMMd().format(transaction.createdDate);
    final amount = '\$' + transaction.amount.toStringAsFixed(2);
    final stock = transaction.stock.toStringAsFixed(2);

    if (transaction.isExpense)
      return Card(
        color: Colors.white,
        child: ExpansionTile(
          trailing: IconButton(
            color: Colors.blue,
            icon: Icon(Icons.sell),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => TransactionDialog(
                transaction: transaction,
                isSale: true,
                onClickedDone: (name, amount, stock, isExpense) =>
                    editTransaction(
                        transaction, name, amount, stock, isExpense),
              ),
            ),
          ),
          tilePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          title: Text(
            transaction.name,
            maxLines: 2,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(date),
          children: [
            ExpansionTile(
              title: Text("stock"),
              trailing: Text(stock),
            ),
            ExpansionTile(
              title: Text("amount"),
              trailing: Text(amount),
            ),
            buildButtons(context, transaction),
          ],
        ),
      );
    else
      return Card(
        color: Colors.white,
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          title: Text(
            transaction.name,
            maxLines: 2,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(date),
          children: [
            ExpansionTile(
              title: Text("sold stock"),
              trailing: Text(stock),
            ),
            ExpansionTile(
              title: Text("sold at"),
              trailing: Text(amount),
            ),
            buildButtons(context, transaction),
          ],
        ),
      );
  }

  Widget buildButtons(BuildContext context, Transaction transaction) => Row(
        children: [
          Expanded(
            child: TextButton.icon(
              label: Text('Edit'),
              icon: Icon(Icons.edit),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => TransactionDialog(
                  transaction: transaction,
                  onClickedDone: (name, amount, stock, isExpense) =>
                      translateTransaction(
                          transaction, name, amount, stock, isExpense),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton.icon(
              label: Text('Delete'),
              icon: Icon(Icons.delete),
              onPressed: () => deleteTransaction(transaction),
            ),
          )
        ],
      );

  Future addTransaction(
      String name, double amount, double stock, bool isExpense) async {
    final transaction = Transaction()
      ..name = name
      ..createdDate = DateTime.now()
      ..amount = amount
      ..stock = stock
      ..isExpense = true;

    final box = Boxes.getTransactions();
    box.add(transaction);
    setState(() {
      toggle = true;
      title = "purchases";
    });
    //box.put('mykey', transaction);

    // final mybox = Boxes.getTransactions();
    // final myTransaction = mybox.get('key');
    // mybox.values;
    // mybox.keys;
  }

  void editTransaction(
    Transaction transaction,
    String name,
    double amount,
    double stock,
    bool isExpense,
  ) {
    if (transaction.stock > stock && transaction.isExpense) {
      transaction.name = name;
      //transaction.amount = amount;
      transaction.stock -= stock;
      transaction.isExpense = true;
      // final box = Boxes.getTransactions();
      // box.put(transaction.key, transaction);
      transaction.save();

      final transaction1 = Transaction()
        ..name = name
        ..createdDate = DateTime.now()
        ..amount = amount
        ..stock = stock
        ..isExpense = false;

      final box = Boxes.getTransactions();
      box.add(transaction1);
    } else
      setState(() {
        AlertDialog(
          title: Text("invalid stock"),
        );
      });
  }

  void translateTransaction(
    Transaction transaction,
    String name,
    double amount,
    double stock,
    bool isExpense,
  ) async {
    //transaction.name = name;
    transaction.amount = amount;
    transaction.stock = stock;
    //transaction.isExpense = true;
    // final box = Boxes.getTransactions();
    // box.put(transaction.key, transaction);
    transaction.save();
  }

  void deleteTransaction(Transaction transaction) async {
    if (await confirm(context)) {
      transaction.delete();
    }
    // final box = Boxes.getTransactions();
    // box.delete(transaction.key);

    //setState(() => transactions.remove(transaction));
  }

  void suggest(String query) {
    setState(() {
      if (myController != null) name = myController.text;
    });
  }
}
