import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paigun/page/components/loading_placeholder.dart';
import 'package:paigun/page/components/sizeappbar.dart';
import 'package:provider/provider.dart';

import '../../../provider/userinfo.dart';
import '../../components/loadingdialog.dart';

class DocVerify extends StatefulWidget {
  const DocVerify({super.key});

  @override
  State<DocVerify> createState() => _DocVerifyState();
}

class _DocVerifyState extends State<DocVerify> {
  final ImagePicker imgPicker = ImagePicker();

  bool _imageLoading = false;
  Map _doc = {};
  bool isLoading = true;
  bool citiUploaded = false;
  bool driverUploaded = false;
  bool taxUploaded = false;

  @override
  void initState() {
    getDoc();
    super.initState();
  }

  void getDoc() async {
    try {
      _doc = await context.read<UserInfo>().getDocument();
    } catch (e) {
      print(e);
    }
    citiUploaded = await _doc['citizen_url'] != null ? true : false;
    driverUploaded = await _doc['driver_url'] != null ? true : false;
    taxUploaded = await _doc['tax_url'] != null ? true : false;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SizeAppbar(
          context, 'Verfication', () => Navigator.pushNamed(context, '/home')),
      body: isLoading
          ? const LoadingPlaceholder()
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(children: [
                  Row(
                    children: [
                      Text(
                        "For passenger",
                        style: GoogleFonts.nunito(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        "Citizen ID card",
                        style: GoogleFonts.nunito(fontSize: 20),
                      ),
                    ],
                  ),
                  Container(
                    width: 360,
                    height: 226.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black26,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: citiUploaded
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.green,
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 40,
                                        )),
                                    Text(
                                      'Success',
                                      style: GoogleFonts.nunito(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary, //<-- SEE HERE
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.15,
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.camera_alt),
                                                      title:
                                                          const Text('Camera'),
                                                      onTap: () async {
                                                        final XFile? image =
                                                            await imgPicker.pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .camera);

                                                        if (image != null) {
                                                          setState(() {
                                                            _imageLoading =
                                                                true;
                                                          });
                                                          // ignore: use_build_context_synchronously
                                                          loadingDialog(
                                                              context,
                                                              _imageLoading,
                                                              'Uploading image');
                                                          await context
                                                              .read<UserInfo>()
                                                              .addDocument(
                                                                  image.path,
                                                                  "citizen");
                                                          setState(() {
                                                            _imageLoading =
                                                                false;
                                                            citiUploaded = true;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.photo),
                                                      title:
                                                          const Text('Gallery'),
                                                      onTap: () async {
                                                        final XFile? image =
                                                            await imgPicker.pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery);
                                                        if (image != null) {
                                                          setState(() {
                                                            _imageLoading =
                                                                true;
                                                          });

                                                          // ignore: use_build_context_synchronously
                                                          loadingDialog(
                                                              context,
                                                              _imageLoading,
                                                              'Uploading image');
                                                          await context
                                                              .read<UserInfo>()
                                                              .updateProfileImage(
                                                                  image.path);

                                                          setState(() {
                                                            _imageLoading =
                                                                false;
                                                            citiUploaded = true;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                    )
                                                  ],
                                                ),
                                              );
                                            });
                                      }
                                    },
                                  ),
                                )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Text(
                        "For driver",
                        style: GoogleFonts.nunito(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        "Driver license card",
                        style: GoogleFonts.nunito(fontSize: 20),
                      ),
                    ],
                  ),
                  Container(
                    width: 360,
                    height: 226.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black26,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: driverUploaded
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.green,
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 40,
                                        )),
                                    Text(
                                      'Success',
                                      style: GoogleFonts.nunito(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary, //<-- SEE HERE
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.15,
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.camera_alt),
                                                      title:
                                                          const Text('Camera'),
                                                      onTap: () async {
                                                        final XFile? image =
                                                            await imgPicker.pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .camera);

                                                        if (image != null) {
                                                          setState(() {
                                                            _imageLoading =
                                                                true;
                                                          });
                                                          // ignore: use_build_context_synchronously
                                                          loadingDialog(
                                                              context,
                                                              _imageLoading,
                                                              'Uploading image');
                                                          await context
                                                              .read<UserInfo>()
                                                              .addDocument(
                                                                  image.path,
                                                                  "driver");
                                                          setState(() {
                                                            _imageLoading =
                                                                false;
                                                            driverUploaded =
                                                                true;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.photo),
                                                      title:
                                                          const Text('Gallery'),
                                                      onTap: () async {
                                                        final XFile? image =
                                                            await imgPicker.pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery);
                                                        if (image != null) {
                                                          setState(() {
                                                            _imageLoading =
                                                                true;
                                                          });

                                                          // ignore: use_build_context_synchronously
                                                          loadingDialog(
                                                              context,
                                                              _imageLoading,
                                                              'Uploading image');
                                                          await context
                                                              .read<UserInfo>()
                                                              .updateProfileImage(
                                                                  image.path);

                                                          setState(() {
                                                            _imageLoading =
                                                                false;
                                                            driverUploaded =
                                                                true;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                    )
                                                  ],
                                                ),
                                              );
                                            });
                                      }
                                    },
                                  ),
                                )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        "Vehicle tax sign",
                        style: GoogleFonts.nunito(fontSize: 20),
                      ),
                    ],
                  ),
                  Container(
                    width: 360,
                    height: 226.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black26,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: taxUploaded
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.green,
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 40,
                                        )),
                                    Text(
                                      'Success',
                                      style: GoogleFonts.nunito(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary, //<-- SEE HERE
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.15,
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.camera_alt),
                                                      title:
                                                          const Text('Camera'),
                                                      onTap: () async {
                                                        final XFile? image =
                                                            await imgPicker.pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .camera);

                                                        if (image != null) {
                                                          setState(() {
                                                            _imageLoading =
                                                                true;
                                                          });
                                                          // ignore: use_build_context_synchronously
                                                          loadingDialog(
                                                              context,
                                                              _imageLoading,
                                                              'Uploading image');
                                                          await context
                                                              .read<UserInfo>()
                                                              .addDocument(
                                                                  image.path,
                                                                  "tax");
                                                          setState(() {
                                                            _imageLoading =
                                                                false;
                                                            taxUploaded = true;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(
                                                          Icons.photo),
                                                      title:
                                                          const Text('Gallery'),
                                                      onTap: () async {
                                                        final XFile? image =
                                                            await imgPicker.pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery);
                                                        if (image != null) {
                                                          setState(() {
                                                            _imageLoading =
                                                                true;
                                                          });

                                                          // ignore: use_build_context_synchronously
                                                          loadingDialog(
                                                              context,
                                                              _imageLoading,
                                                              'Uploading image');
                                                          await context
                                                              .read<UserInfo>()
                                                              .updateProfileImage(
                                                                  image.path);

                                                          setState(() {
                                                            _imageLoading =
                                                                false;
                                                            taxUploaded = true;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                    )
                                                  ],
                                                ),
                                              );
                                            });
                                      }
                                    },
                                  ),
                                )),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
    );
  }
}
