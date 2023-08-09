import 'package:flutter/material.dart';

import '../model/transaction.dart';

class TransactionDialog extends StatefulWidget {
  final Transaction? transaction;
  final bool? isSale;
  final Function(
    String name,
    double amount,
    double stock,
    bool isExpense,
  ) onClickedDone;

  const TransactionDialog({
    Key? key,
    this.transaction,
    required this.onClickedDone,
    this.isSale,
  }) : super(key: key);

  @override
  _TransactionDialogState createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final stkController = TextEditingController();

  bool isExpense = true;

  bool isSale = false;

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      final transaction = widget.transaction!;

      nameController.text = transaction.name;
      // amountController.text = transaction.amount.toString();
      isExpense = transaction.isExpense;
    }

    if (widget.isSale != null) this.isSale = widget.isSale!;
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    stkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    String title = isEditing ? 'new discription' : 'Add Transaction';
    if (isSale) title = "sales description";
    return AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 8),
              if (!isEditing) buildName(),
              SizedBox(height: 8),
              buildAmount(),
              SizedBox(height: 8),
              buildstk(),
              SizedBox(height: 8),
              //  buildRadioButtons(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        buildCancelButton(context),
        buildAddButton(context, isEditing: isEditing),
      ],
    );
  }

  Widget buildName() => TextFormField(
        controller: nameController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter Name',
        ),
        validator: (name) =>
            name != null && name.isEmpty ? 'Enter a name' : null,
      );

  Widget buildAmount() => TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter Unit Price',
        ),
        keyboardType: TextInputType.number,
        validator: (amount) => amount != null && double.tryParse(amount) == null
            ? 'Enter a valid number'
            : null,
        controller: amountController,
      );
  Widget buildstk() => TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter Stock',
        ),
        keyboardType: TextInputType.number,
        validator: (stock) => stock != null && double.tryParse(stock) == null
            ? 'Enter a valid number'
            : null,
        controller: stkController,
      );

  Widget buildCancelButton(BuildContext context) => TextButton(
        child: Text('Cancel'),
        onPressed: () => Navigator.of(context).pop(),
      );

  Widget buildAddButton(BuildContext context, {required bool isEditing}) {
    String text = isEditing ? 'Save' : 'Add';
    if (isSale) text = "sell";
    return TextButton(
      child: Text(text),
      onPressed: () async {
        final isValid = formKey.currentState!.validate();

        if (isValid) {
          final name = nameController.text;
          final stock = double.tryParse(stkController.text) ?? 0;
          final amount = double.tryParse(amountController.text) ?? 0;

          widget.onClickedDone(name, amount, stock, isExpense);

          Navigator.of(context).pop();
        }
      },
    );
  }
}
