import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/custom_appbar.dart';
import '../utils/custom_drawer.dart';
import '../utils/custom_loader.dart';
import '../utils/custom_popup_dropdown.dart';
import '../utils/jml_colors.dart';

class EditInward extends StatefulWidget {
  final double drawerWidth;
  final double selectedDestination;
  final String plantValue;
  final Map inwardMap;
  const EditInward({
    required this.drawerWidth,
    required this.selectedDestination,
    required this.inwardMap,
    required this.plantValue,
    super.key
  });

  @override
  State<EditInward> createState() => _EditInwardState();
}

class _EditInwardState extends State<EditInward> {


  final _horizontalScrollController = ScrollController();
  final _verticalScrollController = ScrollController();
  bool loading = false;
  final gateInwardNoController = TextEditingController();
  final plantController = TextEditingController();
  final entryDateController = TextEditingController();
  final entryTimeController = TextEditingController();
  final vehicleNoController = TextEditingController();
  final vehicleInTimeController = TextEditingController();
  final supplierCodeController = TextEditingController();
  final invoiceNoController = TextEditingController();
  final supplierNameController = TextEditingController();
  final invoiceDateController = TextEditingController();
  final purchaseOrderController = TextEditingController();
  final poTypeController = TextEditingController();
  final enteredByController = TextEditingController();
  final canceledController = TextEditingController();
  final receivedController = TextEditingController();
  final remarksController = TextEditingController();
  final searchSupplierCodeController = TextEditingController();
  final searchSupplierNameController = TextEditingController();
  final searchPONoController = TextEditingController();
  final referenceNoController = TextEditingController();
  final typeController = TextEditingController();
  late double drawerWidth;
  String sapUuid = "";

  String dropdownValue1 = "";
  String canceledValue1 = "NO";
  String typeValue1 = "";
  List supplierCodeList = [];
  List<dynamic> poNoList = [];
  List suppliers = [];
  List poNo = [];
  List<dynamic> selectedPurchaseOrders = [];
  List<dynamic> displayData =[];
  List<Map<String, dynamic>> uniquePurchaseOrder = [];
  List<dynamic> purchaseOrders = [];
  List<CustomPopupMenuEntry<String>> canceledPopUpList = <CustomPopupMenuEntry<String>>[
    const CustomPopupMenuItem(
      height: 40,
      value: 'Yes',
      child: Center(child: SizedBox(width: 350,child: Text('Yes',maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11)))),
    ),
    const CustomPopupMenuItem(
      height: 40,
      value: 'No',
      child: Center(child: SizedBox(width: 350,child: Text('No',maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11)))),
    ),
  ];
  List<CustomPopupMenuEntry<String>> typePopUpList = <CustomPopupMenuEntry<String>>[
    const CustomPopupMenuItem(
      height: 40,
      value: '-',
      child: Center(child: SizedBox(width: 350,child: Text('-',maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11)))),
    ),
    const CustomPopupMenuItem(
      height: 40,
      value: 'Customer',
      child: Center(child: SizedBox(width: 350,child: Text('Customer',maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11)))),
    ),
    const CustomPopupMenuItem(
      height: 40,
      value: 'Supplier',
      child: Center(child: SizedBox(width: 350,child: Text('Supplier',maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11)))),
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
  Future<void> selectVehicleInTime(BuildContext context)async{
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
        vehicleInTimeController.text = formattedTime;
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
    entryDateTime = DateFormat("yyyy-MM-dd").format(pickedDate) + "T00:00:00";
    print('-------- entry date -------');
    print(entryDateTime);
    print(entryDateController.text);
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
    invoiceDateTime = DateFormat("yyyy-MM-dd").format(pickedDate) + "T00:00:00";
    print('-------- invoice data -------');
    print(invoiceDateTime);
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
    // print('-------- edit inward init ---------');
    sapUuid = widget.inwardMap['SAP_UUID'];
    // print(sapUuid);
    // print(widget.inwardMap);
    String entryDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    entryDateTime = "${entryDate}T00:00:00";
    gateInwardNoController.text = widget.inwardMap['GateInwardNo']??"";
    plantController.text = widget.inwardMap['Plant']??"";
    entryDateController.text = _formatDate(widget.inwardMap['EntryDate']??"");
    entryTimeController.text = widget.inwardMap['EntryTime']??"";
    vehicleNoController.text = widget.inwardMap['VehicleNumber']??"";
    vehicleInTimeController.text = widget.inwardMap['VehicleIntime']??"";
    supplierCodeController.text = widget.inwardMap['SupplierCode']??"";
    invoiceNoController.text = widget.inwardMap['InvoiceNo']??"";
    supplierNameController.text = widget.inwardMap['SupplierName']??"";
    invoiceDateController.text = _formatDate(widget.inwardMap['InvoiceDate']??"");
    purchaseOrderController.text = widget.inwardMap['PurchaseOrderNo']??"";
    poTypeController.text = widget.inwardMap['ReceivedBy'??""];
    enteredByController.text = widget.inwardMap['EnteredBy']??"";
    canceledController.text = widget.inwardMap['Cancelled']??"";
    // receivedController.text = widget.inwardMap['ReceivedBy']??"";
    remarksController.text = widget.inwardMap['Remarks']??"";
    typeController.text = widget.inwardMap['SAP_Description']??"";
    referenceNoController.text = widget.inwardMap['ReceivedBy1']??"";

    getInitialData();
  }
  Future getInitialData() async{
    var data = await getSupplierCode();
    if(data != null){
      suppliers = data.map((entry){
        return {
          "Supplier":entry["Supplier"],
          "SupplierName": entry["SupplierName"],
        };
      }).toList();
    }
    supplierCodeList = suppliers;
    setState(() {
      loading = false;
    });
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
                      title: const Text("View Inward"),
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
                      //         // String entryTime = entryTimeController.text;
                      //         // DateTime entryTimeDateTime = DateFormat.jm().parse(entryTime);
                      //         // String formattedEntryTime = "PT${entryTimeDateTime.hour}H${entryTimeDateTime.minute}M00S";
                      //         //
                      //         // String vehicleInTime = vehicleInTimeController.text;
                      //         // DateTime vehicleInTimeDateTime = DateFormat.jm().parse(vehicleInTime);
                      //         // String formattedVehicleInTime = "PT${vehicleInTimeDateTime.hour}H${vehicleInTimeDateTime.minute}M00S";
                      //         //
                      //         // String entryDate = entryDateController.text;
                      //         // DateTime entryDateDateTime = DateFormat("dd-MM-yyyy").parse(entryDate);
                      //         // String formattedEntryDate = "/Date(${entryDateDateTime.millisecondsSinceEpoch})/";
                      //         //
                      //         // String invoiceDate = invoiceDateController.text;
                      //         // DateTime invoiceDateDateTime = DateFormat("dd-MM-yyyy").parse(invoiceDate);
                      //         // String formattedInvoiceDate = "/Date(${invoiceDateDateTime.millisecondsSinceEpoch})/";
                      //
                      //         Map editInward = {
                      //           "gateInwardNo": gateInwardNoController.text,
                      //           "entryDate": entryDateController.text,
                      //           "entryTime": entryTimeController.text,
                      //           "plant": plantController.text,
                      //           "vehicleNumber": vehicleNoController.text,
                      //           "vehicleInTime": vehicleInTimeController.text,
                      //           "supplierCode": supplierCodeController.text,
                      //           "supplierName": supplierNameController.text,
                      //           "purchaseOrderNo": purchaseOrderController.text,
                      //           "purchaseOrderType": poTypeController.text,
                      //           "invoiceNo": invoiceNoController.text,
                      //           "invoiceDate": invoiceDateController.text,
                      //           "entredBy": enteredByController.text,
                      //           "remarks": remarksController.text,
                      //           "canceledBy": canceledController.text,
                      //           "receivedBy": receivedController.text
                      //         };
                      //         print('-------- edit inward -----------');
                      //         print(editInward);
                      //       },child: const Text("Save",style: TextStyle(color: Colors.white)),),
                      //   )
                      // ],
                    ),
                  ),
                ),
                body: CustomLoader(
                  inAsyncCall: loading,
                  child: AdaptiveScrollbar(
                    underColor: Colors.blueGrey.withOpacity(0.3),
                    sliderDefaultColor: Colors.grey.withOpacity(0.7),
                    sliderActiveColor: Colors.grey,
                    controller: _verticalScrollController,
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
                            padding: const EdgeInsets.only(top: 20, left: 80, bottom: 30, right: 80),
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
                                          child: Text("Gate Inward", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,fontSize: 12)),
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
                                                            child: Text("Gate Inward No",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                          width: 200,
                                                          child: TextFormField(
                                                            style: const TextStyle(fontSize: 11),
                                                            readOnly: true,
                                                            controller: gateInwardNoController,
                                                            decoration: customerFieldDecoration(hintText: '',controller: gateInwardNoController),
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
                                                            //   selectTime(context);
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
                                                            child: Text("Vehicle In-Time",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                          width: 200,
                                                          child: TextFormField(
                                                            style: const TextStyle(fontSize: 11),
                                                            readOnly: true,
                                                            controller: vehicleInTimeController,
                                                            decoration: customerFieldDecoration(hintText: '',controller: vehicleInTimeController),
                                                            onChanged: (value){

                                                            },
                                                            // onTap: () {
                                                            //   selectVehicleInTime(context);
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
                                                            width: 100,
                                                            child: Text("Supplier Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                          width: 200,
                                                          child: SizedBox(
                                                            height: 30,
                                                            child: TextFormField(
                                                              style: const TextStyle(fontSize: 11),
                                                              readOnly: true,
                                                              // autofocus: true,
                                                              controller: supplierNameController,
                                                              decoration:  const InputDecoration(
                                                                hintText: " Select Supplier Name",
                                                                hintStyle: TextStyle(fontSize: 11,),
                                                                border: OutlineInputBorder(
                                                                    borderSide: BorderSide(color:  Colors.blue)
                                                                ),
                                                                contentPadding: EdgeInsets.fromLTRB(12, 00, 0, 0),
                                                                  suffixIcon: Icon(
                                                                    Icons.arrow_drop_down_circle_sharp,
                                                                    color: Colors.blue,size: 14,
                                                                  ),
                                                                enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
                                                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                                                              ),
                                                              onChanged: (value){

                                                              },
                                                              // onTap: () {
                                                              //   showDialog(
                                                              //     context: context,
                                                              //     builder: (context) => _showSupplierNameDialog(),
                                                              //   ).then((value) {
                                                              //     setState(() {
                                                              //       loading = false;
                                                              //       supplierNameController.text = value["name"];
                                                              //       supplierCodeController.text = value["code"];
                                                              //       print('-------- supplier name then ----------');
                                                              //       print(supplierNameController.text);
                                                              //       print(supplierCodeController.text);
                                                              //       print(poNoList);
                                                              //     });
                                                              //     getPOData(value["code"]);
                                                              //   });
                                                              // },
                                                            ),
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
                                                            child: Text("Supplier Code",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                          width: 200,
                                                          child: SizedBox(
                                                            height: 30,
                                                            child: TextField(
                                                              style: const TextStyle(fontSize: 11),
                                                              controller: supplierCodeController,
                                                              readOnly: true,
                                                              decoration:  const InputDecoration(
                                                                hintText: " Select Supplier",
                                                                hintStyle: TextStyle(fontSize: 11,),
                                                                border: OutlineInputBorder(
                                                                    borderSide: BorderSide(color:  Colors.blue)
                                                                ),
                                                                contentPadding: EdgeInsets.fromLTRB(12, 00, 0, 0),
                                                                  suffixIcon: Icon(
                                                                    Icons.arrow_drop_down_circle_sharp,
                                                                    color: Colors.blue,size: 14,
                                                                  ),
                                                                enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
                                                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                                                              ),
                                                              // onTap: () {
                                                              //   showDialog(
                                                              //     context: context,
                                                              //     builder: (context) => _showSupplierDialog(),
                                                              //   ).then((value) {
                                                              //     setState(() {
                                                              //       loading = false;
                                                              //       supplierCodeController.text = value;
                                                              //     });
                                                              //     getPOData(value);
                                                              //   });
                                                              // },
                                                            ),
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
                                                            child: Text("Purchase Order No",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                          width: 200,
                                                          child:SizedBox(
                                                            height: 30,
                                                            child: TextFormField(
                                                              style: const TextStyle(fontSize: 11),
                                                              readOnly: true,
                                                              controller: purchaseOrderController,
                                                              decoration: const InputDecoration(
                                                                hintText: " Select Purchase Order Number",
                                                                hintStyle: TextStyle(fontSize: 11,),
                                                                border: OutlineInputBorder(
                                                                    borderSide: BorderSide(color:  Colors.blue)
                                                                ),
                                                                contentPadding: EdgeInsets.fromLTRB(12, 00, 0, 0),
                                                                suffixIcon: Icon(
                                                                  Icons.arrow_drop_down_circle_sharp,
                                                                  color: Colors.blue,size: 14,
                                                                ),
                                                                enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
                                                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                                                              ),
                                                              // onTap: () {
                                                              //   showDialog(
                                                              //     context: context,
                                                              //     builder: (context) => _showPODialog(),
                                                              //   ).then((value) {
                                                              //     setState(() {
                                                              //       loading = false;
                                                              //       purchaseOrderController.text = value;
                                                              //     });
                                                              //   });
                                                              // },
                                                            ),
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
                                                            child: Text("PO Type",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                          width: 200,
                                                          child:TextFormField(
                                                            style: const TextStyle(fontSize: 11),
                                                            readOnly: true,
                                                            controller: poTypeController,
                                                            decoration: customerFieldDecoration(hintText: '',controller: poTypeController),
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
                                                            child: Text("Invoice No",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                          width: 200,
                                                          child:TextFormField(
                                                            style: const TextStyle(fontSize: 11),
                                                            readOnly: true,
                                                            controller: invoiceNoController,
                                                            decoration: customerFieldDecoration(hintText: '',controller: invoiceNoController),
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
                                                            child: Text("Invoice Date",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                          width: 200,
                                                          child:TextFormField(
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
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: SizedBox(height: 30,child: Text("Other than PO Items",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),)),
                                                  ),
                                                  // Padding(
                                                  //   padding: const EdgeInsets.all(8),
                                                  //   child: Row(
                                                  //     children: [
                                                  //       const SizedBox(
                                                  //           width: 100,
                                                  //           child: Text("Type",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                  //       ),
                                                  //       SizedBox(
                                                  //         height: 30,
                                                  //         width: 200,
                                                  //         child:SizedBox(
                                                  //           height: 30,
                                                  //           child: Focus(
                                                  //               skipTraversal: true,
                                                  //               descendantsAreFocusable: true,
                                                  //               child: LayoutBuilder(
                                                  //                 builder: (BuildContext context, BoxConstraints constraints) {
                                                  //                   return CustomPopupMenuButton(
                                                  //                     decoration: customPopupDecoration(hintText:typeValue1,),
                                                  //                     itemBuilder: (BuildContext context) {
                                                  //                       return typePopUpList;
                                                  //                     },
                                                  //                     hintText: "",
                                                  //                     childWidth: constraints.maxWidth,
                                                  //                     textController: typeController,
                                                  //                     shape:  const RoundedRectangleBorder(
                                                  //                       side: BorderSide(color: mTextFieldBorder),
                                                  //                       borderRadius: BorderRadius.all(
                                                  //                         Radius.circular(5),
                                                  //                       ),
                                                  //                     ),
                                                  //                     offset: const Offset(1, 40),
                                                  //                     tooltip: '',
                                                  //                     onSelected: ( value) {
                                                  //                       setState(() {
                                                  //                         typeValue1 = value;
                                                  //                         typeController.text = value;
                                                  //                       });
                                                  //                     },
                                                  //                     onCanceled: () {
                                                  //
                                                  //                     },
                                                  //                     child: Container(),
                                                  //                   );
                                                  //                 },
                                                  //               )
                                                  //           ),
                                                  //         ),
                                                  //       ),
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8),
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(
                                                            width: 100,
                                                            child: Text("Type",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                          width: 200,
                                                          child:TextFormField(
                                                            style: const TextStyle(fontSize: 11),
                                                            readOnly: true,
                                                            controller: typeController,
                                                            decoration: customerFieldDecoration(hintText: '',controller: typeController),
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
                                                            child: Text("Reference No",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                          width: 200,
                                                          child:TextFormField(
                                                            style: const TextStyle(fontSize: 11),
                                                            readOnly: true,
                                                            controller: referenceNoController,
                                                            decoration: customerFieldDecoration(hintText: '',controller: referenceNoController),
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
                                                            child: Text("Cancelled ?",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))
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
                                                  child:TextFormField(
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
                                                  width: 800,
                                                  child:TextFormField(
                                                    style: const TextStyle(fontSize: 11),
                                                    readOnly: true,
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
              )
          ),
        ],
      ),
    );
  }


  Future patchInwardApi() async{
    String url = "Https://JMIApp-terrific-eland-ao.cfapps.in30.hana.ondemand.com/api/sap_odata_patch/Customising/YY1_GATEENTRY_CDS/YY1_GATEENTRY/guid'$sapUuid'";
    print('------ edit inward url ------');
    print(url);
  }
  Future getSupplierCode() async{
    String url = "Https://JMIApp-terrific-eland-ao.cfapps.in30.hana.ondemand.com/api/sap_odata_get/Customising/A_Supplier";
    String authToken = "Basic " + base64Encode(utf8.encode('INTEGRATION:rXnDqEpDv2WlWYahKnEGo)mwREoCafQNorwoDpLl'));
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': authToken,
        },
      );

      if (response.statusCode == 200) {
        Map tempData ={};
        tempData= json.decode(response.body);
        if(tempData['d']['results'].isEmpty){
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Data Found !')));
          }
          setState(() {
            loading = false;
          });
          return [];
        }
        else{
          setState(() {
            displayData = tempData['d']['results'];
            loading = false;
          });
        }
        return json.decode(response.body)['d']['results'];
      } else {
        print('Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred in API: $e');
      return null;
    }
  }


  Future<List<dynamic>?> getPOData(String supplierCode) async {
    String url = "Https://JMIApp-terrific-eland-ao.cfapps.in30.hana.ondemand.com/api/sap_odata_get/Customising/PurchaseOrder/PurchaseOrderScheduleLine?filter=OpenPurchaseOrderQuantity gt 0 and PurchaseOrderQuantityUnit eq 'EA' and _PurchaseOrder/Supplier eq '$supplierCode'&select=PurchaseOrder&expand=_PurchaseOrder";
    String authToken = "Basic ${base64Encode(utf8.encode('INTEGRATION:rXnDqEpDv2WlWYahKnEGo)mwREoCafQNorwoDpLl'))}";
    print('------- get po URL -------');
    print(url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': authToken},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic>? tempData = json.decode(response.body);
        if(tempData!['value'].isEmpty || tempData['value'] == null){
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No PO Number !')));
          }
          setState(() {
            purchaseOrderController.clear();
            poTypeController.clear();
            purchaseOrders = [];
            poNoList = [];
          });
        }
        else if (tempData != null &&
            tempData.containsKey('value') &&
            tempData['value'] != null) {
          purchaseOrders = tempData['value'];
          poNoList = purchaseOrders.map((order) => order['_PurchaseOrder']['PurchaseOrder']).toSet().toList();
          print('------- get po data ----------');
          print(poNoList);
          return purchaseOrders;
        } else {
          print('Error: Unable to find results in response body');
          return null;
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred in API: $e');
      return null;
    }
  }

  _showSupplierDialog(){
    return AlertDialog(
      title: const Text("Select Supplier Code"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            height: 500,
            child: Column(
              children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchSupplierCodeController,
                        decoration: const InputDecoration(labelText: "Search Supplier Code"),
                        onChanged: (value) {
                          setState((){
                            if(value.isEmpty || value == ""){
                              supplierCodeList = [];
                            }
                            filterSuppliers(value);
                          });
                        },
                      ),
                    )
                ),
                SizedBox(
                  width: 500,
                  height: 400,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: supplierCodeList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context, supplierCodeList[index]["Supplier"].toString());
                          print('------- supplier on tap --------');
                          print(supplierCodeList[index]["SupplierName"]);
                          print(poNoList);
                          supplierNameController.text = supplierCodeList[index]["SupplierName"];
                        },
                        child: ListTile(
                          title: Text(supplierCodeList[index]["Supplier"].toString()),
                        ),
                      );
                    },),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _showSupplierNameDialog(){
    return AlertDialog(
      title: const Text("Select Supplier Name"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            height: 500,
            child: Column(
              children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchSupplierNameController,
                        decoration: const InputDecoration(labelText: "Search Supplier Name"),
                        onChanged: (value) {
                          setState((){
                            if(value.isEmpty || value == ""){
                              supplierCodeList = [];
                            }
                            filterSuppliersName(value);
                          });
                        },
                      ),
                    )
                ),
                SizedBox(
                  width: 500,
                  height: 400,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: supplierCodeList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.pop(
                              context,
                              {
                                "name": supplierCodeList[index]["SupplierName"].toString(),
                                "code": supplierCodeList[index]["Supplier"].toString(),
                              }
                          );
                          print('------- supplier  name on tap --------');
                          print(supplierCodeList[index]["SupplierName"]);
                          print(supplierCodeList[index]["Supplier"]);
                          print(poNoList);
                          supplierCodeController.text = supplierCodeList[index]["Supplier"];
                        },
                        child: ListTile(
                          title: Text(supplierCodeList[index]["SupplierName"].toString()),
                        ),
                      );
                    },),
                ),
              ],
            ),
          );
        },),
    );
  }

  _showPODialog(){
    return AlertDialog(
      title: const Text("Select Purchase Order No"),
      content: StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            height: 500,
            child: Column(
              children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchPONoController,
                        decoration: const InputDecoration(labelText: "Search PO No"),
                        onChanged: (value) {
                          setState((){
                            if(value.isEmpty || value == ""){
                              poNoList = [];
                            }
                            filterPONo(value);
                          });
                        },
                      ),
                    )
                ),
                SizedBox(
                  width: 500,
                  height: 400,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: poNoList.length,
                    itemBuilder: (context, index) {
                      var purchaseOrder = poNoList[index];
                      var purchaseOrderType = getPurchaseOrderType(purchaseOrder);
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context, purchaseOrder );
                          poTypeController.text = purchaseOrderType;
                        },
                        child: ListTile(
                          title: Text(purchaseOrder),
                        ),
                      );
                    },),
                ),
              ],
            ),
          );
        },),
    );
  }

  String getPurchaseOrderType(String purchaseOrder) {
    var order = purchaseOrders.firstWhere((order) => order['_PurchaseOrder']['PurchaseOrder'] == purchaseOrder, orElse: () => null);
    return order != null ? order['_PurchaseOrder']['PurchaseOrderType'] : '';
  }

  void filterSuppliers(String value){
    setState(() {
      supplierCodeList = suppliers.where((supplier) {
        final code = supplier["Supplier"].toString().toLowerCase();
        return code.contains(value.toLowerCase());
      }).toList();
    });
  }

  void filterSuppliersName(String value){
    setState(() {
      supplierCodeList = suppliers.where((supplier) {
        final code = supplier["SupplierName"].toString().toLowerCase();
        return code.contains(value.toLowerCase());
      }).toList();
    });
  }

  filterPONo(String searchQuery) {
    if (searchQuery.isEmpty) {
      poNoList = purchaseOrders.map((order) => order['_PurchaseOrder']['PurchaseOrder']).toList();
    } else {
      poNoList = purchaseOrders
          .where((order) => order['_PurchaseOrder']['PurchaseOrder'].contains(searchQuery))
          .map((order) => order['_PurchaseOrder']['PurchaseOrder'])
          .toList();
    }
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
