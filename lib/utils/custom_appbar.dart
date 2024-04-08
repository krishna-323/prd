import 'package:flutter/material.dart';

import '../login_screen.dart';
import 'custom_popup_dropdown.dart';
import 'jml_colors.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {

  dynamic size,width,height;
  String logoutInitial="";

  List <CustomPopupMenuEntry<String>> logout =<CustomPopupMenuEntry<String>>[
    const CustomPopupMenuItem(height: 40,
      value: 'Logout',
      child: Center(child: Text('Logout',maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 14))),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 170,
      backgroundColor: Colors.white,
      foregroundColor: Colors.white,
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      elevation: 2,
      bottomOpacity: 20,
      leading: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset("assets/logo/Ikyam_color_logo.png"),
      ),
      actions: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Row(
                children: [
                  TooltipTheme(
                    data: const TooltipThemeData(
                      textStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        color: Colors.black,
                      ),
                      tooltip: 'Notifications',
                    ),
                  ),
                  const SizedBox(width: 15,),
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return CustomPopupMenuButton(
                          elevation: 4,
                          decoration: logoutDecoration(hintText:logoutInitial,),
                          itemBuilder: (BuildContext context) {
                            return logout;
                          },
                          shape:  const RoundedRectangleBorder(
                            side: BorderSide(color: mTextFieldBorder),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          hintText: "",
                          childWidth: 150,
                          offset: const Offset(1, 40),
                          tooltip: '',
                          onSelected: (value) {
                            Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),));
                          },
                          child: Container(),
                        );
                      },),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  logoutDecoration({required String hintText, bool? error, bool ? isFocused,}) {
    return InputDecoration(
      hoverColor: mHoverColor,
      suffixIcon: const Icon(Icons.account_circle, color:Colors.black),
      // border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
      border: InputBorder.none,
      constraints: const BoxConstraints(maxHeight: 35),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xB2000000)),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
    );
  }
}
