import 'package:expensetrack/core/appcolors.dart';
import 'package:flutter/material.dart';

class AddNewentity extends StatelessWidget {
  const AddNewentity({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController entityController = TextEditingController();
    final TextEditingController numberController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Add New Entity"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.info_outline))],
      ),
      body: Column(
        children: [
          SizedBox(height: 27),
          Center(
            child: CircleAvatar(
              backgroundColor: AppColors.filterColor,
              radius: 42,
              child: Icon(
                Icons.person_3,
                size: 50,
                color: AppColors.textTitleColor,
              ),
            ),
          ),
          SizedBox(height: 30),
          NewPartyField(
            labelText: 'Entity Name',
            keyboard: TextInputType.name,
            controller: entityController,
          ),
          SizedBox(height: 30),
          NewPartyField(
            labelText: 'Phone Number',
            keyboard: TextInputType.phone,
            controller: numberController,
          ),
        ],
      ),
    );
  }
}

class NewPartyField extends StatelessWidget {
  final String labelText;
  final TextInputType keyboard;
  final TextEditingController controller;
  const NewPartyField({
    super.key,
    required this.labelText,
    required this.keyboard,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
        // autofocus: true,
        keyboardType: keyboard,
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade400),
          enabled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green.shade300),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
