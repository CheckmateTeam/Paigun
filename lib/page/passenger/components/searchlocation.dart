import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/data/provinces.json');
    final data = await json.decode(response);
    setState(() {
      _province = data;
      _province = _province.map((e) {
        return e['provinceNameEn'];
      }).toList();
      _showProvince = _province;
    });
  }

  List _province = [];
  List _showProvince = [];
  @override
  void initState() {
    readJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.2,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0.8,
          bottomOpacity: 0.1,
          shadowColor: const Color.fromARGB(255, 255, 255, 255),
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context, _controller.text);
            },
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const TextField(
                showCursor: false,
                decoration: InputDecoration(
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
              const SizedBox(height: 10),
              TextField(
                controller: _controller,
                onChanged: (value) {
                  print(_province.length);
                  setState(() {
                    _showProvince = _province
                        .where((element) => element
                            .toString()
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
                decoration: const InputDecoration(
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
            ],
          ),
        ),
        body: Container(
          child: _showProvince.isNotEmpty
              ? ListView.builder(
                  itemCount: _showProvince.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        _controller.text = _showProvince[index].toString();
                      },
                      title: Text(_showProvince[index].toString()),
                    );
                  },
                )
              : Container(),
        ));
  }
}
