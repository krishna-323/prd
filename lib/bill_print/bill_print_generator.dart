import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import '../utils/jml_colors.dart';
import 'bill_pdf_formater.dart';



class BillPrintScreen extends StatefulWidget {
  final double drawerWidth;
  final double selectedDestination;
  const BillPrintScreen({super.key, required this.drawerWidth, required this.selectedDestination});

  @override
  State<BillPrintScreen> createState() => _BillPrintScreenState();
}

class _BillPrintScreenState extends State<BillPrintScreen> {
  final billDateController = TextEditingController();
  bool billDateError = false;
  final _validate = GlobalKey<FormState>();
  List responseData1=[];
  bool loading=false;
  int fileCount = 0;
  int totalCount = 0;
  @override
  initState(){
    super.initState();

  }

  //API Call.
  Future billDocument(String billDate)async{
    print('----------billDate-----');
    print(billDate);
    String addVoData = "${billDate}T00:00";
    print(addVoData);

    ///Quality URL For PDFs.
    // String url = "Https://JMIApp-terrific-eland-ao.cfapps.in30.hana.ondemand.com/api/sap_odata_get/Test/ZSB_PAYINV_V5/ZPAYINV_EXPOSE_V5?filter=paymentdate eq datetime'$billDate'";
    ///PRD URL For PDFs.
    String url = "Https://JMIApp-terrific-eland-ao.cfapps.in30.hana.ondemand.com/api/sap_odata_get/PRD/ZSB_PAYINV_V5/ZPAYINV_EXPOSE_V5?filter=paymentdate eq datetime'$addVoData'&top=10000";
    final resData1 = await http.get(Uri.parse(url),
        headers: {
          "Authorization":StaticData.basicAuth
        }
    );
    final movementType = jsonDecode(resData1.body);
    try{

      if(resData1.statusCode==200){
        responseData1 = movementType['d']['results'];
        setState(() {
          ///TO Get Total Responses.
          //totalCount = responseData1.length;
          // print('-------totalCount------');
          // print(totalCount);
        });
        Map groupedData = groupBy(responseData1, (item) {

          // print('------item--------');
          // print(item);
          return item['AccountingDocument'];
        });
        // print('+++++++++++++++++++++++++++++++++++++++++++++++++');
        // print(jsonEncode(groupedData));
        billPDFGenerator(groupedData).whenComplete(() {
          setState(() {
            loading = false;
            billDateController.clear();
          });
        });

        if(responseData1.isEmpty){
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Data available Please Check !!!..'),
              duration: Duration(seconds: 8),));
          }
        }
      }
      else if(resData1.statusCode == 400){
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Data Available,Please Check DC Number.'),
            duration: Duration(seconds: 8),));
        }
      }
      else {
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Something Went Wrong Please Check !!!..'),
            duration: Duration(seconds: 8),));
        }
      }



    }

    catch(e){
      print('----------Exception---------');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Form(key: _validate,
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Bill Date",style: TextStyle(fontSize: 12)),
                Padding(
                  padding: const EdgeInsets.only(left: 100),
                  child: SizedBox(
                    width: 200,
                    child:
                    TextFormField(
                      style: const TextStyle(fontSize: 11),
                      controller: billDateController,
                      validator: (value){
                        if(value == null || value.isEmpty) {
                          setState(() {
                            billDateError=true;
                          });
                          return 'Please Enter Bill Date';
                        }
                        setState(() {
                          billDateError=false;
                        });
                        return null;
                      },
                      decoration: entryDateFieldDecoration(hintText: "Select Bill Date",error: billDateError),
                      onTap: () {
                        selectEntryDate(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 15,),
                MaterialButton(
                    color: Colors.blue,
                    child:const Text("Download",style: TextStyle(color: Colors.white),),
                    onPressed: (){
                      if(_validate.currentState!.validate()){
                        setState(() {
                          loading =true;
                          //API Call.
                          billDocument(billDateController.text);
                        });

                      }

                    }),
                const SizedBox(width: 20,),
                if(loading)...{
                  const   Row(children: [
                    SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator()),
                    SizedBox(width: 5,),
                    Text("Loading Please Wait.."),
                  ],),
                }
                else...{
                  const Text(""),
                },
                const SizedBox(width: 15,),

                if(fileCount > 0)...{
                  Builder(
                      builder: (context) {
                        return Text("$fileCount Of $totalCount");
                      }
                  ),
                }
                else...{
                  const Text("")
                }

              ],
            ),
          ]),
        ),
      ),
    );
  }

  //TextField Decoration.
  entryDateFieldDecoration( {required String hintText, bool? error,}) {
    return  InputDecoration(
      constraints: BoxConstraints(maxHeight: error==true ? 60:30),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 11),
      suffixIcon: billDateController.text.isNotEmpty?InkWell(
          onTap: (){
            setState(() {
              billDateController.clear();
            });
          },
          child: const Icon(Icons.close,size: 14,color:Colors.grey ,)):
      const Icon(Icons.calendar_month, size: 16, color: Colors.grey,),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color:  Colors.blue)),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
      enabledBorder:const OutlineInputBorder(borderSide: BorderSide(color: mTextFieldBorder)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
    );
  }
  //Date Picker.
  selectEntryDate(BuildContext context) async{
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now()
    );
    if(pickedDate != null) {
      setState(() {
        String formattedDate = DateFormat("yyyy-MM-dd").format(pickedDate);
        billDateController.text = formattedDate;
        print('--------Selected Bill Date---------');
        print(billDateController.text);
      });
    }
  }




  Future<void> billPDFGenerator(Map dividedMap) async {
    String keyStore = "";
    try {
      // print('---------dividedMap---------');
      // print(dividedMap);

      for (var key in dividedMap.keys) {

        List billList = dividedMap[key]!;
        // print('------------check----------');
        // print(billList);
        // print(billList.length);
        Uint8List pdfBytes = await generateBillPDF(billList);


        // String data = base64Encode(pdfBytes);
        // print('-------------------data-------------------------');
        // print(data);

        // Create a blob from the PDF bytes
        final blob = html.Blob([pdfBytes]);

        final url = html.Url.createObjectUrlFromBlob(blob);

        // Create a download link
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "$key.pdf")
          ..text = "Download PDF";

        // Append the anchor element to the body
        html.document.body?.append(anchor);

        // Click the anchor to initiate download
        anchor.click();

        // Clean up resources.
        html.Url.revokeObjectUrl(url);
        anchor.remove();
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          fileCount++;
          // print('-----------fileCount-----');
          // print(fileCount);

          keyStore = key;
          totalCount = dividedMap.keys.length;
          print('--------totalCount--------');
          print(totalCount);
        });
      }

    } catch (e) {
      print("--------Exception While Generating PDF-------");
      print(e);
      print('---------AccountingDocument----------');
      print(keyStore);
    }
  }

}
