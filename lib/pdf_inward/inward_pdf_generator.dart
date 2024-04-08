import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

Future<Uint8List> inwardPdfGen(Map filteredList) async {


  ///Styles.
  // TextStyle blueGrey200 = const TextStyle(color: PdfColors.blueGrey300);
  TextStyle fontSize9 =const TextStyle(fontSize: 11 );
  TextStyle fontSize10WithBold = TextStyle(fontSize: 14,color: PdfColors.black,fontWeight: FontWeight.bold,);
  //TextStyle fontSize9WidthBold =TextStyle(fontWeight: FontWeight.bold,fontSize: 9,color: PdfColors.white,);
  TextStyle fontSize20Heading =const TextStyle(fontSize: 20,color: PdfColors.black,);
  double textWidth= 100;

  //date conversion.
  String convertTimestampToDate(String timestamp) {
    // Extract the timestamp from the string
    String timestampString = timestamp.replaceAll(RegExp(r'[^0-9]'), '');

    // Convert the timestamp string to an integer
    int millisecondsSinceEpoch = int.parse(timestampString);

    // Create a DateTime object from the millisecondsSinceEpoch
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

    // Format the DateTime object into the desired format
    String formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year.toString()}';

    return formattedDate;
  }
  final pdf = Document();



  // Load the image from assets
  final image = MemoryImage(
    (await rootBundle.load('assets/logo/jmi_logo.png')).buffer.asUint8List(),
  );
  ///This Does't not have boards.
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

                // bottom: BorderSide(color: PdfColor.fromInt(0xFF9E9E9E),width: 0.3),
                // right: BorderSide(color: PdfColor.fromInt(0xFF9E9E9E),width: 0.3),
                // left: BorderSide(color: PdfColor.fromInt(0xFF9E9E9E),width: 0.3),
                // top: BorderSide(color: PdfColor.fromInt(0xFF9E9E9E),width: 0.3),
              ),
            ),

            child: Column(children: [
              //First.
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
              Text("GATE INWARD",style: TextStyle(fontWeight: FontWeight.bold)),
              Padding(padding:const EdgeInsets.all(30),child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Inward Details", style: fontSize10WithBold),
                          SizedBox(height: 10),
                          Row(children: [
                            Container(width: textWidth,child: Text("Gate Inward No", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["GateInwardNo"]??""}", style: fontSize9),
                          ]),
                          Row(children: [
                            Container(width: textWidth,child: Text("Entry Date", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text(convertTimestampToDate(filteredList["EntryDate"]??""), style: fontSize9),
                          ]),
                          Row(children: [
                            Container(width: textWidth,child: Text("Entry Time", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["EntryTime"]??""}", style: fontSize9),
                          ]),
                          SizedBox(height: 10),
                          Text("Supplier Details", style: fontSize10WithBold),
                          SizedBox(height: 10),
                          Row(children: [
                            Container(width: textWidth,child: Text("Supplier Name", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["SupplierName"]??""}", style: fontSize9),
                          ]),
                          Row(children: [
                            Container(width: textWidth,child: Text("Supplier Code", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["SupplierCode"]??""}", style: fontSize9),
                          ]),
                          Row(children: [
                            Container(width: textWidth,child: Text("Purchase Order No", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["PurchaseOrderNo"]??""}", style: fontSize9),
                          ]),
                          Row(children: [
                            Container(width: textWidth,child: Text("PO Type", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["ReceivedBy"]??""}", style: fontSize9),
                          ]),
                          Row(children: [
                            Container(width: textWidth,child: Text("Invoice No", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["InvoiceNo"]??""}", style: fontSize9),
                          ]),
                          Row(children: [
                            Container(width: textWidth,child: Text("Invoice Date", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text(convertTimestampToDate(filteredList["InvoiceDate"]??""), style: fontSize9),
                          ]),
                        ],
                      ),
                      SizedBox(width: 80),

                      // Column 2
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Row(children: [
                            Container(width: textWidth,child: Text("Plant", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["Plant"]??""}", style: fontSize9),
                          ]),
                          Row(children: [
                            Container(width: textWidth,child: Text("Vehicle Number", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["VehicleNumber"]??""}", style: fontSize9),
                          ]),
                          Row(children: [
                            Container(width: textWidth,child: Text("Vehicle In-time", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["EntryTime"]??""}", style: fontSize9),

                          ]),
                          SizedBox(height: 30),

                          Row(children: [
                            Container(width: textWidth,child: Text("Type", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["SAP_Description"]??""}", style: fontSize9),
                          ]),
                          Row(children: [
                            Container(width: textWidth,child: Text("Reference Number", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["ReceivedBy1"]??""}", style: fontSize9),
                          ]),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Section 3
                  Text("Security Details", style: fontSize10WithBold),
                  SizedBox(height: 10),
                  Row(
                  //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Column 1
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(children: [
                            Container(width: textWidth,child: Text("Entered By", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["EnteredBy"]??""}", style: fontSize9),
                          ]),
                          Row(children: [
                            Container(width: textWidth,child: Text("Remarks", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("${filteredList["Remarks"]??""}", style: fontSize9),
                          ]),
                          SizedBox(height: 10),
                          Row(children: [
                            Container(width: textWidth,child: Text("Received By", style: fontSize9),),
                            SizedBox(width: 5,child: Text(":")),
                            Text("", style: fontSize9),
                          ]),
                        ],
                      ),
                      // Column 2
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     // Row(children: [
                      //     //   Container(width: textWidth,child: Text("Received By", style: fontSize9),),
                      //     //   SizedBox(width: 5,child: Text(":")),
                      //     //   Text("", style: fontSize9),
                      //     // ]),
                      //
                      //   ],
                      // ),
                    ],
                  ),
                ],
              )


              )
            ]) )
      ],
    ),
  );

  // log('------pdf-------');
  // log(pdf.runtimeType.toString());

  // Return PDF as bytes.
  return pdf.save();
}