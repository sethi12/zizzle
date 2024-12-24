import 'package:flutter/material.dart';

import '../utils/colors.dart';
class MonthlyTransaction extends StatefulWidget {
  const MonthlyTransaction({super.key});

  @override
  State<MonthlyTransaction> createState() => _MonthlyTransactionState();
}

class _MonthlyTransactionState extends State<MonthlyTransaction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: mobileBackgroundColor,),
      body: Center(child: Text("You Have Received maximum Amount of this Month"),),
    );
  }
}
