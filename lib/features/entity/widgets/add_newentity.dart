import 'package:flutter/material.dart';

class AddNewentity extends StatefulWidget {
  const AddNewentity({super.key});

  @override
  State<AddNewentity> createState() => _AddNewentityState();
}

class _AddNewentityState extends State<AddNewentity> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _toggleKey = GlobalKey();
  double _togglePosition = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveTogglePosition();
    });
  }

  void _saveTogglePosition() {
    final renderBox =
        _toggleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _togglePosition = renderBox.localToGlobal(Offset.zero).dy;
      });
    }
  }

  void _scrollToToggle() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _togglePosition - MediaQuery.of(context).padding.top - kToolbarHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Add New Entity"),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 10,
        ),
        child: Column(
          children: [
            const SizedBox(height: 27),
            Center(
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 42,
                child: const Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 30),
            NewPartyField(
              labelText: 'Entity Name',
              keyboard: TextInputType.name,
              onTap: _scrollToToggle,
            ),
            const SizedBox(height: 20),
            NewPartyField(
              labelText: 'Phone Number',
              keyboard: TextInputType.phone,
              onTap: _scrollToToggle,
            ),
            const SizedBox(height: 25),
            // This is the widget we want to keep at top
            IncomeExpenseToggle(
              key: _toggleKey,
              firstIndex: 'Amount Info',
              secondIndex: 'Additional Details',
            ),
            // Rest of your content...
            NewPartyField(
              labelText: "Entity Email",
              keyboard: TextInputType.emailAddress,
              onTap: _scrollToToggle,
            ),
            NewPartyField(
              labelText: "Entity Address",
              keyboard: TextInputType.text,
              onTap: _scrollToToggle,
            ),
          ],
        ),
      ),
    );
  }
}

class NewPartyField extends StatelessWidget {
  final String labelText;
  final TextInputType keyboard;
  final VoidCallback? onTap;

  const NewPartyField({
    super.key,
    required this.labelText,
    required this.keyboard,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
        keyboardType: keyboard,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class IncomeExpenseToggle extends StatelessWidget {
  final String firstIndex;
  final String secondIndex;

  const IncomeExpenseToggle({
    super.key,
    required this.firstIndex,
    required this.secondIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blue[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [Text(firstIndex), Text(secondIndex)],
      ),
    );
  }
}
