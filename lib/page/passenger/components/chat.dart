import 'package:flutter/material.dart';

import '../../components/sizeappbar.dart';

class DriverChat extends StatefulWidget {
  const DriverChat({super.key});

  @override
  State<DriverChat> createState() => _DriverChat();
}

class _DriverChat extends State<DriverChat> {
  
  @override
  int currentChat = 1;

  
  List chatList = [
    {"Name":"Bobo","Message":"The question is in a way meaningless, she knows, but one must ask. Love in such situations is rarely real. Sex is the engine, exalting and ruining people, sex and frustration. Love is what people believe is worth the path of devastation."},
    {"Name":"Putang","Message":"Detail2"},
    {"Name":"Tango Mid","Message":"Detail3"},
    {"Name":"Anjing kara","Message":"Detail4"},
    {"Name":"Sugar","Message":"Detail5"},
    ];


  List chatListP = [
    {"Name":"Boboasdasdas","Message":"The question is in a way meaningless, she knows, but one must ask. Love in such situations is rarely real. Sex is the engine, exalting and ruining people, sex and frustration. Love is what people believe is worth the path of devastation."},
    {"Name":"Putangasdasdasd","Message":"Detail2"},
    {"Name":"Tango Midasdasd","Message":"Detail3"},
    {"Name":"Anjing karaasdasd","Message":"Detail4"},
    {"Name":"Sugarasdasd","Message":"Detail5"},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SizeAppbar(context, "Chat",
          () => Navigator.pushReplacementNamed(context, '/home')),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromARGB(255, 199, 199, 199)),
                      child: Row(
                        children: [
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color.fromARGB((currentChat == 1) ? 255 : 0,
                                      36, 70, 221)),
                            ),
                            onPressed: () {
                              setState(() {
                                currentChat = 1;
                              });
                            },
                            child: Text(
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                    color: (currentChat == 1)
                                        ? Colors.white
                                        : Colors.black),
                                "Driver"),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color.fromARGB((currentChat == 1) ? 0 : 255,
                                      36, 70, 221)),
                            ),
                            onPressed: () {
                              setState(() {
                                currentChat = 2;
                              });
                            },
                            child: Text(
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                    color: (currentChat == 1)
                                        ? Colors.black
                                        : Colors.white),
                                "Passenger"),
                          )
                        ],
                      )),
                ])),


                SizedBox(height:20,),


                Expanded(
                  child: ListView.builder(
                    itemCount: chatList.length,
                    itemBuilder: (context,index){
                      return chatBox((currentChat == 1)
                                        ? chatList[index]['Name'] : chatListP[index]['Name'],
                                      (currentChat == 1)
                                        ? chatList[index]['Message'] : chatListP[index]['Message']);
                    }))
          ],
        ),
      ),
    );
  }

  Widget chatBox(String name, String recentChat) {
    return 
    InkWell(child:
    Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color.fromARGB(139, 221, 221, 221)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 228, 228, 228),
            blurRadius: 1,
            offset: Offset(0, 0), // Shadow position
          ),
        ],
      ),

      //list start here

      child: 
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(right: 10),
              child: Image.asset("assets/images/journeyboardmock.png")),
          Expanded(child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
            Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16,
                ),
                ),
            Text(
                recentChat,
                style: const TextStyle(
                  fontWeight: FontWeight.w100,
                  color: Colors.black,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                )
          ]),)
          
        ],
      ),
    ),);
  }
}