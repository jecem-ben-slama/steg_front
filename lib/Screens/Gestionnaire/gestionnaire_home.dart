import 'package:flutter/material.dart';

class GestionnaireHome extends StatelessWidget {
  const GestionnaireHome({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F0F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            //* Sidebar
            Container(
              width: screenWidth * 0.2,
              height: screenHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF0A2847),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  //* Logo
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.dashboard,
                      color: Color(0xFF0A2847),
                      size: 40,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    "Micon Protocol",
                    style: TextStyle(
                      fontSize: screenWidth * 0.02,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  //* Navigation Items
                  SidebarItem(icon: Icons.dashboard, label: "Dashboard"),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.015),

                  SidebarItem(icon: Icons.business, label: "Papers"),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.015),

                  SidebarItem(
                    icon: Icons.account_balance_wallet,
                    label: "Accounting and Finance",
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.015),

                  SidebarItem(icon: Icons.people, label: "Supervisors"),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.015),

                  SidebarItem(icon: Icons.access_time, label: "Attendance"),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.06),
                  SidebarItem(icon: Icons.logout, label: "Log Out"),
                ],
              ),
            ),
            const SizedBox(width: 24),
            //* Main Content
            Expanded(
              child: Column(
                children: [
                  //? Search Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 200),
                      SizedBox(
                        width: screenWidth * 0.4,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search here",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          "https://randomuser.me/api/portraits/men/1.jpg",
                        ),
                        radius: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  //? Stats sneek peek
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatCard(title: "Active Employee", value: "1081"),
                      StatCard(title: "Total Employee", value: "2,300"),
                      StatCard(title: "Total Task", value: "34"),
                      StatCard(title: "Attendance", value: "+91"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  //? Department Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DeptCard(title: "Manage Internships"),
                      DeptCard(title: "Manage Student"),
                      DeptCard(title: "Manage Subject"),
                      DeptCard(title: "Manage Supervisor"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  //? Attendance Table
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(
                            "Internships",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          DataTable(
                            columns: const [
                              DataColumn(label: Text("Student Name")),
                              DataColumn(label: Text("Subject")),
                              DataColumn(label: Text("Supervisor")),
                              DataColumn(label: Text("Type")),
                              DataColumn(label: Text("Start Date")),
                              DataColumn(label: Text("End Date")),
                              DataColumn(label: Text("Status")),
                              DataColumn(label: Text("Actions")),
                            ],
                            rows: [
                              attendanceRow(
                                "Syed Mahamudul Hasan",
                                "09:36",
                                "18:55",
                                "09hr 02min",
                                "45min",
                                "(+30min)",
                                "Late",
                              ),
                              attendanceRow(
                                "Kamrul Hasan",
                                "09:00",
                                "18:30",
                                "09hr 30min",
                                "1hr 05min",
                                "--",
                                "In time",
                              ),
                              // Add more rows as needed
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//! Sidebar item widget
class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const SidebarItem({super.key, required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: MediaQuery.of(context).size.width * 0.02,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(context).size.width * 0.01,
        ),
      ),
      onTap: () {},
    );
  }
}

//! Stat card widget
class StatCard extends StatelessWidget {
  final String title, value;
  const StatCard({super.key, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.13,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.black54)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Text("See More", style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }
}

//! Department card widget
class DeptCard extends StatelessWidget {
  final String title;
  const DeptCard({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.11,
      height: MediaQuery.of(context).size.height * 0.1,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

//! Attendance
DataRow attendanceRow(
  String name,
  String inTime,
  String outTime,
  String working,
  String breakTime,
  String extra,
  String status,
) {
  return DataRow(
    cells: [
      DataCell(Text(name)),
      DataCell(Text(inTime)),
      DataCell(Text(outTime)),
      DataCell(Text(working)),
      DataCell(Text(breakTime)),
      DataCell(Text(extra)),
      DataCell(
        Text(
          inTime,
          style: TextStyle(color: inTime == "Late" ? Colors.red : Colors.green),
        ),
      ),
      DataCell(
        Text(
          status,
          style: TextStyle(color: status == "Late" ? Colors.red : Colors.green),
        ),
      ),
    ],
  );
}
