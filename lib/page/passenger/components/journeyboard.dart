import 'package:flutter/material.dart';

class Journeyboard extends StatelessWidget {
  const Journeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter layout demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter layout demo'),
        ),
        body: const Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextField(
                showCursor: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  hintText: 'Current Location',
                  filled: true,
                  fillColor: Color.fromARGB(255, 240, 240, 240),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  prefixIcon:
                      Icon(Icons.location_pin, color: Colors.blueAccent),
                ),
              ),
              TextField(
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
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  hintText: 'Destination',
                  filled: true,
                  fillColor: Color.fromARGB(255, 240, 240, 240),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  prefixIcon: Icon(
                    Icons.location_searching,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
              ),
              TextField(
                showCursor: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 15),  
                  hintText: 'Current Location',
                  filled: true,
                  fillColor: Color.fromARGB(255, 240, 240, 240),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  prefixIcon:
                      Icon(Icons.location_pin, color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        
      ),
    );
  }
}