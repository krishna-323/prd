import 'package:flutter/material.dart';


import '../inward/inward_list.dart';
import '../outward/outward_list.dart';
import '../utils/custom_appbar.dart';
import '../utils/custom_drawer.dart';
import '../utils/custom_loader.dart';

class HomeScreen extends StatefulWidget {
  final double drawerWidth;
  final double selectedDestination;
  final String plantValue;
  const HomeScreen({
    required this.drawerWidth,
    required this.selectedDestination,
    required this.plantValue,
    super.key
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool loading = false;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomDrawer(widget.drawerWidth, widget.selectedDestination, widget.plantValue),
          const VerticalDivider(width: 1,thickness: 1),
          Expanded(
              child: Scaffold(
                body: CustomLoader(
                  inAsyncCall: loading,
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>  InwardList(
                                    drawerWidth: widget.drawerWidth,
                                    selectedDestination: 1,
                                    plantValue: widget.plantValue,
                                  ),
                                )
                            );
                          },
                          child: Card(
                              color: Colors.transparent,
                              elevation: 4,
                              child: Container(
                                height: 130,
                                width: 300,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    topLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 20.0, top: 20),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 55,
                                                padding: const EdgeInsets.all(10),
                                                decoration: const BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(5))),
                                                child: const Icon(Icons.inventory,color: Colors.white),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Flexible(
                                                        child: Text(
                                                            "Inward",
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              color: Colors.grey[800],
                                                              fontSize: 20,
                                                            )
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffF9FAFB),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                        border: Border.all(
                                          width: 3,
                                          color: Colors.transparent,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: 16, top: 8, bottom: 4),
                                            child: Icon(
                                              Icons.arrow_forward,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        ),
                        // InkWell(
                        //   onTap: () {
                        //     Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) =>  OutwardList(
                        //       drawerWidth: widget.drawerWidth,
                        //       selectedDestination: 2,
                        //       plantValue: widget.plantValue,
                        //     ),));
                        //   },
                        //   child: Card(
                        //       color: Colors.transparent,
                        //       elevation: 4,
                        //       child: Container(
                        //         height: 130,
                        //         width: 300,
                        //         decoration: const BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius: BorderRadius.only(
                        //             topRight: Radius.circular(12),
                        //             topLeft: Radius.circular(12),
                        //             bottomRight: Radius.circular(12),
                        //             bottomLeft: Radius.circular(12),
                        //           ),
                        //         ),
                        //         child: Column(
                        //           children: [
                        //             Expanded(
                        //                 child: Padding(
                        //                   padding: const EdgeInsets.only(left: 20.0, top: 20),
                        //                   child: Row(
                        //                     crossAxisAlignment: CrossAxisAlignment.start,
                        //                     children: [
                        //                       Container(
                        //                         width: 55,
                        //                         padding: const EdgeInsets.all(10),
                        //                         decoration: const BoxDecoration(
                        //                             color: Colors.blue,
                        //                             borderRadius: BorderRadius.all(
                        //                                 Radius.circular(5))),
                        //                         child: const Icon(Icons.inventory,color: Colors.white),
                        //                       ),
                        //                       const SizedBox(
                        //                         width: 10,
                        //                       ),
                        //                       Expanded(
                        //                         child: Column(
                        //                           crossAxisAlignment: CrossAxisAlignment.start,
                        //                           mainAxisAlignment: MainAxisAlignment.center,
                        //                           children: [
                        //                             Flexible(
                        //                                 child: Text(
                        //                                     "Outward",
                        //                                     overflow: TextOverflow.ellipsis,
                        //                                     maxLines: 1,
                        //                                     style: TextStyle(
                        //                                       color: Colors.grey[800],
                        //                                       fontSize: 20,
                        //                                     )
                        //                                 )
                        //                             ),
                        //                           ],
                        //                         ),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 )),
                        //             Container(
                        //               height: 40,
                        //               decoration: BoxDecoration(
                        //                 color: const Color(0xffF9FAFB),
                        //                 borderRadius: const BorderRadius.only(
                        //                   bottomLeft: Radius.circular(10),
                        //                   bottomRight: Radius.circular(10),
                        //                 ),
                        //                 border: Border.all(
                        //                   width: 3,
                        //                   color: Colors.transparent,
                        //                   style: BorderStyle.solid,
                        //                 ),
                        //               ),
                        //               child: const Row(
                        //                 mainAxisAlignment: MainAxisAlignment.end,
                        //                 children: [
                        //                   Padding(
                        //                     padding: EdgeInsets.only(
                        //                         right: 16, top: 8, bottom: 4),
                        //                     child: Icon(
                        //                       Icons.arrow_forward,
                        //                       color: Colors.black,
                        //                       size: 20,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             )
                        //           ],
                        //         ),
                        //       )),
                        // ),
                      ],
                    ),
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }
}
