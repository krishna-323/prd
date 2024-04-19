import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../home/home_screen.dart';
import '../pdf_inward/outward_pdf_generator.dart';
import '../utils/config.dart';
import '../utils/custom_appbar.dart';
import '../utils/custom_drawer.dart';
import '../utils/custom_loader.dart';
import '../utils/jml_colors.dart';
import '../widgets/outlined_mbutton.dart';
import 'add_outward.dart';
import 'edit_outward.dart';

class OutwardList extends StatefulWidget {
  final double drawerWidth;
  final double selectedDestination;
  final String plantValue;
  const OutwardList({
    required this.drawerWidth,
    required this.selectedDestination,
    required this.plantValue,
    super.key
  });

  @override
  State<OutwardList> createState() => _OutwardListState();
}

class _OutwardListState extends State<OutwardList> {

  final _horizontalScrollController = ScrollController();
  final _verticalScrollController = ScrollController();

  final searchVehicleNo = TextEditingController();
  final searchVehicleOutTime = TextEditingController();
  final searchInvoiceNo = TextEditingController();
  final searchInvoiceDate = TextEditingController();
  final searchEntryTime = TextEditingController();

  final searchGateOutNo = TextEditingController();
  final searchSupplierName = TextEditingController();
  final searchPONo = TextEditingController();
  final searchEntryDate = TextEditingController();
  final searchCancel = TextEditingController();

  List filteredList = [];
  int startVal=0;
  bool loading = true;
  List outwardList = [];
  late double drawerWidth;
  String formatTime(String timeString) {
    try {
      String timeWithoutPT = timeString.substring(2);
      int hours = int.parse(timeWithoutPT.substring(0, 2));
      int minutes = int.parse(timeWithoutPT.substring(3, 5));
      String meridian = 'AM';
      if (hours >= 12) {
        if (hours > 12) {
          hours -= 12;
        }
        meridian = 'PM';
      }

      String formattedTime = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} $meridian';

      return formattedTime;
    } catch (e) {
      print('Error formatting time: $e');
      return '';
    }
  }
  Future getOutwardListApi()async{
    String url = "${StaticData.apiURL}/YY1_GATEENTRYOUT_CDS/YY1_GATEENTRYOUT?filter=Plant eq '${widget.plantValue}'&orderby=GateOutwardNo desc";
    try{
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': StaticData.basicAuth,
        },
      );
      if(response.statusCode == 200){
        setState(() {
          loading = false;
        });
        Map tempData = jsonDecode(response.body);
        List results = tempData["d"]["results"];
        outwardList.clear();
        for(var result in results){
          Map outWardData = {
            "GateOutwardNo": result['GateOutwardNo'],
            "EntryDate": result['EntryDate'],
            "EntryTime": formatTime(result['EntryTime']),
            "Plant": result['Plant'],
            "VehicleNumber":  result['VehicleNumber'],
            "VehicleOuttime": formatTime(result['VehicleOuttime']),
            "InvoiceNo": result['InvoiceNo'],
            "InvoiceDate": result['InvoiceDate'],
            "SupplierCode": result['SupplierCode'],
            "SupplierName": result['SupplierName'],
            "PurchaseOrderNo": result['PurchaseOrderNo'],
            "Cancelled": result['Cancelled'],
            "EnteredBy": result['EnteredBy'],
            "Remarks": result['Remarks'],
            'SAP_UUID': result['SAP_UUID'],
          };
          setState(() {
            outwardList.add(outWardData);
            loading = false;
          });
        }
        if (outwardList.isEmpty) {
          setState(() {
            loading = false;
          });
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Data found!')),);
          }
        }
      }
    }catch(e){
      setState(() {
        loading = false;
      });
      print('Error occurred in API: $e');
    }
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
  Future downloadJmiPdf(Map filteredList)async{

    final Uint8List pdfBytes = await outwardPdfGen(filteredList);

    // Create a blob from the PDF bytes
    final blob = html.Blob([pdfBytes]);

    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a download link
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "${filteredList['GateOutwardNo']??""} .pdf")
      ..text = "Download PDF";

    // Append the anchor element to the body
    html.document.body?.append(anchor);

    // Click the anchor to initiate download.
    anchor.click();

    // Clean up resources
    html.Url.revokeObjectUrl(url);
    anchor.remove();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOutwardListApi().then((value) {
      if(filteredList.isEmpty){
        if(outwardList.length > outwardList.length){
          // for(int i=0; i<startVal + 1000; i++){
          //   filteredList.add(outwardList[i]);
          // }
        } else{
          for(int i=0; i< outwardList.length; i++){
            filteredList.add(outwardList[i]);
          }
        }
        setState(() {
          loading = false;
        });
      }
    });
    drawerWidth = 60.0;
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
                      title: const Text("Outward List"),
                      centerTitle: true,
                      leading: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                              PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
                                  drawerWidth: widget.drawerWidth,
                                  selectedDestination: widget.selectedDestination,
                                  plantValue: widget.plantValue),));
                        },
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                  )
              ),
              body: loading ? const Center(child: CircularProgressIndicator(),) :
              AdaptiveScrollbar(
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
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SingleChildScrollView(
                            controller: _horizontalScrollController,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 1200,
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
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(
                                            height: 40,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 26,top: 12,right: 0),
                                              child: Text("Outward List", style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 35,
                                            width: 120,
                                            child: OutlinedMButton(
                                              text: "+  New Outward",
                                              buttonColor: mSaveButton,
                                              textColor: Colors.white,
                                              borderColor: mSaveButton,
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) =>  AddOutward(
                                                      drawerWidth: widget.drawerWidth,
                                                      selectedDestination: widget.selectedDestination,
                                                      plantValue: widget.plantValue,
                                                    ),)
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20, top: 0, bottom: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            width: 150,
                                            child: TextFormField(
                                              style: const TextStyle(fontSize: 11),
                                              controller: searchGateOutNo,
                                              decoration: searchGateOutDecoration(hintText: "Search Gate Outward No"),
                                              onChanged: (value) {
                                                if(value.isEmpty || value == ""){
                                                  startVal = 0;
                                                  filteredList = [];
                                                  setState(() {
                                                    if(outwardList.length > outwardList.length){
                                                      // for(int i=0; i < startVal + 1000; i++){
                                                      //   filteredList.add(outwardList[i]);
                                                      // }
                                                    } else{
                                                      for(int i=0; i < outwardList.length; i++){
                                                        filteredList.add(outwardList[i]);
                                                      }
                                                    }
                                                  });
                                                } else{
                                                  startVal = 0;
                                                  filteredList = [];
                                                  searchEntryDate.clear();
                                                  searchInvoiceNo.clear();
                                                  searchCancel.clear();
                                                  searchSupplierName.clear();
                                                  fetchGateOutNo(searchGateOutNo.text);
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 20,),
                                          SizedBox(
                                            height: 30,
                                            width: 150,
                                            child: TextFormField(
                                              style: const TextStyle(fontSize: 11),
                                              controller: searchSupplierName,
                                              decoration: searchSupplierNameDecoration(hintText: "Search Customer Name"),
                                              onChanged: (value) {
                                                if(value.isEmpty || value == ""){
                                                  startVal = 0;
                                                  filteredList = [];
                                                  setState(() {
                                                    if(outwardList.length > outwardList.length){
                                                      // for(int i=0; i < startVal + 1000; i++){
                                                      //   filteredList.add(outwardList[i]);
                                                      // }
                                                    } else{
                                                      for(int i=0; i < outwardList.length; i++){
                                                        filteredList.add(outwardList[i]);
                                                      }
                                                    }
                                                  });
                                                } else{
                                                  startVal = 0;
                                                  filteredList = [];
                                                  searchGateOutNo.clear();
                                                  searchInvoiceNo.clear();
                                                  searchEntryDate.clear();
                                                  searchCancel.clear();
                                                  fetchSupplierName(searchSupplierName.text);
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 20,),
                                          SizedBox(
                                            height: 30,
                                            width: 150,
                                            child: TextFormField(
                                              style: const TextStyle(fontSize: 11),
                                              controller: searchInvoiceNo,
                                              decoration: searchInvoiceNoDecoration(hintText: "Search Invoice No"),
                                              onChanged: (value) {
                                                if(value.isEmpty || value == ""){
                                                  startVal = 0;
                                                  filteredList = [];
                                                  setState(() {
                                                    if(outwardList.length > outwardList.length){
                                                      // for(int i=0; i < startVal + 1000; i++){
                                                      //   filteredList.add(outwardList[i]);
                                                      // }
                                                    } else{
                                                      for(int i=0; i < outwardList.length; i++){
                                                        filteredList.add(outwardList[i]);
                                                      }
                                                    }
                                                  });
                                                } else{
                                                  startVal = 0;
                                                  filteredList = [];
                                                  searchCancel.clear();
                                                  searchEntryDate.clear();
                                                  searchGateOutNo.clear();
                                                  searchSupplierName.clear();
                                                  fetchInvoiceNo(searchInvoiceNo.text);
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 20,),
                                          SizedBox(
                                            height: 30,
                                            width: 150,
                                            child: TextFormField(
                                              style: const TextStyle(fontSize: 11),
                                              controller: searchEntryDate,
                                              decoration: entryDateFieldDecoration(controller: searchEntryDate, hintText: "Select Entry Date"),
                                              onTap: () {
                                                setState(() {
                                                  if(searchEntryDate.text.isEmpty || searchEntryDate.text == ""){
                                                    startVal = 0;
                                                    filteredList = outwardList;
                                                  }
                                                  selectEntryDate(context: context);
                                                  searchCancel.clear();
                                                  searchInvoiceNo.clear();
                                                  searchGateOutNo.clear();
                                                  searchSupplierName.clear();
                                                  // searchVehicleNo.clear();
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 20,),
                                          SizedBox(
                                            height: 30,
                                            width: 150,
                                            child: TextFormField(
                                              style: const TextStyle(fontSize: 11),
                                              controller: searchCancel,
                                              decoration: searchCancelDecoration(hintText: "Search by Cancel"),
                                              onChanged: (value) {
                                                if(value.isEmpty || value == ""){
                                                  startVal = 0;
                                                  filteredList = [];
                                                  setState(() {
                                                    if(outwardList.length > outwardList.length){
                                                      // for(int i=0; i < startVal + 15; i++){
                                                      //   filteredList.add(outwardList[i]);
                                                      // }
                                                    } else{
                                                      for(int i=0; i < outwardList.length; i++){
                                                        filteredList.add(outwardList[i]);
                                                      }
                                                    }
                                                  });
                                                } else{
                                                  startVal = 0;
                                                  filteredList = [];
                                                  searchGateOutNo.clear();
                                                  searchInvoiceNo.clear();
                                                  searchEntryDate.clear();
                                                  searchSupplierName.clear();
                                                  fetchCancel(searchCancel.text);
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(height: 0.5,color: Colors.grey[500],thickness: 0.5,),
                                    Container(
                                      color: Colors.grey[100],
                                      height: 32,
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 18.0, top: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 4.0),
                                                child: SizedBox(
                                                  height: 25,
                                                  // width: 150,
                                                  child: Center(child: Text("Gate Outward No",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 4.0),
                                                child: SizedBox(
                                                  height: 25,
                                                  // width: 150,
                                                  child: Center(child: Text("Customer Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 4.0),
                                                child: SizedBox(
                                                  height: 25,
                                                  // width: 150,
                                                  child: Center(child: Text("Invoice Number",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 4.0),
                                                child: SizedBox(
                                                  height: 25,
                                                  // width: 150,
                                                  child: Center(child: Text("Entry Date",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 4.0),
                                                child: SizedBox(
                                                  height: 25,
                                                  // width: 150,
                                                  child: Center(child: Text("Cancelled",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 4.0),
                                                child: SizedBox(
                                                  height: 25,
                                                  // width: 150,
                                                  child: Center(child: Text("Download PDF",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 4.0),
                                                child: SizedBox(
                                                  height: 25,
                                                  // width: 150,
                                                  child: Center(child: Text("View",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12))),
                                                ),
                                              ),
                                            ),
                                            // Center(child: Padding(
                                            //   padding: EdgeInsets.only(right: 8),
                                            //   child: Icon(size: 18,
                                            //     Icons.more_vert,
                                            //     color: Colors.transparent,
                                            //   ),
                                            // ),)
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(height: 0.5,color: Colors.grey[500],thickness: 0.5,),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: filteredList.length,
                                      itemBuilder: (context, i) {
                                        if(i < filteredList.length){
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              MaterialButton(
                                                hoverColor: Colors.blue[50],
                                                onPressed: () {

                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 18.0,top: 4,bottom: 3),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            child: Center(child: Text(filteredList[i]['GateOutwardNo']??"",style: const TextStyle(fontSize: 11))),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            child: Center(child: Text(filteredList[i]['SupplierName']??"",style: const TextStyle(fontSize: 11))),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            child: Center(child: Text(filteredList[i]['InvoiceNo']??"",style: const TextStyle(fontSize: 11))),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            child: Center(child: Text(filteredList[i]['EntryDate'] != null ? _formatDate(outwardList[i]['EntryDate']):"",style: const TextStyle(fontSize: 11))),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            child: Center(child: Text(filteredList[i]['Cancelled']??"",style: const TextStyle(fontSize: 11))),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            child: Center(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  downloadJmiPdf(filteredList[i]);
                                                                },
                                                                child: const Icon(Icons.download,size: 16,color: Colors.blue),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            child: Center(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => EditOutward(
                                                                    drawerWidth: drawerWidth,
                                                                    selectedDestination: widget.selectedDestination,
                                                                    outwardList: filteredList[i],
                                                                    plantValue: widget.plantValue,
                                                                  ),));
                                                                },
                                                                child: const Icon(Icons.arrow_circle_right,size: 16,color: Colors.blue),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // const Center(child: Padding(
                                                      //   padding: EdgeInsets.only(right: 8),
                                                      //   child: Icon(size: 18,
                                                      //     Icons.arrow_circle_right,
                                                      //     color: Colors.blue,
                                                      //   ),
                                                      // ),)
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        }
                                      },
                                    )
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
        ],
      ),
    );
  }

  invoiceDateFieldDecoration( {required TextEditingController controller, required String hintText, bool? error, Function? onTap}) {
    return  InputDecoration(
      constraints: BoxConstraints(maxHeight: error==true ? 50:30),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 11),
      // suffixIcon: const Icon(Icons.calendar_month, size: 16, color: Colors.grey,),
      suffixIcon: searchInvoiceDate.text.isEmpty?const Icon(Icons.calendar_month, size: 16, color: Colors.grey,):InkWell(
          onTap: (){
            setState(() {
              searchInvoiceDate.clear();
              filteredList = outwardList;
            });
          },
          child: const Icon(Icons.close,size: 14,)),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color:  Colors.blue)),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
      enabledBorder:const OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
    );
  }
  entryDateFieldDecoration( {required TextEditingController controller, required String hintText, bool? error, Function? onTap}) {
    return  InputDecoration(
      constraints: BoxConstraints(maxHeight: error==true ? 50:30),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 11),
      // suffixIcon: const Icon(Icons.calendar_month, size: 16, color: Colors.grey,),
      suffixIcon: searchEntryDate.text.isEmpty?const Icon(Icons.calendar_month, size: 16, color: Colors.grey,):InkWell(
          onTap: (){
            setState(() {
              searchEntryDate.clear();
              filteredList = outwardList;
            });
          },
          child: const Icon(Icons.close,size: 14,)),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color:  Colors.blue)),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
      enabledBorder:const OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
    );
  }
  entryTimeFieldDecoration( {required TextEditingController controller, required String hintText, bool? error, Function? onTap}) {
    return  InputDecoration(
      constraints: BoxConstraints(maxHeight: error==true ? 50:30),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 11),
      // suffixIcon: const Icon(Icons.calendar_month, size: 16, color: Colors.grey,),
      suffixIcon: searchEntryTime.text.isEmpty?const Icon(Icons.watch_later_outlined, size: 16, color: Colors.grey,):InkWell(
          onTap: (){
            setState(() {
              searchEntryTime.clear();
              filteredList = outwardList;
            });
          },
          child: const Icon(Icons.close,size: 14,)),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color:  Colors.blue)),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
      enabledBorder:const OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
    );
  }
  vehicleInTimeFieldDecoration( {required TextEditingController controller, required String hintText, bool? error, Function? onTap}) {
    return  InputDecoration(
      constraints: BoxConstraints(maxHeight: error==true ? 50:30),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 11),
      // suffixIcon: const Icon(Icons.calendar_month, size: 16, color: Colors.grey,),
      suffixIcon: searchVehicleOutTime.text.isEmpty?const Icon(Icons.watch_later_outlined, size: 16, color: Colors.grey,):InkWell(
          onTap: (){
            setState(() {
              searchVehicleOutTime.clear();
              filteredList = outwardList;
            });
          },
          child: const Icon(Icons.close,size: 14,)),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color:  Colors.blue)),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
      enabledBorder:const OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
    );
  }
  searchCancelDecoration({required String hintText, bool? error}){
    return InputDecoration(
      hoverColor: mHoverColor,
      suffixIcon: searchCancel.text.isEmpty?const Icon(Icons.search,size: 18):InkWell(
          onTap: (){
            setState(() {
              searchCancel.clear();
              filteredList = outwardList;
            });
          },
          child: const Icon(Icons.close,size: 14,)),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color:  Colors.blue)),
      constraints:  const BoxConstraints(maxHeight:35),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 11),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color:error==true? mErrorColor :mTextFieldBorder)),
      focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color:error==true? mErrorColor :Colors.blue)),
    );
  }

  searchGateOutDecoration({required String hintText, bool? error}){
    return InputDecoration(
      hoverColor: mHoverColor,
      suffixIcon: searchGateOutNo.text.isEmpty?const Icon(Icons.search,size: 18):InkWell(
          onTap: (){
            setState(() {
              searchGateOutNo.clear();
              filteredList = outwardList;
            });
          },
          child: const Icon(Icons.close,size: 14,)),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color:  Colors.blue)),
      constraints:  const BoxConstraints(maxHeight:35),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 11),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color:error==true? mErrorColor :mTextFieldBorder)),
      focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color:error==true? mErrorColor :Colors.blue)),
    );
  }
  searchSupplierNameDecoration({required String hintText, bool? error}){
    return InputDecoration(
      hoverColor: mHoverColor,
      suffixIcon: searchSupplierName.text.isEmpty?const Icon(Icons.search,size: 18):InkWell(
          onTap: (){
            setState(() {
              searchSupplierName.clear();
              filteredList = outwardList;
            });
          },
          child: const Icon(Icons.close,size: 14,)),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color:  Colors.blue)),
      constraints:  const BoxConstraints(maxHeight:35),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 11),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color:error==true? mErrorColor :mTextFieldBorder)),
      focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color:error==true? mErrorColor :Colors.blue)),
    );
  }
  searchInvoiceNoDecoration({required String hintText, bool? error}){
    return InputDecoration(
      hoverColor: mHoverColor,
      suffixIcon: searchInvoiceNo.text.isEmpty?const Icon(Icons.search,size: 18):InkWell(
          onTap: (){
            setState(() {
              searchInvoiceNo.clear();
              filteredList = outwardList;
            });
          },
          child: const Icon(Icons.close,size: 14,)),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color:  Colors.blue)),
      constraints:  const BoxConstraints(maxHeight:35),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 11),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color:error==true? mErrorColor :mTextFieldBorder)),
      focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color:error==true? mErrorColor :Colors.blue)),
    );
  }

  void fetchGateOutNo(String gateOutNo) {
    if(outwardList.isNotEmpty && gateOutNo.isNotEmpty){
      setState(() {
        filteredList = outwardList.where((outward) => outward["GateOutwardNo"].toLowerCase().contains(gateOutNo.toLowerCase())).toList();
      });
    }
  }
  void fetchSupplierName(String supplierName) {
    if(outwardList.isNotEmpty && supplierName.isNotEmpty){
      setState(() {
        filteredList = outwardList.where((name) => name["SupplierName"].toLowerCase().contains(supplierName.toLowerCase())).toList();
      });
    }
  }
  void fetchInvoiceNo(String invoiceNo) {
    if(outwardList.isNotEmpty && invoiceNo.isNotEmpty){
      setState(() {
        filteredList = outwardList.where((po) => po["InvoiceNo"].toLowerCase().contains(invoiceNo.toLowerCase())).toList();
      });
    }
  }
  void fetchCancel(String cancelled) {
    if(outwardList.isNotEmpty && cancelled.isNotEmpty){
      setState(() {
        filteredList = outwardList.where((cancel) => cancel["Cancelled"].toLowerCase().contains(cancelled.toLowerCase())).toList();
      });
    }
  }
  void fetchInvoiceDate(DateTime selectedDate){
    if(outwardList.isNotEmpty && selectedDate != null){
      String formattedDate = "${selectedDate.day}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year.toString().padLeft(2, '0')}";
      setState(() {
        filteredList = outwardList.where((item) => item['invoiceDate'] == formattedDate).toList();
      });
    }
  }
  void fetchEntryDate(DateTime selectedDate){
    if(outwardList.isNotEmpty && selectedDate != null){
      int milliseconds = selectedDate.millisecondsSinceEpoch + selectedDate.timeZoneOffset.inMilliseconds;
      String formattedDate = "/Date($milliseconds)/";
      setState(() {
        filteredList = outwardList.where((item) => item['EntryDate'] == formattedDate).toList();
      });
    }
  }
  void fetchEntryTime(DateTime selectedTime){
    if(outwardList.isNotEmpty && selectedTime != null){
      String formattedTime = DateFormat('hh:mm a').format(selectedTime);
      setState(() {
        filteredList = outwardList.where((item) => item['entryTime'] == formattedTime).toList();
      });
    }
  }
  void fetchVehicleOutTime(DateTime selectedTime){
    if(outwardList.isNotEmpty && selectedTime != null){
      String formattedTime = DateFormat('hh:mm a').format(selectedTime);
      setState(() {
        filteredList = outwardList.where((item) => item['vehicleOutTime'] == formattedTime).toList();
      });
    }
  }

  selectInvoiceDate({required BuildContext context}) async{
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now()
    );
    if(pickedDate == null) {
      return;
    }
    // datePicker.text = DateFormat("dd-MM-yyyy").format(pickedDate);
    String formattedDate = DateFormat("dd-MM-yyyy").format(pickedDate);
    searchInvoiceDate.text = formattedDate;
    fetchInvoiceDate(pickedDate);
  }
  selectEntryDate({required BuildContext context}) async{
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now()
    );
    if(pickedDate == null) {
      return;
    }
    // datePicker.text = DateFormat("dd-MM-yyyy").format(pickedDate);
    String formattedDate = DateFormat("dd-MM-yyyy").format(pickedDate);
    searchEntryDate.text = formattedDate;
    fetchEntryDate(pickedDate);
  }
  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay _time2 = TimeOfDay.now();
  late TimeOfDay picked;
  late TimeOfDay picked2;
  selectEntryTime(BuildContext context)async{
    picked = (await showTimePicker(
        context: context,
        initialTime: _time
    ))!;
    setState(() {
      _time = picked;
      // String formattedTime = '${picked.hour}:${picked.minute}';
      String formattedTime = DateFormat('hh:mm a').format(DateTime(0, 0, 0, picked.hour, picked.minute));
      searchEntryTime.text = formattedTime;
      fetchEntryTime(DateTime(0, 0, 0, picked.hour, picked.minute));
    });
  }
  selectVehicleOutTime(BuildContext context)async{
    picked2 = (await showTimePicker(
        context: context,
        initialTime: _time2
    ))!;
    setState(() {
      _time2 = picked2;
      // String formattedTime = '${picked.hour}:${picked.minute}';
      String formattedTime = DateFormat('hh:mm a').format(DateTime(0, 0, 0, picked2.hour, picked2.minute));
      searchVehicleOutTime.text = formattedTime;
      fetchVehicleOutTime(DateTime(0, 0, 0, picked2.hour, picked2.minute));
    });
  }
}
