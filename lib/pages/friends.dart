import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../appbar/appbar.dart';
import '../functions/get_credentials.dart';
import '../styles.dart';

class PlaceMeFriendsPage extends StatefulWidget {
  const PlaceMeFriendsPage({super.key});

  @override
  State<PlaceMeFriendsPage> createState() => _PlaceMeFriendsPageState();
}

class _PlaceMeFriendsPageState extends State<PlaceMeFriendsPage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<ApplicationState>(context).currentUser;

    return Scaffold(
      appBar: const PlaceMeAppbar(title: 'Find Friends'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('uid', isNotEqualTo: currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index].data() as Map<String, dynamic>;
                final name = user['displayName'] ?? 'No Name'; // Handle missing name
                final dep = user['departmentID'] ?? 0; // Handle missing name
                final photoUrl = user['photoURL'] ?? ''; // Handle missing photoURL

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(photoUrl),
                    backgroundColor: Colors.grey, // Default color if no image
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name),
                      if (dep==0) const Text('') else Text(getDepartment(dep), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // FirebaseFirestore.instance
                      //     .collection('users')
                      //     .doc(currentUser.uid)
                      //     .set(<String, FieldValue>{
                      //   'friendsCount' : FieldValue.increment(1),
                      // }, SetOptions(merge: true));
                    },
                    style: AppStyles.buttonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all<Color>(AppStyles.thistleColor),
                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                        textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(
                          fontSize: 12,
                        )
                        ),
                        padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
                    ),
                    child: const Text('Add Friend'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}