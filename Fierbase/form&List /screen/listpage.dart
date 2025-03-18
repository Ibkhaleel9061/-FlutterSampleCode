import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersListPage extends StatelessWidget {
  const UsersListPage({super.key});

  void _showEditDialog(
    BuildContext context,
    String docId,
    String name,
    String address,
    String phone,
  ) {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController addressController = TextEditingController(
      text: address,
    );
    TextEditingController phoneController = TextEditingController(text: phone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(docId)
                      .update({
                        'name': nameController.text,
                        'address': addressController.text,
                        'phone': phoneController.text,
                      });

                  if (Navigator.canPop(context)) {
                    // ✅ Check if dialog can be closed
                    Navigator.pop(context);
                  }
                } catch (error) {
                  print("Error updating user: $error");
                }
              },

              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Users List")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .orderBy('timestamp', descending: true) // Order by latest
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching data"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final items = snapshot.data!.docs;

          return ListView.separated(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index].data() as Map<String, dynamic>;
              final docId = items[index].id; // Document ID for editing

              return ListTile(
                leading: CircleAvatar(
                  child: Text(item["name"]?[0] ?? "?"), // First letter of name
                ),
                title: Text(item["name"] ?? "No Name"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item["address"] ?? "No Address"),
                    Text(item["phone"] ?? "No Phone"),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed:
                          () => _showEditDialog(
                            context,
                            docId,
                            item["name"] ?? "",
                            item["address"] ?? "",
                            item["phone"] ?? "",
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(docId)
                            .delete();
                      },
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(),
          );
        },
      ),
    );
  }
}
