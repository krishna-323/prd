import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../inward/inward_list.dart';
import '../outward/outward_list.dart';
import 'jml_colors.dart';

class CustomDrawer extends StatefulWidget {
  final double drawerWidth;
  final double selectedDestination;
  final String plantValue;
  const CustomDrawer(this.drawerWidth, this.selectedDestination, this.plantValue,{Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {

  late double drawerWidth;
  late double _selectedDestination;
  bool homeHover = false;
  bool homeExpanded = false;
  bool inwardHover = false;
  bool inwardExpanded = false;
  bool outwardHover = false;
  bool outwardExpanded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    drawerWidth = widget.drawerWidth;
    _selectedDestination = widget.selectedDestination;
    if (_selectedDestination == 0) {
      homeHover = true;
      homeExpanded = false;
    } else if (_selectedDestination == 1) {
      inwardHover = true;
      inwardExpanded = false;
    } else if (_selectedDestination == 2) {
      outwardHover = true;
      outwardExpanded = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
      width:  drawerWidth,
      child: Scaffold(
        body: Drawer(
          backgroundColor:  Colors.white,
          child: ListView(
            controller: ScrollController(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 10,),
              drawerWidth == 60 ? InkWell(
                hoverColor: mHoverColor,
                onTap: (){
                  setState(() {
                    drawerWidth = 190;
                    _selectedDestination = 0;
                  });
                },
                child: SizedBox(
                  height: 40,
                  child: Icon(Icons.apps_rounded,
                    color: _selectedDestination == 0 ? Colors.blue: Colors.black54,
                  ),
                ),
              ) :
              MouseRegion(
                onHover: (event){
                  setState((){
                    homeHover =true;
                  });
                },
                onExit: (event){
                  setState(() {
                    homeHover=false;
                  });
                },
                child: Container(
                  color: homeHover?mHoverColor:Colors.transparent,
                  child: ListTileTheme(
                    contentPadding: const EdgeInsets.only(left: 0),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) =>  HomeScreen(drawerWidth: widget.drawerWidth,selectedDestination: 0,plantValue: widget.plantValue),));
                        setState(() {
                          _selectedDestination = 0;
                        });
                      },
                      leading: const SizedBox(width: 40,child: Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(Icons.apps_rounded),
                      ),),
                      title:    Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          drawerWidth == 60 ? '' : 'Home',
                          style: const TextStyle(fontSize: 17,color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              drawerWidth == 60 ? InkWell(
                hoverColor: mHoverColor,
                onTap: (){
                  setState(() {
                    drawerWidth = 190;
                    // _selectedDestination = 1;
                  });
                },
                child: SizedBox(
                  height: 40,
                  child: Icon(
                    Icons.inventory,
                    color: _selectedDestination == 1 ? Colors.blue: Colors.black54,
                  ),
                ),
              ) :
              MouseRegion(
                onHover: (event){
                  setState((){
                    // inwardHover =true;
                  });
                },
                onExit: (event){
                  setState(() {
                    // inwardHover=false;
                    // _selectedDestination = 1;
                  });
                },
                child: Container(
                  color: inwardHover ? mHoverColor :Colors.transparent,
                  child: ListTileTheme(
                    contentPadding: const EdgeInsets.only(left: 0),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) =>  InwardList(
                          selectedDestination: 1,
                          drawerWidth: widget.drawerWidth,
                          plantValue: widget.plantValue,
                        ),));
                        // setState(() {
                        //   _selectedDestination = 1;
                        // });
                      },
                      leading: const SizedBox(width: 40,child: Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(Icons.inventory),
                      ),),
                      // selectedTileColor: Colors.blue,
                      // hoverColor: mHoverColor,
                      // selectedColor: Colors.black,
                      title:    Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          drawerWidth == 60 ? '' : 'Inward',
                          style:  const TextStyle(fontSize: 17,color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              drawerWidth == 60 ? InkWell(
                hoverColor: mHoverColor,
                onTap: (){
                  setState(() {
                    drawerWidth = 190;
                  });
                },
                child: SizedBox(
                  height: 40,
                  child: Icon(Icons.inventory,
                    color: _selectedDestination == 2 ? Colors.blue: Colors.black54,
                  ),
                ),
              ) :
              MouseRegion(
                onHover: (event){
                  setState((){
                    // outwardHover =true;
                    // inwardHover=false;
                  });
                },
                onExit: (event){
                  setState(() {
                    // outwardHover=false;
                  });
                },
                child: Container(
                  color: outwardHover?mHoverColor:Colors.transparent,
                  child: ListTileTheme(
                    contentPadding: const EdgeInsets.only(left: 0),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) =>  OutwardList(
                          drawerWidth: widget.drawerWidth,
                          selectedDestination: 2,
                          plantValue: widget.plantValue,
                        ),));
                      },
                      leading: const SizedBox(width: 40,child: Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(Icons.inventory),
                      ),),
                      title:    Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          drawerWidth == 60 ? '' : 'Outward',
                          style: const TextStyle(fontSize: 17,color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: 30,
          width: 50,
          child: InkWell(
              onTap: () {
                setState(() {
                  if (drawerWidth == 60) {
                    drawerWidth = 190;
                  } else {
                    drawerWidth = 60;
                  }
                });
              },
              child:
              Row(

                children: [
                  drawerWidth==190?  const Expanded(
                    child: Row(
                      children: [
                        Spacer(),
                        // Flexible(child: Center(child: Image.asset("assets/logo/Ikyam_color_logo.png"))),
                        Center(child: Text("minimize",style: TextStyle(color: Colors.black,fontSize: 11),)),
                        Spacer(),
                        Flexible(child: Icon(Icons.arrow_back_ios_new_rounded,size: 18,))
                      ],
                    ),
                  ):const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Center(child: Icon(Icons.arrow_forward_ios_rounded,size: 18,)),
                  ),
                  // Text(drawerWidth == 60 ? ">" : "<"),
                ],
              )),
        ),
      ),
    );
  }
}
