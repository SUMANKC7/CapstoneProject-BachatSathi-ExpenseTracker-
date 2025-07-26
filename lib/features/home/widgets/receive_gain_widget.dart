import 'package:flutter/material.dart';

class RecieveGive extends StatelessWidget {
  final String amount;
  final String account;
  final GestureTapCallback onClicked;
  const RecieveGive({super.key, required this.amount, required this.account, required this.onClicked});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onClicked,
          child: Container(
            height: MediaQuery.sizeOf(context).height * 0.10,
            width: MediaQuery.sizeOf(context).width * 0.42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.only(left: 13, top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(account),
                ],
              ),
            ),
          ),
        ),
    
        Positioned(
          top: 27,
          right: 8,
          child: Icon(Icons.chevron_right_outlined),
        ),
      ],
    );
  }
}