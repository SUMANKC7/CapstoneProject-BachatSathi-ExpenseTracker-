
import 'package:expensetrack/features/settings/widgets/setting_list_tile_widget.dart';
import 'package:expensetrack/features/settings/widgets/settings_title_text.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15,vertical: 10),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              SettingsTitleText(title: "Profile"),
              SettingsListTile(icon:Icons.person_2_outlined,title: "Personal Details",subtitle: "Manage your personal information", ),
              SettingsTitleText(title: "App Settings"),
              SettingsListTile(icon: Icons.light_mode_outlined, title: "Theme", subtitle: "Customize app appearance"),
              SettingsListTile(icon: Icons.notifications_outlined, title: "Notifications", subtitle: "Manage notification preferences"),
              SettingsListTile(icon: Icons.lock_outline_rounded, title: "Security", subtitle: "Configure security settings"),
              SettingsTitleText(title: "Data Management"),
              SettingsListTile(icon: Icons.picture_as_pdf_outlined, title: "Export to PDF", subtitle: "Export transactions to PDF"),
              SettingsListTile(icon: Icons.import_export_outlined, title: "Export to Excel", subtitle: "Export transactions to Excel")
            ],
          ),
        ),
      ),
    );
  }
}


