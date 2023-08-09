import 'package:flutter/material.dart';
import 'package:hive_database_example/model/transaction.dart';
import 'package:hive_database_example/transaction_page.dart';

class menu extends StatefulWidget {
  const menu({key});

  @override
  State<menu> createState() => _menuState();
}

class _menuState extends State<menu> {
  @override
  Widget build(BuildContext context) {
    return TransactionPage();
  }
}
