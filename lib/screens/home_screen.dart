import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:random_people_fluttering/repositories/repositories.dart';
import 'package:random_people_fluttering/theme.dart';

import './screens.dart';
import '../constant.dart';
import '../models/models.dart';
import '../shared/widgets/loader.dart';

class HomeController {
  final UserRepository _userRepository = UserRepository();

  // Getting all users data in form of list
  Future<List<User>> fetchUserData() {
    return _userRepository.getUser();
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final HomeController _homeController = HomeController();
  AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _fadeController.forward();
  }

  // AppBar
  Widget _buildAppBar() {
    final _themeChanger = Provider.of<ThemeChanger>(context);

    Icon themeIcon = Icon(
      WeatherIcons.wi_day_sunny,
      size: space * 3,
    );
    if (_themeChanger.getThemeMode() == 'light') {
      themeIcon = Icon(
        FontAwesome.moon_o,
        size: space * 3,
      );
    } else if (_themeChanger.getThemeMode() == 'dark') {
      themeIcon = Icon(
        WeatherIcons.wi_day_sunny,
        size: space * 3,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(MaterialCommunityIcons.menu, size: space * 3),
        IconButton(
          onPressed: () {
            _themeChanger.toggleTheme();
          },
          icon: themeIcon,
          iconSize: space,
        ),
      ],
    );
  }

  // App info
  Widget _buildAppInfo() {
    return FadeTransition(
      opacity: _fadeController.drive(CurveTween(curve: Curves.easeOut)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: space * 2),
          Text('Random', style: Theme.of(context).textTheme.headline1),
          Text('People', style: Theme.of(context).textTheme.headline1),
          Text('Fluttering', style: Theme.of(context).textTheme.headline1),
          SizedBox(height: space * 2),
          Text(
            'Random user api used for generating random user data',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }

  Widget _buildUserThumbnail(String photoUrl, int id) {
    return Hero(
      tag: 'user_img$id',
      child: Container(
        padding: EdgeInsets.all(space),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(space),
        ),
        child: Image(
          image: NetworkImage(photoUrl),
          height: space * 6,
          width: space * 6,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildUserInfo(String username, String country) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: space * 20,
          child: Text(
            username,
            style: Theme.of(context).textTheme.headline2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: space),
        Row(
          children: [
            Icon(FontAwesome.location_arrow),
            SizedBox(width: space),
            Container(
              child: Text(
                country,
                style: Theme.of(context).textTheme.bodyText2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserListView() {
    return Expanded(
      child: FutureBuilder<List<User>>(
        future: _homeController.fetchUserData(),
        builder: (context, snapshot) {
          List<User> users = snapshot.data;

          if (users == null) {
            return Loader();
          }

          return ListView.builder(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      id: index,
                      username: users[index].getFullname(),
                      userImg: users[index].userLargeImg,
                      location: users[index].getLocation(),
                      email: users[index].email,
                      age: users[index].age,
                      phoneNum: users[index].phoneNum,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(boxShadow: [shadow]),
                child: Card(
                  color: Theme.of(context).accentColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildUserThumbnail(users[index].userThumbnail, index),
                      _buildUserInfo(
                          users[index].getFullname(), users[index].country),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Container(
          height: size.height,
          padding: EdgeInsets.symmetric(
            horizontal: space * 2,
            vertical: space * 2,
          ),
          child: Column(
            children: [
              _buildAppBar(),
              SizedBox(height: space),
              _buildAppInfo(),
              Divider(
                height: space * 8,
                color: Theme.of(context).accentColor,
                thickness: 4,
              ),
              _buildUserListView(),
            ],
          ),
        ),
      ),
    );
  }
}
