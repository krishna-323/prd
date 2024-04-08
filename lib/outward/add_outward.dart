import 'dart:convert';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import '../utils/custom_appbar.dart';
import '../utils/custom_drawer.dart';
import '../utils/custom_loader.dart';
import '../utils/custom_popup_dropdown.dart';
import '../utils/jml_colors.dart';
import 'outward_list.dart';

class AddOutward extends StatefulWidget {
  final double drawerWidth;
  final double selectedDestination;
  final String plantValue;
  const AddOutward({
    required this.drawerWidth,
    required this.selectedDestination,
    required this.plantValue,
    super.key
  });

  @override
  State<AddOutward> createState() => _AddOutwardState();
}

class _AddOutwardState extends State<AddOutward> {

  final _horizontalScrollController = ScrollController();
  final _verticalScrollController = ScrollController();
  bool loading = true;

  final gateOutwardNoController = TextEditingController();
  final plantController = TextEditingController();
  final entryDateController = TextEditingController();
  final entryTimeController = TextEditingController();
  final vehicleNoController = TextEditingController();
  final vehicleOutTimeController = TextEditingController();
  final invoiceDCNoController = TextEditingController();
  final supplierNameController = TextEditingController();
  final searchSupplierNameController = TextEditingController();
  final supplierCodeController = TextEditingController();
  final searchSupplierCodeController = TextEditingController();
  final invoiceDateController = TextEditingController();
  final invoiceDCTypeController = TextEditingController();
  final enteredByController = TextEditingController();
  final searchSecurityNameController = TextEditingController();
  final remarksController = TextEditingController();
  final canceledController = TextEditingController();
  late double drawerWidth;
  String canceledValue1 = "NO";

  List supplierCodeList = [];
  List securityNameList = [];
  List<dynamic> poNoList = [];
  List suppliers = [];
  List poNo = [];
  List<dynamic> selectedPurchaseOrders = [];
  List<dynamic> displayData =[];
  List<Map<String, dynamic>> uniquePurchaseOrder = [];
  List<dynamic> purchaseOrders = [];
  List securityName = [];

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
  Future<void> selectEntryTime(BuildContext context)async{
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
  String _formatTime(TimeOfDay time) {
    return 'PT${time.hour}H${time.minute}M00S';
  }
  @override
  void initState() {
    // TODO: implement initState
    drawerWidth = 60.0;
    super.initState();
    canceledController.text = canceledValue1;
    plantController.text = widget.plantValue;
    entryDateController.text = DateFormat("dd-MM-yyyy").format(DateTime.now());
    invoiceDateController.text = DateFormat("dd-MM-yyyy").format(DateTime.now());
    entryTimeController.text = DateFormat('hh:mm a').format(DateTime.now());
    formattedEntryTime = _formatTime(TimeOfDay.now());
    String entryDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String invoiceDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    entryDateTime = "${entryDate}T00:00:00";
    invoiceDateTime = "${invoiceDate}T00:00:00";
    getGateOutNo();
    getInitialData();
  }

  Future getInitialData() async{
    var data = await getSupplierCode();
    var data2 = await getSecurityNameApi();
    if(data != null){
      suppliers = data.map((entry){
        return {
          "Customer":entry["Customer"],
          "CustomerName": entry["CustomerName"],
        };
      }).toList();
    }
    if(data2 != null){
      securityName = data2.map((entry){
        return {
          "SecurityName":entry["SecurityName"],
        };
      }).toList();
    }
    supplierCodeList = suppliers;
    securityNameList = securityName;
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
          CustomDrawer(drawerWidth, widget.selectedDestination, widget.plantValue),
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
                      title: const Text("Outward Details"),
                      centerTitle: true,
                      leading: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          //Navigator.pushReplacementNamed(context, "/home");
                        },
                        child: const Icon(Icons.keyboard_backspace_outlined),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: MaterialButton(
                            color: Colors.blue,
                            onPressed: () {
                              if (supplierNameController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select Supplier Name")));
                                return;
                              }
                              if (invoiceDateController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter Invoice Date")));
                                return;
                              }
                              if (vehicleNoController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter Vehicle Number")));
                                return;
                              }
                              if (vehicleOutTimeController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter Vehicle Out-Time")));
                                return;
                              }
                              if (enteredByController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter Security Name")));
                                return;
                              }
                              Map savedOutward = {
                                "GateOutwardNo": gateOutwardNoController.text,
                                "EntryDate": entryDateTime,
                                "EntryTime": formattedEntryTime,
                                "Plant": plantController.text,
                                "VehicleNumber": vehicleNoController.text,
                                "VehicleOuttime": formattedVehicleTime,
                                "InvoiceNo": invoiceDCNoController.text,
                                "InvoiceDate": invoiceDateTime,
                                "SupplierCode": supplierCodeController.text,
                                "SupplierName": supplierNameController.text,
                                "PurchaseOrderNo": invoiceDCTypeController.text,
                                "Cancelled": canceledController.text,
                                "EnteredBy": enteredByController.text,
                                "Remarks": remarksController.text,
                              };
                              print('-------- saves outward -----------');
                              print(savedOutward);
                              postOutWardApi(savedOutward, context);
                            },child: const Text("Save",style: TextStyle(color: Colors.white)),),
                        )
                      ],
                    ),
                  ),
                ),
                body: loading ? const Center(child: CircularProgressIndicator(),) :
                AdaptiveScrollbar(
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
                                                        // autofocus: true,
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
                                                        // autofocus: true,
                                                        controller: vehicleOutTimeController,
                                                        decoration: customerFieldDecoration(hintText: '',controller: vehicleOutTimeController),
                                                        onChanged: (value){

                                                        },
                                                        onTap: () {
                                                          selectVehicleOutTime(context);
                                                        },
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
                                                        autofocus: true,
                                                        controller: supplierNameController,
                                                        decoration:  const InputDecoration(
                                                          hintText: " Select Customer Name",
                                                          hintStyle: TextStyle(fontSize: 11,),
                                                          border: OutlineInputBorder(
                                                              borderSide: BorderSide(color:  Colors.blue)
                                                          ),
                                                          contentPadding: EdgeInsets.fromLTRB(12, 00, 0, 0),
                                                          suffixIcon: Icon(
                                                            Icons.arrow_drop_down_outlined,
                                                            color: Colors.blue,size: 16,
                                                          ),
                                                          enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
                                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                                                        ),
                                                        onChanged: (value){

                                                        },
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) => _showSupplierNameDialog(),
                                                          ).then((value) {
                                                            setState(() {
                                                              loading = false;
                                                              supplierNameController.text = value["name"];
                                                              supplierCodeController.text = value["code"];
                                                              // poNoList=[];
                                                              // purchaseOrders = [];
                                                              // purchaseOrderController.clear();
                                                              // poTypeController.clear();
                                                            });
                                                            // getPOData(value["code"]);
                                                          });
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
                                                        // autofocus: true,
                                                        controller: supplierCodeController,
                                                        decoration:  const InputDecoration(
                                                          hintText: " Select Customer Code",
                                                          hintStyle: TextStyle(fontSize: 11,),
                                                          border: OutlineInputBorder(
                                                              borderSide: BorderSide(color:  Colors.blue)
                                                          ),
                                                          contentPadding: EdgeInsets.fromLTRB(12, 00, 0, 0),
                                                          suffixIcon: Icon(
                                                            Icons.arrow_drop_down_outlined,
                                                            color: Colors.blue,size: 16,
                                                          ),
                                                          enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
                                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                                                        ),
                                                        onChanged: (value){

                                                        },
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) => _showSupplierDialog(),
                                                          ).then((value) {
                                                            setState(() {
                                                              loading = false;
                                                              supplierCodeController.text = value;
                                                              poNoList=[];
                                                              purchaseOrders = [];
                                                              // purchaseOrderController.clear();
                                                              // poTypeController.clear();
                                                            });
                                                            // getPOData(value);
                                                          });
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
                                                        // autofocus: true,
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
                                                        // autofocus: true,
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
                                                        // autofocus: true,
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
                                                    SizedBox(
                                                      height: 30,
                                                      width: 200,
                                                      child:SizedBox(
                                                        height: 30,
                                                        child: Focus(
                                                            skipTraversal: true,
                                                            descendantsAreFocusable: true,
                                                            child: LayoutBuilder(
                                                              builder: (BuildContext context, BoxConstraints constraints) {
                                                                return CustomPopupMenuButton(
                                                                  decoration: customPopupDecoration(hintText:canceledValue1,),
                                                                  itemBuilder: (BuildContext context) {
                                                                    return canceledPopUpList;
                                                                  },
                                                                  hintText: "",
                                                                  childWidth: constraints.maxWidth,
                                                                  textController: canceledController,
                                                                  shape:  const RoundedRectangleBorder(
                                                                    side: BorderSide(color: mTextFieldBorder),
                                                                    borderRadius: BorderRadius.all(
                                                                      Radius.circular(5),
                                                                    ),
                                                                  ),
                                                                  offset: const Offset(1, 40),
                                                                  tooltip: '',
                                                                  onSelected: ( value) {
                                                                    setState(() {
                                                                      canceledValue1 = value;
                                                                      canceledController.text = value;
                                                                    });
                                                                  },
                                                                  onCanceled: () {

                                                                  },
                                                                  child: Container(),
                                                                );
                                                              },
                                                            )
                                                        ),
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
                                                autofocus: true,
                                                controller: enteredByController,
                                                decoration:  const InputDecoration(
                                                  hintText: " Select Security Name",
                                                  hintStyle: TextStyle(fontSize: 11,),
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(color:  Colors.blue)
                                                  ),
                                                  contentPadding: EdgeInsets.fromLTRB(12, 00, 0, 0),
                                                  suffixIcon: Icon(
                                                    Icons.arrow_drop_down_outlined,
                                                    color: Colors.blue,size: 16,
                                                  ),
                                                  enabledBorder:OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
                                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                                                ),
                                                onChanged: (value){

                                                },
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return _showEnteredByDialog();
                                                    },).then((value){
                                                    enteredByController.text = value;
                                                  });
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
                                                style: const TextStyle(fontSize: 11),
                                                autofocus: true,
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
              )
          ),
        ],
      ),
    );
  }


  Future postOutWardApi(Map tempData, BuildContext context)async{
    String url = "${StaticData.apiPostURL}/YY1_GATEENTRYOUT_CDS/YY1_GATEENTRYOUT";
    print('------- out post url ----------');
    print(url);
    try{
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'Authorization': StaticData.basicAuth,
        },
        body:  json.encode(tempData),
      );
      if(response.statusCode == 201){
        final jsonResponse = json.decode(response.body);
        if(jsonResponse['d'] != null && jsonResponse['d']['SAP_UUID'] != null){
          BuildContext dialogContext = context;
          if(mounted){
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title:  Text('GateInwardNo: ${gateOutwardNoController.text}'),
                  content:  const Text("Data posted successfully"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(dialogContext).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => OutwardList(
                                    drawerWidth: widget.drawerWidth,
                                    selectedDestination: widget.selectedDestination,
                                    plantValue: widget.plantValue
                                ),
                              )
                          );
                        }, child: const Text("OK"))
                  ],
                );
              },);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data posted successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          setState(() {
            loading = false;
          });
        } else{
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to post data'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          setState(() {
            loading = false;
          });
        }
        return response.body;
      } else{
        final errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['error']['message']['value'];
        if(errorMessage.contains("Instance with the same key already exists")){
          BuildContext dialogContext = context;
          if(mounted){
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title:  Text('GateInwardNo: ${gateOutwardNoController.text}'),
                  content:  const Text("Instance with the same key already exists"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close the dialog
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Instance with the same key already exists'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          setState(() {
            loading = false;
          });
        } else{
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to post data: $errorMessage'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          setState(() {
            loading = false;
          });
        }
        return response.body;
      }
    }catch(e){
      print('Error posting data: $e');
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting data: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      setState(() {
        loading = false;
      });
      return null;
    }
  }
  Future getGateOutNo() async{
    String url = "${StaticData.apiURL}/YY1_GATEENTRYOUT_CDS/YY1_GATEENTRYOUT?orderby=GateOutwardNo desc";
    try{
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': StaticData.basicAuth,
        },
      );
      if(response.statusCode == 200){
        Map tempData = json.decode(response.body);
        List results = tempData['d']['results'];

        if(results.isNotEmpty){
          String firstGateInwardNo = results[0]['GateOutwardNo'];
          int nextGateInwardNo = int.parse(firstGateInwardNo) + 1;
          gateOutwardNoController.text = nextGateInwardNo.toString();
          setState(() {
            loading = false;
          });
        }
        if(results.isEmpty){
          setState(() {
            loading = false;
          });
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No Data Found")));
          }
        }
      }
    }catch(e){
      print('Error fetching GateInwardNo: $e');
      setState(() {
        loading = false;
      });
    }
  }
  Future getSupplierCode() async{
    String url = "${StaticData.apiURL}/A_Customer";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': StaticData.basicAuth,
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
  Future getSecurityNameApi() async{
    String url = "${StaticData.apiURL}/YY1_SECURITYMASTER_CDS/YY1_SECURITYMASTER?filter=Active eq true";
    try{
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': StaticData.basicAuth},
      );
      if(response.statusCode == 200){
        Map<String, dynamic> tempData = {};
        tempData = json.decode(response.body);
        if(tempData['d']['results'].isEmpty){
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Data Found !')));
          }
          setState(() {
            loading = false;
          });
          return [];
        }
        else {
          setState(() {
            securityNameList = tempData['d']['results'];
            loading = false;
          });
        }
        return json.decode(response.body)['d']['results'];
      } else{
        print('Request failed with status: ${response.statusCode}');
        setState(() {
          loading = false;
        });
        return null;
      }
    }catch(e){
      setState(() {
        loading = false;
      });
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
                          Navigator.pop(context, supplierCodeList[index]["Customer"].toString());
                          setState((){
                            supplierNameController.text = supplierCodeList[index]["CustomerName"];
                            // purchaseOrderController.clear();
                          });
                        },
                        child: ListTile(
                          title: Text(supplierCodeList[index]["Customer"].toString()),
                          subtitle: Text(supplierCodeList[index]["CustomerName"].toString()),
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
  void filterSuppliers(String value){
    setState(() {
      supplierCodeList = suppliers.where((supplier) {
        final code = supplier["Customer"].toString().toLowerCase();
        return code.contains(value.toLowerCase());
      }).toList();
    });
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
                                "name": supplierCodeList[index]["CustomerName"].toString(),
                                "code": supplierCodeList[index]["Customer"].toString(),
                              }
                          );
                          supplierCodeController.text = supplierCodeList[index]["Customer"];
                        },
                        child: ListTile(
                          title: Text(supplierCodeList[index]["CustomerName"].toString()),
                          subtitle: Text(supplierCodeList[index]["Customer"].toString()),
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
  void filterSuppliersName(String value){
    setState(() {
      supplierCodeList = suppliers.where((supplier) {
        final code = supplier["CustomerName"].toString().toLowerCase();
        return code.contains(value.toLowerCase());
      }).toList();
    });
  }
  _showEnteredByDialog(){
    return AlertDialog(
      title: const Text("Select Security Name"),
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
                        controller: searchSecurityNameController,
                        decoration: const InputDecoration(labelText: "Search Security Name"),
                        onChanged: (value) {
                          setState((){
                            if(value.isEmpty || value == ""){
                              securityNameList = [];
                            }
                            filterSecurityName(value);
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
                    itemCount: securityNameList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context,securityNameList[index]['SecurityName']);
                          enteredByController.text = securityNameList[index]['SecurityName'];
                        },
                        child: ListTile(
                          title: Text(securityNameList[index]['SecurityName']),
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
  void filterSecurityName(String value) {
    setState(() {
      securityNameList = securityName.where((element) {
        final secName = element['SecurityName'].toString().toLowerCase();
        return secName.contains(value.toLowerCase());
      }).toList();
    });
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
