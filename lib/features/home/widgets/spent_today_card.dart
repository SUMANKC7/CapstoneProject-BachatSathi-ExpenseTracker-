import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';

class SpentTodayCard extends StatelessWidget {
  const SpentTodayCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
       Container(
        height: MediaQuery.sizeOf(context).height*0.22,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/pic.jpg"),fit: BoxFit.cover),
          // color: AppColors.greenAccent,
          borderRadius: BorderRadius.circular(10)
        ),
       ),
       Positioned(
        bottom: 15,
        left: 20,
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text("Spent today",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: AppColors.cardWhite,),),
             SizedBox(height: 7,),
             Text("\$120",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color: AppColors.cardWhite,),),
           ],
         ),
       )
      ],
    );
  }
}