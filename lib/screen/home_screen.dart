import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgtstask/bloc/auth_bloc.dart';
import 'package:vgtstask/drawer.dart';
import 'package:vgtstask/model/branch.dart';
import 'package:vgtstask/model/gitHubRepository.dart';
import 'package:vgtstask/model/profile.dart';
import 'package:http/http.dart'as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.token}) : super(key: key);
  final String? token;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Profile> _profileFuture;
  late Future<List<GitHubRepository>> _repositoriesFuture;
  late Future<List<Branch>> _branchesFuture;
  late String _branches = "";
  late String userWoner = "";
  late String token = '';

  @override
  void initState() {
    super.initState();
    // final authCubit = BlocProvider.of<AuthCubit>(context);
    // token = authCubit.state!.getIdToken().toString();
    token = widget.token!;
    print("jana");
    print(token);
    _profileFuture = fetchGitHubProfile(widget.token!);
  }

  Future<Profile> fetchGitHubProfile(String token) async {
    final url = Uri.https('api.github.com', '/user');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final username = data['login'];
      setState(() {
        userWoner = username;
        _repositoriesFuture = fetchGitHubRepositories(token, username);
      });
      final profile = Profile.fromJson(data);
      return profile;
    } else {
      throw Exception('Failed to fetch GitHub profile details');
    }
  }

  Future<List<GitHubRepository>> fetchGitHubRepositories(String accessToken, String userName) async {
    final url = Uri.https('api.github.com', '/users/${userName}/repos');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        final data = json.decode(response.body) as List<dynamic>;

        final repositories = data.map((json) => GitHubRepository.fromJson(json)).toList();
        return repositories;
      } else {
        return []; // Return an empty list if the response body is empty
      }
    } else {
      throw Exception('Failed to fetch GitHub repository details');
    }
  }

  Future<List<Branch>> fetchGitHubBranches(String accessToken, String userName, String repo) async {
    final url = Uri.https('api.github.com', '/repos/$userName/$repo/branches');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        final data = json.decode(response.body) as List<dynamic>;
        final branches = data.map((json) => Branch.fromJson(json)).toList();
        return branches;
      } else {
        return []; // Return an empty list if the response body is empty
      }
    } else {
      throw Exception('Failed to fetch GitHub repository details');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _repositoriesFuture = fetchGitHubRepositories(token, userWoner);
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              authCubit.signOut(context);
            },
          ),
        ],
      ),
      drawer: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Drawer(); // Empty drawer while loading profile data
          } else if (snapshot.hasError) {
            return Drawer(); // Empty drawer on error
          } else {
            final dynamic profi = snapshot.data;
            return buildDrawer(context, profi); // Build drawer with fetched profile data
          }
        },
      ),
      body: FutureBuilder<List<GitHubRepository>>(
        future: _repositoriesFuture,
        builder: (BuildContext context, AsyncSnapshot<List<GitHubRepository>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching GitHub repositories'),
            );
          } else {
            final repositories = snapshot.data!;
            return ListView.builder(
              itemCount: repositories.length,
              itemBuilder: (BuildContext context, int index) {
                final repository = repositories[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    //set border radius more than 50% of height and width to make circle
                  ),
                  child: ListTile(
                    title: Text(repository.name),
                    subtitle: Text(repository.description),
                    onTap: () {
                      setState(() {
                        _branches = repository.name;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Branches'),
                            content: FutureBuilder<List<Branch>>(
                              future: fetchGitHubBranches(token, userWoner, repository.name),
                              builder: (BuildContext context, AsyncSnapshot<List<Branch>> snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    height: 100,
                                    width: double.maxFinite,
                                    child: Center(child: Text("Loading....")),
                                  );
                                } else if (snapshot.hasError) {
                                  return Container(
                                    height: 100,
                                    width: double.maxFinite,
                                    child: Center(child: Text('Error: ${snapshot.error}')),
                                  );
                                } else {
                                  final branches = snapshot.data;
                                  if (branches != null) {
                                    return Container(
                                      height: 100,
                                      width: double.maxFinite,
                                      child: ListView.builder(
                                        itemCount: branches.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(branches[index].name),
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    return Text('No branches found');
                                  }
                                }
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}