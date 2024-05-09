import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import '../home/home_screen.dart';
import '../pdf_inward/inward_pdf2.dart';
import '../pdf_inward/inward_pdf_generator.dart';
import '../utils/config.dart';
import '../utils/custom_appbar.dart';
import '../utils/custom_drawer.dart';
import '../utils/custom_loader.dart';
import '../utils/jml_colors.dart';
import '../widgets/outlined_mbutton.dart';
import 'add_inward.dart';
import 'edit_inward.dart';

class InwardList extends StatefulWidget {
  final double drawerWidth;
  final double selectedDestination;
  final String plantValue;
  const InwardList({
    required this.drawerWidth,
    required this.selectedDestination,
    required this.plantValue,
    super.key
  });

  @override
  State<InwardList> createState() => _InwardListState();
}

class _InwardListState extends State<InwardList> {

  final _horizontalScrollController = ScrollController();
  final _verticalScrollController = ScrollController();

  final searchGateInNo = TextEditingController();
  final searchSupplierName = TextEditingController();
  final searchPONo = TextEditingController();
  final searchEntryDate = TextEditingController();
  final searchCancel = TextEditingController();


  bool loading = true;
  List inwardList = [];
  List filteredList = [];
  int startVal=0;
  late double drawerWidth;

  Future getInwardList()async{
    // String url = "Https://JMIApp-terrific-eland-ao.cfapps.in30.hana.ondemand.com/api/sap_odata_get/Customising/YY1_GATEENTRY_CDS/YY1_GATEENTRY";
    String url = "${StaticData.apiURL}/YY1_GATEENTRY_CDS/YY1_GATEENTRY?filter=Plant eq '${widget.plantValue}'&orderby=GateInwardNo desc";

    try{
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': StaticData.basicAuth,
        },
      );

      if(response.statusCode == 200){
        loading = true;
        Map tempData = jsonDecode(response.body);
        List results = tempData["d"]["results"];
        inwardList.clear();

        for(var result in results){
          Map inwardData = {
            'GateInwardNo': result['GateInwardNo'],
            'EntryTime': formatTime(result['EntryTime']),
            'EntryDate': result['EntryDate'],
            'SupplierName': result['SupplierName'],
            'SupplierCode': result['SupplierCode'],
            'PurchaseOrderNo': result['PurchaseOrderNo'],
            'EnteredBy': result['EnteredBy'],
            'Plant': result['Plant'],
            'VehicleNumber': result['VehicleNumber'],
            'VehicleIntime': formatTime(result['VehicleIntime']),
            'InvoiceNo': result['InvoiceNo'],
            'InvoiceDate': result['InvoiceDate'],
            'ReceivedBy': result['ReceivedBy'],
            'Cancelled': result['Cancelled'],
            'Remarks': result['Remarks'],
            'SAP_UUID': result['SAP_UUID'],
            'SAP_Description': result['SAP_Description'],
            'ReceivedBy1': result['ReceivedBy1'],
            'CreatedBy': result['CreatedBy'],
          };
          setState(() {
            inwardList.add(inwardData);
            loading = false;
          });
        }
        if(results.isEmpty){
          setState(() {
            loading = false;
          });
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Data found!')),);
          }
        }
      }
      else{
        setState(() {
          loading = false;
        });
      }
    }catch(e){}
  }
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
  ///Down pdf.
  Future downloadJmiPdf(Map filteredList)async{

    final Uint8List pdfBytes = await inwardPdfGen2(filteredList);

    // Create a blob from the PDF bytes
    final blob = html.Blob([pdfBytes]);

    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a download link
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "${filteredList['GateInwardNo']??""} .pdf")
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
    drawerWidth = 60.0;

    getInwardList().then((value) {
      if(filteredList.isEmpty){
        if(inwardList.length > inwardList.length){
          // for(int i=0; i<startVal + 1000; i++){
          //   filteredList.add(inwardList[i]);
          // }
        } else{
          for(int i=0; i< inwardList.length; i++){
            filteredList.add(inwardList[i]);
          }
        }
        setState(() {
          loading = false;
        });
      }
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
                      title: const Text("Inward List"),
                      centerTitle: true,
                      leading: InkWell(
                        onTap: () {
                          Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
                              drawerWidth: widget.drawerWidth,
                              selectedDestination: widget.selectedDestination,
                              plantValue: widget.plantValue),
                          ));
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
                              // width: MediaQuery.of(context).size.width/1.2,
                              width: 1200,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
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
                                                child: Text("Inward List", style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 35,
                                              width: 120,
                                              child: OutlinedMButton(
                                                text: "+  New Inward",
                                                buttonColor: mSaveButton,
                                                textColor: Colors.white,
                                                borderColor: mSaveButton,
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) =>  AddInward(
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
                                                controller: searchGateInNo,
                                                decoration: searchGateInNoDecoration(hintText: "Search Gate Inward No"),
                                                onChanged: (value) {
                                                  if(value.isEmpty || value == ""){
                                                    startVal = 0;
                                                    filteredList = [];
                                                    setState(() {
                                                      if(inwardList.length > inwardList.length){
                                                        // for(int i=0; i < startVal + 1000; i++){
                                                        //   filteredList.add(inwardList[i]);
                                                        // }
                                                      } else{
                                                        for(int i=0; i < inwardList.length; i++){
                                                          filteredList.add(inwardList[i]);
                                                        }
                                                      }
                                                    });
                                                  } else{
                                                    startVal = 0;
                                                    filteredList = [];
                                                    searchEntryDate.clear();
                                                    searchPONo.clear();
                                                    searchCancel.clear();
                                                    searchSupplierName.clear();
                                                    fetchGateInNo(searchGateInNo.text);
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
                                                decoration: searchSupplierNameDecoration(hintText: "Search Supplier Name"),
                                                onChanged: (value) {
                                                  if(value.isEmpty || value == ""){
                                                    startVal = 0;
                                                    filteredList = [];
                                                    setState(() {
                                                      if(inwardList.length > inwardList.length){
                                                        // for(int i=0; i < startVal + 1000; i++){
                                                        //   filteredList.add(inwardList[i]);
                                                        // }
                                                      } else{
                                                        for(int i=0; i < inwardList.length; i++){
                                                          filteredList.add(inwardList[i]);
                                                        }
                                                      }
                                                    });
                                                  } else{
                                                    startVal = 0;
                                                    filteredList = [];
                                                    searchEntryDate.clear();
                                                    searchPONo.clear();
                                                    searchCancel.clear();
                                                    searchGateInNo.clear();
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
                                                controller: searchPONo,
                                                decoration: searchPoNoDecoration(hintText: "Search PO No"),
                                                onChanged: (value) {
                                                  if(value.isEmpty || value == ""){
                                                    startVal = 0;
                                                    filteredList = [];
                                                    setState(() {
                                                      if(inwardList.length > inwardList.length){
                                                        // for(int i=0; i < startVal + 1000; i++){
                                                        //   filteredList.add(inwardList[i]);
                                                        // }
                                                      } else{
                                                        for(int i=0; i < inwardList.length; i++){
                                                          filteredList.add(inwardList[i]);
                                                        }
                                                      }
                                                    });
                                                  } else{
                                                    startVal = 0;
                                                    filteredList = [];
                                                    searchCancel.clear();
                                                    searchEntryDate.clear();
                                                    searchGateInNo.clear();
                                                    searchSupplierName.clear();
                                                    fetchPoNo(searchPONo.text);
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
                                                      filteredList = inwardList;
                                                    }
                                                    selectEntryDate(context);
                                                    searchCancel.clear();
                                                    searchPONo.clear();
                                                    searchGateInNo.clear();
                                                    searchSupplierName.clear();
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
                                                    // startVal = 0;
                                                    filteredList = [];
                                                    setState(() {
                                                      if(inwardList.length > inwardList.length){
                                                        // for(int i=0; i < startVal + 1000; i++){
                                                        //   filteredList.add(inwardList[i]);
                                                        // }
                                                      } else{
                                                        for(int i=0; i < inwardList.length; i++){
                                                          filteredList.add(inwardList[i]);
                                                        }
                                                      }
                                                    });
                                                  } else{
                                                    startVal = 0;
                                                    filteredList = [];
                                                    searchGateInNo.clear();
                                                    searchPONo.clear();
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
                                                    child: Text("Gate Inward No",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: 4.0),
                                                  child: SizedBox(
                                                    height: 25,
                                                    // width: 150,
                                                    child: Text("Supplier Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: 4.0),
                                                  child: SizedBox(
                                                    height: 25,
                                                    // width: 150,
                                                    child: Text("PO Number",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: 4.0),
                                                  child: SizedBox(
                                                    height: 25,
                                                    // width: 150,
                                                    child: Text("Entry Date",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: 4.0),
                                                  child: SizedBox(
                                                    height: 25,
                                                    // width: 100,
                                                    child: Text("Cancelled",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: 4.0,right: 25),
                                                  child: SizedBox(
                                                    height: 25,
                                                    width: 100,
                                                    child: Text("Download PDF",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: 4.0,right: 25),
                                                  child: SizedBox(
                                                    height: 25,
                                                    // width: 100,
                                                    child: Text("View",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(height: 0.5,color: Colors.grey[500],thickness: 0.5,),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: filteredList.length,
                                        itemBuilder: (context, i) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              MaterialButton(
                                                hoverColor: Colors.blue[50],
                                                onPressed: () {

                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 18.0,top: 4,bottom: 4),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            child: Text(filteredList[i]['GateInwardNo']??"",style: const TextStyle(fontSize: 11)),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            child: Text(filteredList[i]['SupplierName']??"",style: const TextStyle(fontSize: 11)),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            child: Text(filteredList[i]['PurchaseOrderNo']??"",style: const TextStyle(fontSize: 11)),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            // child: Text(filteredList[i]['EntryDate']??"",style: const TextStyle(fontSize: 11)),
                                                            child: Text(filteredList[i]['EntryDate'] != null ? _formatDate(filteredList[i]['EntryDate']) : "", style: const TextStyle(fontSize: 11)),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            child: Text(filteredList[i]['Cancelled']??"",style: const TextStyle(fontSize: 11)),
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0,right: 25),
                                                          child: SizedBox(
                                                            // height: 25,
                                                            width: 100,
                                                            child: InkWell(
                                                              hoverColor: Colors.transparent,
                                                              onTap: () {
                                                                downloadJmiPdf(filteredList[i]);
                                                              },
                                                              child: const Icon(size: 18,
                                                                Icons.download,
                                                                color: Colors.blue,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 4.0, right: 25),
                                                          child: SizedBox(
                                                            // width: 100,
                                                            child: InkWell(
                                                              hoverColor: Colors.transparent,
                                                              onTap: () {
                                                                Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => EditInward(
                                                                  drawerWidth: drawerWidth,
                                                                  selectedDestination: widget.selectedDestination,
                                                                  inwardMap: filteredList[i],
                                                                  plantValue: widget.plantValue,
                                                                ),));
                                                              },
                                                              child: const Icon(size: 18,
                                                                Icons.arrow_circle_right,
                                                                color: Colors.blue,
                                                              ),
                                                            ),
                                                          ),
                                                        ),)
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                          if(i < filteredList.length){

                                          }
                                        },
                                      )
                                    ],
                                  ),
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
              filteredList = inwardList;
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
    searchEntryDate.text = formattedDate;
    fetchEntryDate(pickedDate);
  }
  searchGateInNoDecoration({required String hintText, bool? error}){
    return InputDecoration(
      hoverColor: mHoverColor,
      suffixIcon: searchGateInNo.text.isEmpty?const Icon(Icons.search,size: 18):InkWell(
          onTap: (){
            setState(() {
              searchGateInNo.clear();
              filteredList = inwardList;
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
              filteredList = inwardList;
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
  searchPoNoDecoration({required String hintText, bool? error}){
    return InputDecoration(
      hoverColor: mHoverColor,
      suffixIcon: searchPONo.text.isEmpty?const Icon(Icons.search,size: 18):InkWell(
          onTap: (){
            setState(() {
              searchPONo.clear();
              filteredList = inwardList;
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
  searchCancelDecoration({required String hintText, bool? error}){
    return InputDecoration(
      hoverColor: mHoverColor,
      suffixIcon: searchCancel.text.isEmpty?const Icon(Icons.search,size: 18):InkWell(
          onTap: (){
            setState(() {
              searchCancel.clear();
              filteredList = inwardList;
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

  void fetchGateInNo(String gateInNo) {
    if(inwardList.isNotEmpty && gateInNo.isNotEmpty){
      setState(() {
        filteredList = inwardList.where((inward) => inward["GateInwardNo"].toLowerCase().contains(gateInNo.toLowerCase())).toList();
      });
    }
  }
  void fetchSupplierName(String gateInNo) {
    if(inwardList.isNotEmpty && gateInNo.isNotEmpty){
      setState(() {
        filteredList = inwardList.where((inward) => inward["SupplierName"].toLowerCase().contains(gateInNo.toLowerCase())).toList();
      });
    }
  }
  void fetchPoNo(String poNo) {
    if(inwardList.isNotEmpty && poNo.isNotEmpty){
      setState(() {
        filteredList = inwardList.where((po) => po["PurchaseOrderNo"].toLowerCase().contains(poNo.toLowerCase())).toList();
      });
    }
  }
  void fetchCancel(String cancelled) {
    if(inwardList.isNotEmpty && cancelled.isNotEmpty){
      setState(() {
        filteredList = inwardList.where((cancel) => cancel["Cancelled"].toLowerCase().contains(cancelled.toLowerCase())).toList();
      });
    }
  }
  void fetchEntryDate(DateTime selectedDate){
    if(inwardList.isNotEmpty && selectedDate != null){
      int milliseconds = selectedDate.millisecondsSinceEpoch + selectedDate.timeZoneOffset.inMilliseconds;
      String formattedDate = "/Date($milliseconds)/";
      setState(() {
        filteredList = inwardList.where((item) => item['EntryDate'] == formattedDate).toList();
      });
    }
  }

}
