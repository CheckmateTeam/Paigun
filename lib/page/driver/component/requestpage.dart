// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:paigun/page/components/loadingdialog.dart';
import 'package:paigun/page/components/sizeappbar.dart';
import 'package:paigun/page/components/styledialog.dart';
import 'package:paigun/provider/driver.dart';
import 'package:paigun/provider/passenger.dart';
import 'package:provider/provider.dart';

import '../../../provider/userinfo.dart';
import '../../passenger/components/chatmessage.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    var item = context.watch<DriveDB>().requestJourney;
    return Scaffold(
      appBar: SizeAppbar(context, 'New Request', () => Navigator.pop(context)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 250, 250, 250),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(192, 0, 0, 0),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 150, horizontal: 10),
        child: Swiper(
          containerHeight: MediaQuery.of(context).size.height,
          itemBuilder: ((context, index) {
            return Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      offset: Offset(0, 3),
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 224, 224, 224),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                  ),
                                ],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                              width: 70,
                              height: 70,
                              child: item[index]['user_id'].isEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.asset(
                                        'assets/images/avatarmock.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : item[index]['user_id']['avatar_url'] == ''
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.asset(
                                            'assets/images/avatarmock.png',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.network(
                                            item[index]['user_id']
                                                    ['avatar_url'] ??
                                                '',
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                            width: 100,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item[index]['user_id'].isEmpty
                                          ? 'Loading...'
                                          : item[index]['user_id']['full_name']
                                                      .length >
                                                  15
                                              ? '${item[index]['user_id']['full_name'].toString().substring(0, 14)}...'
                                              : item[index]['user_id']
                                                  ['full_name'],
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    const Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 20,
                                    )
                                  ],
                                ),
                                Text(
                                  item[index]['user_id'].isEmpty
                                      ? 'Loading...'
                                      : 'Tel: 0${item[index]['user_id']['username'].toString().substring(2) ?? ''}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            IconButton.filled(
                                style: ElevatedButton.styleFrom(elevation: 1),
                                onPressed: () async {
                                  String user1 = UserInfo().user!.id;
                                  String user2 = item[index]['id'];
                                  String room_id = await context.read<PassDB>().gotoRoom(user1,user2);
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                      return ChatRoomMessage(
                                      room_id: room_id,
                                      title: item[index]['full_name'],
                                    );
                                  }));
                                },
                                icon: const Icon(Icons.chat))
                          ],
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text('From',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                )),
                            Text(
                                item[index]['journey_id']['origin_province']
                                        .toString()
                                        .contains("Chang Wat")
                                    ? item[index]['journey_id']
                                            ['origin_province']
                                        .toString()
                                        .split("Chang Wat ")[1]
                                    : item[index]['journey_id']
                                        ['origin_province'],
                                style: GoogleFonts.nunito(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        const Icon(
                          Icons.arrow_right_alt_rounded,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          children: [
                            Text('To',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                )),
                            Text(
                                item[index]['journey_id']
                                            ['destination_province']
                                        .toString()
                                        .contains("Chang Wat")
                                    ? item[index]['journey_id']
                                            ['destination_province']
                                        .toString()
                                        .split("Chang Wat ")[1]
                                    : item[index]['journey_id']
                                        ['destination_province'],
                                style: GoogleFonts.nunito(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Send request since',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                )),
                            const SizedBox(
                              width: 3,
                            ),
                            Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                        Text(
                            DateFormat("EEEE, dd MMMM yyyy, HH:mm a")
                                .format(DateTime.parse(item[index]['create_at'])
                                    .toLocal())
                                .toString(),
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Accept Request'),
                                          content: const Text(
                                              'Are you sure to accept this request?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel')),
                                            TextButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    _isLoading = true;
                                                  });
                                                  loadingDialog(
                                                      context,
                                                      _isLoading,
                                                      'Accepting request...');
                                                  await context
                                                      .read<DriveDB>()
                                                      .driverAcceptedRequest(
                                                          item[index]
                                                                  ['journey_id']
                                                              ['journey_id'],
                                                          item[index]['user_id']
                                                              ['id']);
                                                  await context
                                                      .read<DriveDB>()
                                                      .getDriverJourney();

                                                  setState(() {
                                                    _isLoading = false;
                                                  });

                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return StyleDialog(
                                                            context,
                                                            'Hooray!',
                                                            'You have one more friend join the trip !',
                                                            'Back', () {
                                                          Navigator
                                                              .pushNamedAndRemoveUntil(
                                                                  context,
                                                                  '/driver',
                                                                  (route) =>
                                                                      false);
                                                        });
                                                      });
                                                },
                                                child: const Text('Accept')),
                                          ],
                                        );
                                      });
                                },
                                child: Text('Accept',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )))),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: Colors.redAccent, width: 1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Decline Request'),
                                          content: const Text(
                                              'Are you sure to decline this request?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel')),
                                            TextButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    _isLoading = true;
                                                  });
                                                  loadingDialog(
                                                      context,
                                                      _isLoading,
                                                      'Declining request...');
                                                  await context
                                                      .read<PassDB>()
                                                      .setUserRequest(
                                                          'decline',
                                                          item[index]
                                                                  ['journey_id']
                                                              ['journey_id']);
                                                  await context
                                                      .read<DriveDB>()
                                                      .getDriverJourney();

                                                  setState(() {
                                                    _isLoading = false;
                                                  });

                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return StyleDialog(
                                                            context,
                                                            'Declined!',
                                                            'You have declined this request.',
                                                            'Back', () {
                                                          Navigator
                                                              .pushNamedAndRemoveUntil(
                                                                  context,
                                                                  '/driver',
                                                                  (route) =>
                                                                      false);
                                                        });
                                                      });
                                                },
                                                child: const Text('Decline')),
                                          ],
                                        );
                                      });
                                },
                                child: Text('Decline',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    )))),
                      ],
                    )
                  ],
                ));
          }),
          itemCount: context.read<DriveDB>().requestJourney.length,
          pagination: SwiperPagination(
              builder: DotSwiperPaginationBuilder(
            color: Colors.grey[400],
            activeColor: Theme.of(context).primaryColor,
            size: 12,
            activeSize: 16,
          )),
          control: const SwiperControl(),
        ),
      ),
    );
  }
}
