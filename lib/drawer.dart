import 'package:flutter/material.dart';
import 'package:vgtstask/model/profile.dart';

Drawer buildDrawer(BuildContext context, Profile profileData) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(profileData.img),
              ),
              SizedBox(height: 8),
              Text(
                profileData.username,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                profileData.username,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
        ),
        ListTile(
          title: Text('Profile'),
          onTap: () {
            // Handle profile tap
            Navigator.pop(context); // Close the drawer
            // Navigate to profile screen
          },
        ),
        ListTile(
          title: Text('Repositories'),
          onTap: () {
            // Handle repositories tap
            Navigator.pop(context); // Close the drawer
            // Navigate to repositories screen
          },
        ),
        ListTile(
          title: Text('Logout'),
          onTap: () {
            // signOut(context);
          },
        ),
      ],
    ),
  );
}