import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paigun/page/components/sizeappbar.dart';

class JourneyDetail extends StatefulWidget {
  const JourneyDetail(
      {Key? key,
      required this.origin,
      required this.destination,
      required this.date,
      required this.note,
      required this.profile})
      : super(key: key);
  final String origin;
  final String destination;
  final String date;
  final String note;
  final dynamic profile;
  @override
  _JourneyDetailState createState() => _JourneyDetailState();
}

class _JourneyDetailState extends State<JourneyDetail> {
  final int _rating = 3;
  @override
  void initState() {
    super.initState();
    //print(widget.profile['id']);
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Container(
              padding: const EdgeInsets.all(20),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: 80,
                      height: 80,
                      child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.profile['avatar_url']))),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.profile['full_name'],
                            style: GoogleFonts.nunito(
                              fontSize: 20,
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
                        widget.profile['username'].replaceRange(0, 2, '0'),
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          for (int i = 0; i < 5; i++)
                            i < _rating
                                ? const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  )
                                : const Icon(
                                    Icons.star,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                        ],
                      ),
                    ],
                  ),
                  IconButton.filled(
                      style: ElevatedButton.styleFrom(elevation: 1),
                      onPressed: () {},
                      icon: const Icon(Icons.chat))
                ],
              )),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const Icon(Icons.location_on_sharp),
              Expanded(
                child: Text(
                  widget.origin,
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Icon(Icons.flag_rounded),
              Expanded(
                child: Text(
                  widget.destination,
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Icon(Icons.calendar_month),
              Expanded(
                child: Text(
                  widget.date,
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Divider(),
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("*", style: TextStyle(color: Colors.red)),
              Expanded(
                child: Text(
                  widget.note,
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}
