import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paigun/page/components/loading_placeholder.dart';
import 'package:paigun/page/components/loadingdialog.dart';
import 'package:paigun/provider/userinfo.dart';
import 'package:provider/provider.dart';

import '../../../provider/passenger.dart';
import '../../components/styledialog.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer(
      {super.key,
      required this.isUserVerified,
      required this.isDriverVerified,
      required this.isGotCheck});
  final bool isDriverVerified;
  final bool isUserVerified;
  final bool isGotCheck;

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
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
  void initState() {
    super.initState();
    setState(() {});
    // Provider.of<DriveDB>(context, listen: false).getDriverJourney();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: UserProfile(
                isUserVerified: widget.isUserVerified,
                isGotCheck: widget.isGotCheck,
              )),
          ..._items
              .map((item) => menuTile(Icon(item['icon']), item['name'],
                  item['path'], context, widget.isDriverVerified))
              .toList(),
              // .map((item) => menuTile(
              //     Icon(item['icon']),
              //     item['name'],
              //     item['path'],
              //     context,
              //     context.watch<UserInfo>().userinfo['verified']))
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: () {
                context.read<UserInfo>().signOut(context);
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)))),
              child: const Text(
                'Sign out',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class UserProfile extends StatefulWidget {
  const UserProfile(
      {super.key, required this.isUserVerified, required this.isGotCheck});
  final bool isUserVerified;
  final bool isGotCheck;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  TextEditingController _firstname = TextEditingController();
  TextEditingController _lastname = TextEditingController();
  bool _imageLoading = false;
  var faker = Faker();
  @override
  Widget build(BuildContext context) {
    final ImagePicker imgPicker = ImagePicker();
    return DrawerHeader(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.15,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Camera'),
                                onTap: () async {
                                  final XFile? image = await imgPicker
                                      .pickImage(source: ImageSource.camera);

                                  if (image != null) {
                                    setState(() {
                                      _imageLoading = true;
                                    });
                                    // ignore: use_build_context_synchronously
                                    loadingDialog(context, _imageLoading,
                                        'Uploading image');
                                    await context
                                        .read<UserInfo>()
                                        .updateProfileImage(image.path);
                                    setState(() {
                                      _imageLoading = false;
                                    });
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo),
                                title: const Text('Gallery'),
                                onTap: () async {
                                  final XFile? image = await imgPicker
                                      .pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    setState(() {
                                      _imageLoading = true;
                                    });

                                    // ignore: use_build_context_synchronously
                                    loadingDialog(context, _imageLoading,
                                        'Uploading image');
                                    await context
                                        .read<UserInfo>()
                                        .updateProfileImage(image.path);

                                    setState(() {
                                      _imageLoading = false;
                                    });
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  }
                                },
                              )
                            ],
                          ),
                        );
                      });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: [
                    '',
                    null,
                  ].contains(context.read<UserInfo>().userinfo['avatar_url'])
                      ? Image.asset(
                          'assets/images/avatarmock.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          context.watch<UserInfo>().userinfo['avatar_url'],
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.watch<UserInfo>().userinfo['full_name'].toString(),
                    style: GoogleFonts.nunito(
                        fontSize: context
                                    .watch<UserInfo>()
                                    .userinfo['full_name']
                                    .toString()
                                    .length >
                                12
                            ? 15
                            : 20,
                        fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '0${context.watch<UserInfo>().userinfo['username'].toString().substring(2)}',
                    style: GoogleFonts.nunito(
                        fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                  context.watch<UserInfo>().doc['citizen_url'] != null
                  //context.watch<UserInfo>().userinfo['verified']
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
                  context.watch<UserInfo>().doc['citizen_url'] != null
                  //context.watch<UserInfo>().userinfo['verified']
                      ? const SizedBox()
                      : Row(
                          children: [
                            const Text('Verify now? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/docverify');
                              },
                              child: const Text('Click here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  )),
                            )
                          ],
                        )
                ],
              )
            ],
          ),
          Center(
              child: InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Edit Profile'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('For the profile picture,'),
                                  Text('edit by tap the profile picture'),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _firstname,
                            decoration: const InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: 'Firstname',
                                border: OutlineInputBorder()),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _lastname,
                            decoration: const InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: 'Lastname',
                                border: OutlineInputBorder()),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () {
                              context.read<UserInfo>().updateUsername(
                                  "${_firstname.text} ${_lastname.text}");
                              Navigator.of(context).pop();
                            },
                            child: const Text('Save')),
                      ],
                    );
                  });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
            ),
          ))
        ],
      ),
    );
  }
}

Widget menuTile(Icon icon, String title, String path, BuildContext context,
    bool isVerified) {
  if (title == 'Driver mode' &&
      (context.watch<UserInfo>().doc['driver_url'] == null ||
          context.watch<UserInfo>().doc['tax_url'] == null)) {
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
        // showDialog(
        //     context: context,
        //     builder: (context) => AlertDialog(
        //           title: const Text('Unverified'),
        //           content: const Text(
        //               'Please verify your account before using this feature.'),
        //           actions: [
        //             TextButton(
        //                 onPressed: () {
        //                   Navigator.of(context).pop();
        //                 },
        //                 child: const Text('OK'))
        //           ],
        //         ));
        showDialog(
            context: context,
            builder: (context) => StyleDialog(
                context,
                'Driver mode is lock.',
                'Your profile need to verify more documents to unlock the Driver mode',
                'Verify now',
                () => Navigator.pushNamed(context, '/docverify')));
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
