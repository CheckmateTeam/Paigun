import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:paigun/page/components/loading_placeholder.dart';
import 'package:paigun/page/components/sizeappbar.dart';
import 'package:paigun/page/components/styledialog.dart';
import 'package:paigun/page/passenger/components/routedetail.dart';
import 'package:paigun/provider/driver.dart';
import 'package:paigun/provider/passenger.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = false;

  void fetchRequestHistory() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<PassDB>().getReqeustJourneyHistory();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchRequestHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SizeAppbar(context, 'History',
          () => Navigator.pushReplacementNamed(context, '/home')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const LoadingPlaceholder()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'On Progress',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600]),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                        itemCount: context
                            .watch<PassDB>()
                            .journeyRequest
                            .where((e) {
                              return e['status'] != 'done';
                            })
                            .toList()
                            .length,
                        itemBuilder: (context, index) => journeyTile(
                                context.read<PassDB>().journeyRequest.where((element) => element['status'] != 'done').toList()[index]
                                    ['journey_id']['origin_province'],
                                context.read<PassDB>().journeyRequest.where((element) => element['status'] != 'done').toList()[index]
                                    ['journey_id']['destination_province'],
                                DateFormat('EEEE, dd MMMM yyyy').format(DateTime.parse(context
                                    .read<PassDB>()
                                    .journeyRequest
                                    .where((element) =>
                                        element['status'] != 'done')
                                    .toList()[index]['journey_id']['date'])),
                                context
                                    .read<PassDB>()
                                    .journeyRequest
                                    .where((element) => element['status'] != 'done')
                                    .toList()[index]['status'],
                                context, () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RouteDetail(
                                      info: context
                                          .read<PassDB>()
                                          .journeyRequest[index]['journey_id'],
                                      driver: context
                                              .read<PassDB>()
                                              .journeyRequest[index]
                                          ['journey_id']['owner'],
                                      status: context
                                          .read<PassDB>()
                                          .journeyRequest[index]['status'],
                                      from: "history",
                                    ),
                                  ));
                            }, context.read<PassDB>().journeyRequest[index]['journey_id']['owner']['avatar_url'])),
                  ),
                  Text(
                    'Success',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600]),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                        itemCount: context
                            .watch<PassDB>()
                            .journeyRequest
                            .where((e) {
                              return e['status'] == 'done';
                            })
                            .toList()
                            .length,
                        itemBuilder: (context, index) => journeyTile(
                            context.read<PassDB>().journeyRequest.where((e) {
                              return e['status'] == 'done';
                            }).toList()[index]['journey_id']['origin_province'],
                            context.read<PassDB>().journeyRequest.where((e) {
                              return e['status'] == 'done';
                            }).toList()[index]['journey_id']
                                ['destination_province'],
                            DateFormat('EEEE, dd MMMM yyyy').format(
                                DateTime.parse(context
                                    .read<PassDB>()
                                    .journeyRequest
                                    .where((e) {
                              return e['status'] == 'done';
                            }).toList()[index]['journey_id']['date'])),
                            'done',
                            context,
                            () {},
                            context.read<PassDB>().journeyRequest[index]
                                ['journey_id']['owner']['avatar_url'])),
                  ),
                ],
              ),
      ),
    );
  }
}

Widget journeyTile(String origin, String destination, String date,
    String status, BuildContext context, Function onTap, String driver) {
  return Column(
    children: [
      GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color.fromARGB(255, 238, 238, 238), width: 0.8)),
          child: ListTile(
              leading: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 224, 224, 224),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                width: 60,
                child: driver == ''
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          'assets/images/avatarmock.png',
                          width: 80,
                          height: 80,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          driver,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          width: 80,
                          height: 80,
                        ),
                      ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_sharp),
                      Text(
                        origin,
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.flag_rounded),
                      Text(
                        destination,
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Text(
                date,
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500]),
              ),
              trailing: status == 'pending'
                  ? waitingAccepted()
                  : status == 'accepted'
                      ? toPay()
                      : status == 'paid'
                          ? inTrip()
                          : status == 'going'
                              ? onGoing()
                              : status == 'done'
                                  ? doneJourney()
                                  : reviewPending()),
        ),
      ),
      const SizedBox(
        height: 10,
      )
    ],
  );
}

Widget reviewPending() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 132, 55, 255),
          child: Icon(
            Icons.rate_review_outlined,
            color: Colors.white,
          )),
      Text(
        'Review',
        style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 132, 55, 255)),
      ),
    ],
  );
}

Widget inTrip() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircleAvatar(
          backgroundColor: Colors.indigoAccent,
          child: Icon(
            Icons.wallet_travel_rounded,
            color: Colors.white,
          )),
      Text(
        'In trip',
        style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.indigoAccent),
      ),
    ],
  );
}

Widget onGoing() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircleAvatar(
          backgroundColor: Colors.indigoAccent,
          child: Icon(
            Icons.directions_car,
            color: Colors.white,
          )),
      Text(
        'On Going',
        style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.indigoAccent),
      ),
    ],
  );
}

Widget doneJourney() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircleAvatar(
          backgroundColor: Colors.greenAccent,
          child: Icon(
            Icons.check,
            color: Colors.white,
          )),
      Text(
        'Success',
        style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.greenAccent),
      ),
    ],
  );
}

Widget waitingAccepted() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(
            Icons.payment,
            color: Colors.white,
          )),
      Text(
        'Waiting',
        style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.blueAccent),
      ),
    ],
  );
}

Widget toPay() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircleAvatar(
          backgroundColor: Colors.orangeAccent,
          child: Icon(
            Icons.hourglass_top_outlined,
            color: Colors.white,
          )),
      Text(
        'To pay',
        style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.orangeAccent),
      ),
    ],
  );
}
