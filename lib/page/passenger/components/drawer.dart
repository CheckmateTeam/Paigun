import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paigun/provider/userinfo.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  bool _isVerified = true;
  var faker = Faker();

  final List<Map<String, dynamic>> _items = [
    {
      'icon': Icons.home,
      'name': 'Home',
      'path': 'home',
    },
    {
      'icon': Icons.chat_outlined,
      'name': 'Chat',
      'path': 'chat',
    },
    {
      'icon': Icons.history,
      'name': 'History',
      'path': 'history',
    },
    {
      'icon': Icons.notifications_none_outlined,
      'name': 'Notification',
      'path': 'notification',
    },
    {
      'icon': Icons.dashboard_outlined,
      'name': 'Journey board',
      'path': 'journeyboard',
    },
    {
      'icon': Icons.car_repair_outlined,
      'name': 'Driver mode',
      'path': 'driver',
    },
    {
      'icon': Icons.info_outline,
      'name': 'How to use?',
      'path': 'howtouse',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: DrawerHeader(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/avatarmock.png',
                        width: 100,
                        height: 100,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phawit Monchai...',
                            style: GoogleFonts.nunito(
                                fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '080-964-5125',
                            style: GoogleFonts.nunito(
                                fontSize: 16, fontWeight: FontWeight.normal),
                          ),
                          _isVerified
                              ? const Row(
                                  children: [
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
                                    ),
                                    Icon(
                                      Icons.verified_rounded,
                                      color: Colors.green,
                                    )
                                  ],
                                )
                              : const Row(
                                  children: [
                                    Text(
                                      'Unverified',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent),
                                    ),
                                    Icon(
                                      Icons.dangerous_rounded,
                                      color: Colors.redAccent,
                                    )
                                  ],
                                ),
                          const Row(
                            children: [
                              Text('Verify now? ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text('Click here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ))
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  Center(
                      child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ))
                ],
              ),
            ),
          ),
          ..._items
              .map((item) => menuTile(Icon(item['icon']), item['name'],
                  item['path'], context, _isVerified))
              .toList(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: () {
                context.read<UserInfo>().signOut(context);
              },
              child: const Text(
                'Sign out',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)))),
            ),
          )
        ],
      ),
    );
  }
}

Widget menuTile(Icon icon, String title, String path, BuildContext context,
    bool isVerified) {
  if (title == 'Driver mode' && !isVerified) {
    return ListTile(
      title: Row(
        children: [
          const Icon(
            Icons.car_repair_outlined,
            color: Colors.grey,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      ),
      trailing: const Icon(
        Icons.lock,
        color: Colors.grey,
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Unverified'),
                  content: const Text(
                      'Please verify your account before using this feature.'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'))
                  ],
                ));
      },
    );
  }
  return ListTile(
    title: Row(
      children: [
        icon,
        const SizedBox(
          width: 10,
        ),
        Text(title)
      ],
    ),
    onTap: () {
      Navigator.of(context).pushReplacementNamed('/$path');
    },
  );
}
