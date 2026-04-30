import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Nearly/presentation/profile/profile_controller.dart';
import 'package:Nearly/shared/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w400),
        ),
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionTitle("Share"),
          _buildCard([
            _buildListItem("Follow us on Instagram"),
            _buildDivider(),
            _buildListItem("Invite friends"),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle("Show distance in"),
          _buildCard([
            _buildListItem("Kilometers"),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle("Notifications"),
          _buildCard([
            _buildListItem("Emails and notifications"),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle("Liked, Skipped and Blocked profiles"),
          _buildCard([
            _buildListItem("Liked profiles"),
            _buildDivider(),
            _buildListItem("Skipped profiles"),
            _buildDivider(),
            _buildListItem("Blocked profiles"),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle("About"),
          _buildCard([
            _buildListItem("About Rebounce"),
            _buildDivider(),
            _buildListItem("Terms of use"),
            _buildDivider(),
            _buildListItem("Privacy policy"),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle("Account"),
          _buildCard([
            _buildListItem("My orders"),
            _buildDivider(),
            _buildListItem("Account settings"),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle("Help"),
          _buildHelpCard(),

          const SizedBox(height: 40),
          
          // Log out button just in case, since Settings usually has it
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => Get.find<ProfileController>().logout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF0F0),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "Log Out",
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5FF), // Light purple background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Help and support",
                  style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w400),
                ),
                Icon(Icons.arrow_forward, size: 20, color: Colors.black87),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(String title) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w400),
              ),
              const Icon(Icons.arrow_forward, size: 20, color: Colors.black87),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFEEEEEE));
  }
}
