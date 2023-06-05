import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../components/sizeappbar.dart';

class Journeyboard extends StatelessWidget {
  const Journeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SizeAppbar(context, 'Journey board',
          () => Navigator.pushReplacementNamed(context, '/home')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: const EdgeInsets.all(5.0),
                  child: const TextField(
                    showCursor: false,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                      hintText: 'Current Location',
                      filled: true,
                      fillColor: Color.fromARGB(255, 240, 240, 240),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      prefixIcon:
                          Icon(Icons.location_pin, color: Colors.black54),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(5.0),
                  child: const TextField(
                    // controller: _controller,
                    // onChanged: (value) {
                    //   print(_province.length);
                    //   setState(() {
                    //     _showProvince = _province
                    //         .where((element) => element
                    //             .toString()
                    //             .toLowerCase()
                    //             .contains(value.toLowerCase()))
                    //         .toList();
                    //   });
                    // },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                      hintText: 'Destination',
                      filled: true,
                      fillColor: Color.fromARGB(255, 240, 240, 240),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      prefixIcon: Icon(
                        Icons.location_searching,
                        color: Colors.black54,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(5.0),
                  child: const TextField(
                    showCursor: false,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                      hintText: 'Current Location',
                      filled: true,
                      fillColor: Color.fromARGB(255, 240, 240, 240),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      prefixIcon:
                          Icon(Icons.access_time_filled, color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: List.generate(5, (index) {
                  return Center(
                      child: journeyTile(
                          faker.address.city(),
                          faker.address.city(),
                          faker.date.dateTime(),
                          'close'));
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget journeyTile(
    String origin, String destination, DateTime date, String status) {
  return 
      Container(
          width: 170,
          height: 170,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 0), // Shadow position
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  width: 50,
                  height: 50,
                  child: Image.asset("assets/images/journeyboardmock.png")),
              Row(
                children: [
                  const Icon(Icons.location_on_sharp),
                  Expanded(
                    child: Text(
                      origin,
                      style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.flag_rounded),
                  Expanded(
                    child: Text(
                      destination,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('D MMMM dd yyyy').format(date),
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500]),
              ),
            ],
          ));
    
  
}
