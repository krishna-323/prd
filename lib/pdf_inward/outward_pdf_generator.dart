import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

Future<Uint8List> outwardPdfGen(Map filteredList) async{
  TextStyle fontSize9 =const TextStyle(fontSize: 11 );
  TextStyle fontSize10WithBold = TextStyle(fontSize: 14,color: PdfColors.black,fontWeight: FontWeight.bold,);
  TextStyle fontSize20Heading =const TextStyle(fontSize: 20,color: PdfColors.black,);
  double textWidth= 100;
  String convertTimestampToDate(String timestamp){
    String timestampString = timestamp.replaceAll(RegExp(r'[^0-9]'), '');
    int millisecondsSinceEpoch = int.parse(timestampString);
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    String formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year.toString()}';

    return formattedDate;
  }
  final pdf = Document();
  final image = MemoryImage(
    (await rootBundle.load('assets/logo/jmi_logo.png')).buffer.asUint8List(),
  );
  pdf.addPage(
      MultiPage(
        margin:const EdgeInsets.all(35),
        crossAxisAlignment: CrossAxisAlignment.start,
        build: (context) => [
          Container(
              height: 750,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: PdfColors.black),
                  top: BorderSide(color: PdfColors.black),
                  right: BorderSide(color: PdfColors.black),
                  bottom: BorderSide(color: PdfColors.black),
                ),
              ),
              child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Display the image
                        Image(image, width: 70, height: 70),
                        SizedBox(width: 100),
                        Text("JM Frictech India Private Limited",style: fontSize20Heading),
                      ],
                    ),
                    Divider(color: PdfColors.black,height: 1),
                    SizedBox(height: 5),
                    Text("GATE OUTWARD",style: TextStyle(fontWeight: FontWeight.bold)),
                    Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Outward Details", style: fontSize10WithBold),
                              SizedBox(height: 10),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      // height: 100,
                                      width: 200,
                                      // color: PdfColors.red,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children:[
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: textWidth,child: Text("Gate Inward No", style: fontSize9),),
                                                  SizedBox(width: 5,child: Text(":")),
                                                  Text("${filteredList["GateOutwardNo"]??""}", style: fontSize9),
                                                ]
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: textWidth,child: Text("Entry Date", style: fontSize9),),
                                                  SizedBox(width: 5,child: Text(":")),
                                                  Text(convertTimestampToDate(filteredList["EntryDate"]??""), style: fontSize9),
                                                ]
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: textWidth,child: Text("Entry Time", style: fontSize9),),
                                                  SizedBox(width: 5,child: Text(":")),
                                                  Text("${filteredList["EntryTime"]??""}", style: fontSize9),
                                                ]
                                            ),
                                          ]
                                      ),
                                    ),
                                    Container(
                                      // height: 100,
                                        width: 200,
                                        // color: PdfColors.blue,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(width: textWidth,child: Text("Plant", style: fontSize9),),
                                                    SizedBox(width: 5,child: Text(":")),
                                                    Text("${filteredList["Plant"]??""}", style: fontSize9),
                                                  ]
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(width: textWidth,child: Text("Vehicle Number", style: fontSize9),),
                                                    SizedBox(width: 5,child: Text(":")),
                                                    Text("${filteredList["VehicleNumber"]??""}", style: fontSize9),
                                                  ]
                                              ),
                                            ]
                                        )
                                    ),
                                  ]
                              ),
                            ]
                        )
                    ),
                    SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Customer Details", style: fontSize10WithBold),
                              SizedBox(height: 10),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      // height: 100,
                                      width: 200,
                                      // color: PdfColors.red,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children:[
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: textWidth,child: Text("Customer Name", style: fontSize9),),
                                                  SizedBox(width: 5,child: Text(":")),
                                                  Expanded(child: Text("${filteredList["SupplierName"]??""}", style: fontSize9),),
                                                  // Expanded(child: Text("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww",))
                                                ]
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: textWidth,child: Text("Customer Code", style: fontSize9),),
                                                  SizedBox(width: 5,child: Text(":")),
                                                  Text("${filteredList["SupplierCode"]??""}", style: fontSize9),
                                                ]
                                            ),
                                            // SizedBox(height: 5),
                                            // Row(
                                            //     crossAxisAlignment: CrossAxisAlignment.start,
                                            //     children: [
                                            //       Container(width: textWidth,child: Text("Purchase Order No", style: fontSize9),),
                                            //       SizedBox(width: 5,child: Text(":")),
                                            //       Text("${filteredList["PurchaseOrderNo"]??""}", style: fontSize9),
                                            //     ]
                                            // ),
                                            SizedBox(height: 5),
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: textWidth,child: Text("Invoice Type", style: fontSize9),),
                                                  SizedBox(width: 5,child: Text(":")),
                                                  Text("${filteredList["PurchaseOrderNo"]??""}", style: fontSize9),
                                                ]
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: textWidth,child: Text("Invoice No", style: fontSize9),),
                                                  SizedBox(width: 5,child: Text(":")),
                                                  Text("${filteredList["InvoiceNo"]??""}", style: fontSize9),
                                                ]
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(width: textWidth,child: Text("Invoice Date", style: fontSize9),),
                                                  SizedBox(width: 5,child: Text(":")),
                                                  Text(convertTimestampToDate(filteredList["InvoiceDate"]??""), style: fontSize9),
                                                ]
                                            ),
                                          ]
                                      ),
                                    ),
                                  ]
                              ),
                            ]
                        )
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Security Details", style: fontSize10WithBold),
                            SizedBox(height: 10),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      children: [
                                        Container(
                                          // height: 100,
                                          width: 200,
                                          // color: PdfColors.red
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children:[
                                                Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(width: textWidth,child: Text("Entered By", style: fontSize9),),
                                                      SizedBox(width: 5,child: Text(":")),
                                                      Text("${filteredList["EnteredBy"]??""}", style: fontSize9),
                                                    ]
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(width: textWidth,child: Text("Remarks", style: fontSize9),),
                                                      SizedBox(width: 5,child: Text(":")),
                                                      Expanded(child:  Text("${filteredList["Remarks"]??""}", style: fontSize9),)
                                                    ]
                                                ),
                                                SizedBox(height: 20),
                                                Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(width: textWidth,child: Text("Received By", style: fontSize9),),
                                                      SizedBox(width: 5,child: Text(":")),
                                                      Text("", style: fontSize9),
                                                    ]
                                                ),
                                              ]
                                          ),
                                        ),
                                      ]
                                  ),
                                  // Column(
                                  //     children: [
                                  //       Container(
                                  //           height: 100,
                                  //           width: 200,
                                  //           color: PdfColors.blue
                                  //       ),
                                  //     ]
                                  // ),
                                ]
                            ),
                          ]
                      ),
                    )
                  ]
              )
          ),
        ],
      )
  );
  return pdf.save();
}