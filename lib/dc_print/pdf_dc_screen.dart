import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import '../utils/jml_colors.dart';
import 'dc_pdf_formater.dart';

class DcPdfGenerator extends StatefulWidget {
  final double drawerWidth;
  final double selectedDestination;
  const DcPdfGenerator({super.key, required this.drawerWidth, required this.selectedDestination});

  @override
  State<DcPdfGenerator> createState() => _DcPdfGeneratorState();
}

class _DcPdfGeneratorState extends State<DcPdfGenerator> {
  final dcNumberController = TextEditingController();
  bool purchaseOrderError=false;
  final _validate = GlobalKey<FormState>();
  List responseData1=[];
  List responseData2=[];
  List responseGoodsMovementType=[];
  bool loading =false;

  ///pdf downloader async function.
  Future downloadDeliveryPdf(List<dynamic> responseData1, List<dynamic> responseData2)async{
    Uint8List? pdfBytes;
    try{
      if(responseData2[0]['GoodsMovementType']=='161'){
        pdfBytes=  await generatePdfDeliveryNote161(responseData1,responseData2);
      }
      else if(responseData2[0]['GoodsMovementType']=='541'){
        pdfBytes=  await generatePdfDeliveryNote541(responseData1,responseData2);
      }
      else if(responseData2[0]['GoodsMovementType']=='Z41'){
        pdfBytes=  await generatePdfDeliveryZ41(responseData1,responseData2);
      }
      else if(responseData2[0]['GoodsMovementType']=='303'){
        // print('---------------GoodsMovementType------------------');
        // print(responseData2[0]['GoodsMovementType']);
        pdfBytes=  await generatePdfDelivery303(responseData1,responseData2);
      }


      // print('-----Uint8List-----');
      // print(pdfBytes.runtimeType);

      // Create a blob from the PDF bytes
      final blob = html.Blob([pdfBytes]);

      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create a download link
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "document.pdf")
        ..text = "Download PDF";

      // Append the anchor element to the body
      html.document.body?.append(anchor);

      // Click the anchor to initiate download
      anchor.click();

      // Clean up resources
      html.Url.revokeObjectUrl(url);
      anchor.remove();
    }
    catch(e){
      print("-----Exception--From Movement Type--------------");
      print(e);
      // if(mounted){
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("TooManyPages Found Please Enter Another DC Number."),
      //     duration: Duration(seconds: 8),));
      // }
    }
  }

  //Goods Movement Type 541.
  Future fetchData541(String dcNumber, List<dynamic> responseGoodsMovementType)async{
   String header541= "${StaticData.apiURL}/YY1_GOODS_MOVEMENT_541_CDS/YY1_GOODS_MOVEMENT_541?filter=MaterialDocument eq '$dcNumber' and IsAutomaticallyCreated eq  ''";


    final res541= await http.get(Uri.parse(header541),
      headers: {
        'Authorization': StaticData.basicAuth,
      },
    );
    final response = jsonDecode(res541.body);
    try{
      setState(() {
        if(res541.statusCode==200){
          responseData1 =response['d']['results'];

          if(responseData1.isEmpty){
            if(mounted){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Data available Please Check !!!..'),
                duration: Duration(seconds: 8),));
            }
          }
          else{
            downloadDeliveryPdf(responseData1,responseGoodsMovementType);
          }
        }
        else if(res541.statusCode == 400){
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

        loading=false;
      });
    }
    catch(e){
      print('------Exception--541----');
      print(e);
    }
  }

  //Goods Movement Type 161.
  Future fetchData161(String dcNumber, List<dynamic> responseGoodsMovementType)async{

    String url1new ="${StaticData.apiURL}/YY1_DELIVERY_DOCUMENT_CDS/YY1_DELIVERY_DOCUMENT?filter=MaterialDocument eq '$dcNumber'";


    final res161= await http.get(Uri.parse(url1new),
      headers: {
        'Authorization': StaticData.basicAuth,
      },
    );
    final response = jsonDecode(res161.body);
    try{
      setState(() {
        if(res161.statusCode==200){
          responseData2 =response['d']['results'];

          if(responseData2.isEmpty){
            if(mounted){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Data available Please Check !!!..'),
                duration: Duration(seconds: 8),));
            }
          }
          else{
            downloadDeliveryPdf(responseData2,responseGoodsMovementType);
          }
        }
        else if(res161.statusCode == 400){
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

        loading=false;
      });
    }
    catch(e){
      print('------Exception--161----');
      print(e);
    }
  }

  //Goods Movement Type 303.
  Future fetchData303(String dcNumber, List<dynamic> responseGoodsMovementType)async{
    ///Old API.
    //String url1new ="${StaticData.apiURL}/YY1_GOODS_MOVEMENT_303_CDS/YY1_Goods_movement_303?filter=MaterialDocument eq '$dcNumber' and IsAutomaticallyCreated eq  ''";
    ///New Api.
    String url1new ="${StaticData.apiURL}/YY1_303_MOVE_TYPE_CDS/YY1_303_MOVE_TYPE?format=json&filter=MaterialDocument eq '$dcNumber' and IsAutomaticallyCreated eq ''";

    final res161= await http.get(Uri.parse(url1new),
      headers: {
        'Authorization': StaticData.basicAuth,
      },
    );
    final response = jsonDecode(res161.body);
    try{
      setState(() {
        if(res161.statusCode==200){
          responseData2 =response['d']['results'];

          if(responseData2.isEmpty){
            if(mounted){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Data available Please Check !!!..'),
                duration: Duration(seconds: 8),));
            }
          }
          else{
            downloadDeliveryPdf(responseData2,responseGoodsMovementType);
          }
        }
        else if(res161.statusCode == 400){
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

        loading=false;
      });
    }
    catch(e){
      print('------Exception--303----');
      print(e);
    }
  }

  //Goods Movement Type API.
  Future getGoodsMovementType(String dcNumber)async{
    ///Old.
    //String url2 = "${StaticData.apiURL}/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentItem?format=json&filter=MaterialDocument eq '$dcNumber' and IsAutomaticallyCreated eq ''";
    ///New.
    String url2= "${StaticData.apiURL}/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentItem?format=json&filter=MaterialDocument eq '$dcNumber' and IsAutomaticallyCreated eq ''";

    final resData1 = await http.get(Uri.parse(url2),
      headers: {
        'Authorization': StaticData.basicAuth,
      },
    );
    final movementType = jsonDecode(resData1.body);
    try{

      setState(() {
        if(resData1.statusCode==200){
          responseGoodsMovementType = movementType['d']['results'];
          if(responseGoodsMovementType.isEmpty){
            if(mounted){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No Data available Please Check !!!..'),
                duration: Duration(seconds: 8),));
            }
          }
          // For Both Goods Movement Type.
          else if(responseGoodsMovementType[0]['GoodsMovementType']=='541' || responseGoodsMovementType[0]['GoodsMovementType']=='Z41'){
            print('--------GoodsMovementType------');
            print(responseGoodsMovementType[0]['GoodsMovementType']);
            fetchData541(dcNumber,responseGoodsMovementType);
          }
          else if(responseGoodsMovementType[0]['GoodsMovementType']=='161'){
            print('--------GoodsMovementType------');
            print(responseGoodsMovementType[0]['GoodsMovementType']);
            fetchData161(dcNumber,responseGoodsMovementType);
          }
          else if(responseGoodsMovementType[0]['GoodsMovementType']=='303'){
            print('--------GoodsMovementType------');
            print(responseGoodsMovementType[0]['GoodsMovementType']);
            fetchData303(dcNumber,responseGoodsMovementType);
          }
          else{
            if(mounted){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goods Movement Type Not Found 541 or 161 or Z41,Please Check DC Number.'),
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

        loading = false;
      });
    }

    catch(e){
      print('----------Exception---Form--API CALL----');
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
                const Text("DC Number",style: TextStyle(fontSize: 12)),
                Padding(
                  padding: const EdgeInsets.only(left: 100),
                  child: SizedBox(
                    width: 200,
                    child: TextFormField(
                      style: const TextStyle(fontSize: 11),
                      controller: dcNumberController,
                      validator: (value){
                        if(value == null || value.isEmpty) {
                          setState(() {
                            purchaseOrderError=true;
                          });
                          return 'Please Enter DC NUmber';
                        }
                        setState(() {
                          purchaseOrderError=false;
                        });
                        return null;
                      },
                      decoration: customerFieldDecoration(controller: dcNumberController, hintText: "Enter DC Number", error: purchaseOrderError),
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
                        });
                        getGoodsMovementType(dcNumberController.text);
                      }

                    }),
                const SizedBox(width: 20,),
                loading? const Row(children: [
                  SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator()),
                  SizedBox(width: 5,),
                  Text("Loading Please Wait.."),
                ],):const Text(""),
              ],
            ),
          ]),
        ),
      ),
    );
  }
  //TextField Decoration.
  customerFieldDecoration({required TextEditingController controller, required String hintText, required bool error, Function? onTap}) {
    return InputDecoration(
      constraints: BoxConstraints(maxHeight: error == true ? 50 : 30),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 11),
      border:
      const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
      counterText: '',
      contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: mTextFieldBorder)),
      focusedBorder:
      const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
    );
  }
}
