import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/custom_appbar.dart';
import '../utils/custom_drawer.dart';
import '../utils/custom_loader.dart';
import '../utils/custom_popup_dropdown.dart';
import '../utils/jml_colors.dart';

class EditOutward extends StatefulWidget {
  final double drawerWidth;
  final double selectedDestination;
  final String plantValue;
  final Map outwardList;
  const EditOutward({
    required this.drawerWidth,
    required this.selectedDestination,
    required this.outwardList,
    required this.plantValue,
    super.key
  });

  @override
  State<EditOutward> createState() => _EditOutwardState();
}

class _EditOutwardState extends State<EditOutward> {

  final _horizontalScrollController = ScrollController();
  final _verticalScrollController = ScrollController();
  bool loading = false;

  final gateOutwardNoController = TextEditingController();
  final plantController = TextEditingController();
  final entryDateController = TextEditingController();
  final entryTimeController = TextEditingController();
  final vehicleNoController = TextEditingController();
  final vehicleOutTimeController = TextEditingController();
  final invoiceDCNoController = TextEditingController();
  final supplierNameController = TextEditingController();
  final supplierCodeController = TextEditingController();
  final invoiceDateController = TextEditingController();
  final invoiceDCTypeController = TextEditingController();
  final enteredByController = TextEditingController();
  final remarksController = TextEditingController();
  final canceledController = TextEditingController();
  late double drawerWidth;
  String canceledValue1 = "NO";
  List<CustomPopupMenuEntry<String>> canceledPopUpList = <CustomPopupMenuEntry<String>>[
    const CustomPopupMenuItem(
      height: 40,
      value: 'Yes',
      child: Center(child: SizedBox(width: 350,child: Text('YES',maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11)))),
    ),
    const CustomPopupMenuItem(
      height: 40,
      value: 'No',
      child: Center(child: SizedBox(width: 350,child: Text('NO',maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11)))),
    ),
  ];

  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay _time2 = TimeOfDay.now();
  late TimeOfDay picked;
  late TimeOfDay picked2;
  late String entryDateTime;
  late String invoiceDateTime;
  late String formattedTime ;
  late String formattedEntryTime ;
  late String formattedVehicleTime ;
  Future<void> selectTime(BuildContext context)async{
    picked = (await showTimePicker(
        context: context,
        initialTime: _time
    ))!;
    if(picked !=null){
      setState(() {
        _time = picked;
        int hour = picked.hour;
        int minute = picked.minute;
        formattedEntryTime = 'PT${hour}H${minute}M00S';
        String formattedTime = DateFormat('hh:mm a').format(DateTime(0, 0, 0, hour, minute));
        entryTimeController.text = formattedTime;
      });
    }
  }
  Future<void> selectVehicleOutTime(BuildContext context)async{
    picked2 = (await showTimePicker(
        context: context,
        initialTime: _time2
    ))!;
    if (picked2 != null) {
      setState(() {
        _time2 = picked2;
        int hour = picked2.hour;
        int minute = picked2.minute;
        formattedVehicleTime = 'PT${hour}H${minute}M00S';
        String formattedTime = DateFormat('hh:mm a').format(DateTime(0, 0, 0, hour, minute));
        vehicleOutTimeController.text = formattedTime;
      });
    }
  }

  selectEntryDate(BuildContext context) async{
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now()
    );
    if(pickedDate == null) {
      return;
    }
    String formattedDate = DateFormat("dd-MM-yyyy").format(pickedDate);
    entryDateController.text = formattedDate;
    entryDateTime = "${DateFormat("yyyy-MM-dd").format(pickedDate)}T00:00:00";
  }
  selectInvoiceDate(BuildContext context) async{
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now()
    );
    if(pickedDate == null) {
      return;
    }
    String formattedDate = DateFormat("dd-MM-yyyy").format(pickedDate);
    invoiceDateController.text = formattedDate;
    invoiceDateTime = "${DateFormat("yyyy-MM-dd").format(pickedDate)}T00:00:00";
  }
  String _formatDate(String dateString) {
    try {
      int milliseconds = int.parse(dateString.substring(6, dateString.length - 2));
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      return formattedDate;
    } catch (e) {
      print('Error formatting date: $e');
      return '';
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    drawerWidth = 60.0;
    super.initState();
    print('-------- edit outward init ----------');
    print(widget.outwardList);
    gateOutwardNoController.text = widget.outwardList['GateOutwardNo']??"";
    plantController.text = widget.outwardList['Plant']??"";
    entryDateController.text = _formatDate(widget.outwardList['EntryDate']??"");
    entryTimeController.text = widget.outwardList['EntryTime']??"";
    vehicleNoController.text = widget.outwardList['VehicleNumber']??"";
    vehicleOutTimeController.text = widget.outwardList['VehicleOuttime']??"";
    invoiceDCNoController.text = widget.outwardList['InvoiceNo']??"";
    supplierNameController.text = widget.outwardList['SupplierName']??"";
    supplierCodeController.text = widget.outwardList['SupplierCode']??"";
    invoiceDateController.text = _formatDate(widget.outwardList['InvoiceDate']??"");
    invoiceDCTypeController.text = widget.outwardList['PurchaseOrderNo']??"";
    enteredByController.text = widget.outwardList['EnteredBy']??"";
    remarksController.text = widget.outwardList['Remarks']??"";
    canceledController.text = widget.outwardList['Cancelled']??"";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CustomAppBar()
      ),
      body: Row(
        children: [
          CustomDrawer(widget.drawerWidth, widget.selectedDestination, widget.plantValue),
          const VerticalDivider(width: 1,thickness: 1),
          Expanded(
            child: Scaffold(
              backgroundColor: const Color(0xffF0F4F8),
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(88.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: AppBar(
                    elevation: 1,
                    surfaceTintColor: Colors.white,
                    shadowColor: Colors.black,
                    title: const Text("View Outward"),
                    centerTitle: true,
                    leading: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        //Navigator.pushReplacementNamed(context, "/home");
                      },
                      child: const Icon(Icons.keyboard_backspace_outlined),
                    ),
                    // actions: [
                    //   Padding(
                    //     padding: const EdgeInsets.only(right: 20),
                    //     child: MaterialButton(
                    //       color: Colors.blue,
                    //       onPressed: () {
                    //         Map editOutward = {
                    //           "gateOutwardNo": gateOutwardNoController.text,
                    //           "entryDate": entryDateController.text,
                    //           "entryTime": entryTimeController.text,
                    //           "plant": plantController.text,
                    //           "vehicleNo": vehicleNoController.text,
                    //           "vehicleOutTime": vehicleOutTimeController.text,
                    //           "invoiceNo": invoiceDCNoController.text,
                    //           "invoiceDate": invoiceDateController.text,
                    //           "supplierCode": supplierCodeController.text,
                    //           "supplierName": supplierNameController.text,
                    //           "invoiceType": invoiceDCTypeController.text,
                    //           "entredBy": enteredByController.text,
                    //           "remarks": remarksController.text,
                    //         };
                    //       },child: const Text("Save",style: TextStyle(color: Colors.white)),),
                    //   )
                    // ],
                  ),
                ),
              ),
              body: CustomLoader(
                inAsyncCall: loading,
                child: AdaptiveScrollbar(
                  position: ScrollbarPosition.bottom,
                  underColor: Colors.blueGrey.withOpacity(0.3),
                  sliderDefaultColor: Colors.grey.withOpacity(0.7),
                  sliderActiveColor: Colors.grey,
                  controller: _horizontalScrollController,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0, left: 80, bottom: 30, right: 80),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 1100,
                              child: Card(
                                color: Colors.white,
                                surfaceTintColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: BorderSide(
                                      color: mTextFieldBorder.withOpacity(0.8),
                                      width: 1
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 26,top: 8,right: 0,bottom: 8),
                                      child: Text("Gate Outward", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,fontSize: 12)),
                                    ),
                                    const Divider(color: mTextFieldBorder,height: 1),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 18,top: 10,right: 18,bottom: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 100,
                                                        child: Text("Gate Outward No",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child: TextFormField(
                                                        style: const TextStyle(fontSize: 11),
                                                        readOnly: true,
                                                        controller: gateOutwardNoController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: gateOutwardNoController),
                                                        onChanged: (value){

                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 100,
                                                        child: Text("Entry Date",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child: TextFormField(
                                                        style: const TextStyle(fontSize: 11),
                                                        readOnly: true,
                                                        controller: entryDateController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: entryDateController),
                                                        onChanged: (value){

                                                        },
                                                        // onTap: () {
                                                        //   selectEntryDate(context);
                                                        // },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 100,
                                                        child: Text("Entry Time",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child: TextFormField(
                                                        style: const TextStyle(fontSize: 11),
                                                        readOnly: true,
                                                        controller: entryTimeController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: entryTimeController),
                                                        onChanged: (value){

                                                        },
                                                        // onTap: () {
                                                        //   selectEntryTime(context);
                                                        // },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 100,
                                                        child: Text("Plant",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child: TextFormField(
                                                        style: const TextStyle(fontSize: 11),
                                                        readOnly: true,
                                                        controller: plantController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: plantController),
                                                        onChanged: (value){

                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 100,
                                                        child: Text("Vehicle Number",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child: TextFormField(
                                                        style: const TextStyle(fontSize: 11),
                                                        readOnly: true,
                                                        controller: vehicleNoController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: vehicleNoController),
                                                        onChanged: (value){

                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 100,
                                                        child: Text("Vehicle Out-Time",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child: TextFormField(
                                                        style: const TextStyle(fontSize: 11),
                                                        readOnly: true,
                                                        controller: vehicleOutTimeController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: vehicleOutTimeController),
                                                        onChanged: (value){

                                                        },
                                                        // onTap: () {
                                                        //   selectVehicleOutTime(context);
                                                        // },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 200,
                                                        child: Text("Customer / Supplier Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child: TextFormField(
                                                        style: const TextStyle(fontSize: 11),
                                                        readOnly: true,
                                                        controller: supplierNameController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: supplierNameController),
                                                        onChanged: (value){

                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 200,
                                                        child: Text("Customer / Supplier Code",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child:  TextFormField(
                                                        style: const TextStyle(fontSize: 11),
                                                        readOnly: true,
                                                        controller: supplierCodeController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: supplierCodeController),
                                                        onChanged: (value){

                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 200,
                                                        child: Text("Invoice DC No",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child:   TextFormField(
                                                        style: const TextStyle(fontSize: 11),
                                                        readOnly: true,
                                                        controller: invoiceDCNoController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: invoiceDCNoController),
                                                        onChanged: (value){

                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 200,
                                                        child: Text("Invoice Date",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child:  TextFormField(
                                                        style: const TextStyle(fontSize: 11),
                                                        readOnly: true,
                                                        controller: invoiceDateController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: invoiceDateController),
                                                        onChanged: (value){

                                                        },
                                                        // onTap: () {
                                                        //   selectInvoiceDate(context);
                                                        // },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 200,
                                                        child: Text("Invoice / DC Type",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child:  TextFormField(
                                                        style: const TextStyle(fontSize: 11),
                                                        readOnly: true,
                                                        controller: invoiceDCTypeController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: invoiceDCTypeController),
                                                        onChanged: (value){

                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                        width: 200,
                                                        child: Text("Cancelled",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                    ),
                                                    // SizedBox(
                                                    //   height: 30,
                                                    //   width: 200,
                                                    //   child:SizedBox(
                                                    //     height: 30,
                                                    //     child: Focus(
                                                    //         skipTraversal: true,
                                                    //         descendantsAreFocusable: true,
                                                    //         child: LayoutBuilder(
                                                    //           builder: (BuildContext context, BoxConstraints constraints) {
                                                    //             return CustomPopupMenuButton(
                                                    //               decoration: customPopupDecoration(hintText:canceledValue1,),
                                                    //               itemBuilder: (BuildContext context) {
                                                    //                 return canceledPopUpList;
                                                    //               },
                                                    //               hintText: "",
                                                    //               childWidth: constraints.maxWidth,
                                                    //               textController: canceledController,
                                                    //               shape:  const RoundedRectangleBorder(
                                                    //                 side: BorderSide(color: mTextFieldBorder),
                                                    //                 borderRadius: BorderRadius.all(
                                                    //                   Radius.circular(5),
                                                    //                 ),
                                                    //               ),
                                                    //               offset: const Offset(1, 40),
                                                    //               tooltip: '',
                                                    //               onSelected: ( value) {
                                                    //                 setState(() {
                                                    //                   canceledValue1 = value;
                                                    //                   canceledController.text = value;
                                                    //                 });
                                                    //               },
                                                    //               onCanceled: () {
                                                    //
                                                    //               },
                                                    //               child: Container(),
                                                    //             );
                                                    //           },
                                                    //         )
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child:TextFormField(
                                                        style: const TextStyle(fontSize: 11),
                                                        readOnly: true,
                                                        controller: canceledController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: canceledController),
                                                        onChanged: (value){

                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Column(
                                            children: [
                                              SizedBox(
                                                width: 200,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 1100,
                              child: Card(
                                color: Colors.white,
                                surfaceTintColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: BorderSide(
                                      color: mTextFieldBorder.withOpacity(0.8),
                                      width: 1
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 18,top: 0,right: 18),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                                width: 100,
                                                child: Text("Entered By",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                            ),
                                            SizedBox(
                                              height: 30,
                                              width: 200,
                                              child: TextFormField(
                                                style: const TextStyle(fontSize: 11),
                                                readOnly: true,
                                                controller: enteredByController,
                                                decoration: customerFieldDecoration(hintText: '',controller: enteredByController),
                                                onChanged: (value){

                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10, left: 8, bottom: 10),
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                                width: 100,
                                                child: Text("Remarks",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                            ),
                                            SizedBox(
                                              // height: 30,
                                              width: 800,
                                              child: TextFormField(
                                                readOnly: true,
                                                style: const TextStyle(fontSize: 11),
                                                // autofocus: true,
                                                controller: remarksController,
                                                minLines: 2,
                                                maxLines: 500,
                                                maxLength: 500,
                                                decoration: customerFieldDecoration2(hintText: '',controller: remarksController),
                                                onChanged: (value){

                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  customerFieldDecoration( {required TextEditingController controller, required String hintText, bool? error, Function? onTap}) {
    return  InputDecoration(
      constraints: BoxConstraints(maxHeight: error==true ? 50:30),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 11),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color:  Colors.blue)),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
      enabledBorder:const OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
    );
  }
  customerFieldDecoration2( {required TextEditingController controller, required String hintText, bool? error, Function? onTap}) {
    return  InputDecoration(
      // constraints: BoxConstraints(maxHeight: error==true ? 50:30),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 11),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color:  Colors.blue)),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      enabledBorder:const OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
    );
  }

  customPopupDecoration({required String hintText, bool? error, bool ? isFocused,}) {
    return InputDecoration(
      hoverColor: mHoverColor,
      suffixIcon: const Icon(Icons.arrow_drop_down_circle_sharp, color: mSaveButton, size: 14),
      border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
      constraints: const BoxConstraints(maxHeight: 35),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xB2000000)),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
      disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: isFocused == true ? Colors.blue : error == true ? mErrorColor : mTextFieldBorder)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: error == true ? mErrorColor : mTextFieldBorder)),
      focusedBorder: OutlineInputBorder(
          borderSide:
          BorderSide(color: error == true ? mErrorColor : Colors.blue)),
    );
  }
}
