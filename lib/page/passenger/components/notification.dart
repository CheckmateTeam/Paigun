import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import '../../components/sizeappbar.dart';

class PaiNotification extends StatefulWidget {
  const PaiNotification({super.key});

  @override
  State<PaiNotification> createState() => _PaiNotification();
}

class _PaiNotification extends State<PaiNotification> {
  @override
  
  List notiList = [
    {"Header":"test1","Detail":"Detail1","isCheck":false},
    {"Header":"test2","Detail":"Detail2","isCheck":false},
    {"Header":"test3","Detail":"Detail3","isCheck":false},
    {"Header":"test4","Detail":"Detail4","isCheck":false},
    {"Header":"test5","Detail":"Detail5","isCheck":false},
    ];

  List olderList = [
    {"Header":"test1","Detail":"Detail1","isCheck":false},
    {"Header":"test2","Detail":"Detail2","isCheck":false},
    {"Header":"test3","Detail":"Detail3","isCheck":false},
    {"Header":"test4","Detail":"Detail4","isCheck":false},
    {"Header":"test5","Detail":"Detail5","isCheck":false},
    ];

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SizeAppbar(context, 'Notification',
            () => Navigator.pushReplacementNamed(context, '/home')),
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: ListView(children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(style: TextStyle(color: Colors.grey), "Today"),
                    Text(
                        style: TextStyle(
                            color: Color.fromARGB(255, 3, 7, 255),
                            fontWeight: FontWeight.w600),
                        "Mark as all read"),
                  ],
                ),




                Divider(
                  color: Colors.grey,
                ),
                SizedBox(height: 8.0),





                Expanded(
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: notiList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                            margin: EdgeInsets.only(bottom: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Color.fromARGB(139, 221, 221, 221)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromARGB(255, 228, 228, 228),
                                  blurRadius: 5,
                                  offset: Offset(0, 0), // Shadow position
                                ),
                              ],
                            ),


                            //list start here

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          notiList[index]['Header'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          ),
                                      Text(
                                          notiList[index]['Detail'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w100,
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                          )
                                    ]),
                                Checkbox(
                                    value: notiList[index]['isCheck'],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        notiList[index]['isCheck'] = value!;
                                      });
                                    })
                              ],
                            ),
                          );
                        })),
                        


                        SizedBox(height: 20.0),
                        // after this is older

                        const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(style: TextStyle(color: Colors.grey), "Older"),
                  ],
                ),




                Divider(
                  color: Colors.grey,
                ),
                SizedBox(height: 8.0),




                Expanded(
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: olderList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                            margin: EdgeInsets.only(bottom: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Color.fromARGB(139, 221, 221, 221)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromARGB(255, 228, 228, 228),
                                  blurRadius: 1,
                                  offset: Offset(0, 0), // Shadow position
                                ),
                              ],
                            ),


                            //list start here

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          "Header"),
                                      Text(
                                          style: TextStyle(
                                            fontWeight: FontWeight.w100,
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                          "Detail")
                                    ]),
                                Checkbox(
                                    value: olderList[index]['isCheck'],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        olderList[index]['isCheck'] = value!;
                                      });
                                    })
                              ],
                            ),
                          );
                        })),


              SizedBox(height: 50.0),
                
                        
              ])),

              
            ],
          ),
        ));
  }



  
}
