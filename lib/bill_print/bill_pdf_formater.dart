import 'dart:typed_data';
import 'package:indian_currency_to_word/indian_currency_to_word.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart';

Future<Uint8List> generateBillPDF(List<dynamic> billList) async {
  // print('-----------billList-------------');
  // print(billList);
  final converter = AmountToWords();
  String totalAmount='';
  String convertPaisa = '';
  String finalTotalAmount= "";

  try{
    ///Replacing - to ''.
    totalAmount = billList[0]["TotalInvoicePaidAmount"].replaceAll('-','');

    ///Converting in To Amount In Words and also replacing Thousands To Thousand.
    convertPaisa = converter.convertAmountToWords(double.parse(totalAmount)).replaceAll("Thousands", "Thousand");

    // print('------convertPaisa-------');
    // print(convertPaisa);

    if(convertPaisa.contains("Paise")){
      finalTotalAmount = convertPaisa.replaceAll("Paise", "Paisa");
      // print('--------------------paisa-------------');
      // print(finalTotalAmount);

    }
    else{
      finalTotalAmount = convertPaisa;
    }
  }
  catch(e){
    print('--------Exception---------');
    print(e);
  }


  ///Styles.
  // TextStyle blueGrey200 = const TextStyle(color: PdfColors.blueGrey300);
  TextStyle fontSize15WithBold =  TextStyle(fontWeight: FontWeight.bold,fontSize: 15);

  TextStyle fontSize9WithBold =  TextStyle(fontWeight: FontWeight.bold,fontSize: 9);
  //TextStyle fontSize9 =const TextStyle(fontSize: 9);
  TextStyle fontSize9 =const TextStyle(fontSize: 9);
  TextStyle fontSize8WidthBold =TextStyle(fontWeight: FontWeight.bold,fontSize: 8,color: PdfColors.black);

  final pdf = Document();

  // // Load the image from assets
  // final image = MemoryImage(
  //   (await rootBundle.load('assets/logo/jmi_logo.png')).buffer.asUint8List(),
  // );
  BorderSide borderStyle= const BorderSide(color: PdfColors.black,width: 0.5);


  //Date Conversion.
  String formatDate(String dateString) {
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

  // String formatToTwoDecimal(double number) {
  //   // Convert the number to a string with two decimal places
  //   String formattedNumber = number.toStringAsFixed(2);
  //
  //   // If the number is an integer, remove the ".00"
  //   if (formattedNumber.endsWith('.00')) {
  //     formattedNumber = formattedNumber.substring(0, formattedNumber.length - 3);
  //   }
  //   return formattedNumber;
  // }
  double textWidth1 = 50;
  double textWidth2= 80;
  Text collenStyle =  Text(" : ",style: fontSize8WidthBold);

  pdf.addPage(
    MultiPage(
      //maxPages: 200,
      margin:const EdgeInsets.all(20),
      crossAxisAlignment: CrossAxisAlignment.start,
      build: (context) => [
        Container(
          width: 1000,
          //height: 800,
          decoration:  const BoxDecoration(
            border: Border(
              // left: borderStyle,
              // top:borderStyle,
              // right:borderStyle,
              // bottom:borderStyle,
            ),
          ),
          child: Column(children:[
            SizedBox(height: 30),
            Text(
                'JM FRICTECH INDIA PVT. LTD',
                style:fontSize15WithBold
            ),
            Text('',style: fontSize9),
            SizedBox(height: 20),
            Text(
                'BANK PAYMENT ADVICE',
                style: fontSize15WithBold
            ),
            SizedBox(height: 20),
            //First Table.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Left side
                Flexible(child: Container(
                    height: 70,
                    decoration:  BoxDecoration(
                      border: Border(
                        left: borderStyle,
                        top:borderStyle,
                        right:borderStyle,
                        bottom:borderStyle,
                      ),
                    ),
                    child:  Padding(padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text("Vendor Code",style: fontSize8WidthBold),
                          Row(children: [
                            Container(width: textWidth1,child: Text('Vendor Code',style: fontSize8WidthBold)),
                            Text(" : ",style: fontSize8WidthBold),
                            Text("${billList[0]['SupplierCode']??""}",style: fontSize9)
                          ]),
                          SizedBox(height: 3),
                          //1 st.
                          Row(children: [
                            Container(width: textWidth1,child: Text('Paid To',style: fontSize8WidthBold)),
                            Text(" : ",style: fontSize8WidthBold),
                            Text("${billList[0]['SupplierName']??""}",style: fontSize9)
                          ]),
                          ///Address and Narration.
                          // //2 sd.
                          // Row(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Container(width: textWidth1,child: Text('Address',style: fontSize8WidthBold)),
                          //       Text(" : ",style: fontSize8WidthBold),
                          //       Column(children: [
                          //         Container(width: 200,
                          //             child:  Text("",
                          //                 style: fontSize9)
                          //         )
                          //       ])
                          //     ]),
                          // //3 rd.
                          // Row(children: [
                          //   Container(width: textWidth1,child: Text('Naration',style: fontSize8WidthBold)),
                          //   Text(" : ",style: fontSize8WidthBold),
                          //   Text("",style: fontSize9)
                          // ]),
                        ],
                      ),)),),

                //Right side.
                Flexible(child:  Container(
                    height: 70,
                    //width: 280,
                    decoration:  BoxDecoration(
                      border: Border(
                        top:borderStyle,
                        right:borderStyle,
                        bottom:borderStyle,
                      ),
                    ),
                    child: Padding(padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //1 st.
                          Row(children: [
                            Container(width: textWidth2,child: Text('Voucher No',style: fontSize8WidthBold)),
                            collenStyle,
                            Text("${billList[0]['AccountingDocument']??""}",style: fontSize9)
                          ]),

                          //2 sd.
                          Row(children: [
                            Container(width: textWidth2,child: Text('Doc. Date',style: fontSize8WidthBold)),
                            collenStyle,
                            Text(billList[0]['paymentdate'] != null ? formatDate(billList[0]['paymentdate']) : "",style: fontSize9)
                          ]),
                          ///Bank And Account.
                          //3 rd.
                          // Row(children: [
                          //   Container(width: textWidth2,child: Text('Bank',style: fontSize8WidthBold)),
                          //   collenStyle,
                          //   Text("",style: fontSize9)
                          // ]),
                          // //4 th.
                          // Row(children: [
                          //   Container(width: textWidth2,child: Text('Acc. No',style: fontSize8WidthBold)),
                          //   collenStyle,
                          //   Text("",style: fontSize9)
                          // ]),
                          ///Payment Mode/ Cheque No/Date,Charges.
                          //5 th.
                          // Row(children: [
                          //   Container(width: textWidth2,child: Text('Payment Mode',style: fontSize8WidthBold)),
                          //   collenStyle,
                          //   Text("",style: fontSize10)
                          // ]),
                          // //6 th.
                          // Row(children: [
                          //   Container(width: textWidth2,child: Text('Cheque No./Date',style: fontSize8WidthBold)),
                          //   collenStyle,
                          //   Text("",style: fontSize10)
                          // ]),
                          // //7 th.
                          // Row(children: [
                          //   Container(width: textWidth2,child: Text('Charges',style: fontSize8WidthBold)),
                          //   collenStyle,
                          //   Text("",style: fontSize10)
                          // ]),
                          //8 th.
                          Row(children: [
                            Container(width: textWidth2,child: Text('Currency',style: fontSize8WidthBold)),
                            collenStyle,
                            Text("INR",style: fontSize9)
                          ]),
                          //9 th
                          Row(children: [
                            Container(width: textWidth2,child: Text('Payment Amount',style: fontSize8WidthBold)),
                            collenStyle,
                            Text(totalAmount,style: fontSize9)
                          ]),
                        ],
                      ),)))
              ],
            ),
            SizedBox(height: 20),
            ///SupplierName and Amount.
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //   Text(
            //     '${billList[0]['SupplierName']??""}',
            //     style: fontSize8WidthBold
            //   ),
            //   Text(
            //       totalAmount,
            //       style: fontSize8WidthBold
            //   ),
            // ]),
            //   SizedBox(height: 20),
            ///Table Code.(old).
            // TableHelper.fromTextArray(
            //   //This is for Header.
            //   headerStyle: fontSize9WithBold,
            //   //This Is for Table.
            //   cellStyle: fontSize9,
            //
            //   headers: [
            //     'Bill Number',
            //     'Bill Date',
            //     'Bill Amount',
            //     'TDS Amount',
            //     'Pay Amount'
            //   ],
            //
            //   ///Not working Train and Error Method.
            //   //cellAlignment: const Alignment(10, 0),
            //
            //
            //   data:
            //   [
            //     for(int i=0;i<billList.length;i++)
            //       [
            //         ///SupplierInvoice and JENumber.
            //         //(billList[i]['SupplierInvoice']!="" || billList[i]['SupplierInvoice']!='null')?billList[i]['SupplierInvoice']:billList[i]['JENumber'],
            //
            //         '${billList[i]['InvoiceReference']??""}',
            //         billList[i]['InvoiceDate'] != null ? formatDate(billList[i]['InvoiceDate']) : "",
            //         '${billList[i]['InvoiceAmount']??""}',
            //         '${billList[i]["TdsAmount"]??""}',
            //         '${billList[i]["PaidAmount"]??""}'
            //       ],
            //   ],
            //   cellAlignments: {
            //     0: Alignment.centerLeft,
            //     1: Alignment.centerLeft,
            //     2: Alignment.centerRight,
            //     3: Alignment.centerRight,
            //     4: Alignment.centerRight,
            //   },
            // ),

            ///Table Header.
            Container(height: 25,
                decoration:  BoxDecoration(
                  ///color
                  // color: PdfColors.grey,
                  border: Border(
                      top:borderStyle,
                      bottom:borderStyle,
                      right: borderStyle,
                      left: borderStyle
                  ),
                ),
                child: Row(children: [

                  Expanded(flex: 1,child: Padding(padding: const EdgeInsets.only(left: 5),
                      child: Text('Bill Number',style: fontSize9WithBold)
                  )),
                  Container(height: 25,width: 0.5,color: PdfColors.black),
                  Expanded(flex: 1,child: Padding(padding: const EdgeInsets.only(left: 5),
                      child: Text('Bill Date',style: fontSize9WithBold)
                  )),
                  Container(height: 25,width: 0.5,color: PdfColors.black),
                  Expanded(flex: 1,child: Padding(padding: const EdgeInsets.only(left: 5,right: 5),
                      child: Align(alignment: Alignment.centerRight,
                          child: Text('Bill Amount',style: fontSize9WithBold))
                  )),
                  Container(height: 25,width: 0.5,color: PdfColors.black),
                  Expanded(flex: 1,
                      child:Padding(padding: const EdgeInsets.only(left: 5,right: 5),
                          child:  Align(alignment: Alignment.centerRight,
                              child: Text('TDS Amount',style: fontSize9WithBold))
                      )),
                  Container(height: 25,width: 0.5,color: PdfColors.black),
                  Expanded(flex: 1,child: Padding(padding: const EdgeInsets.only(left: 5,right: 5),
                      child: Align(alignment: Alignment.centerRight,
                          child: Text('Pay Amount',style: fontSize9WithBold))
                  )),
                ])
            ),
            ///Dynamic Table
            for(int i=0;i<billList.length;i++)
            //Eight Dynamic Header.
              LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                      children: [
                        Container(height: 25,
                            decoration:  BoxDecoration(
                              border: Border(
                                //top:borderStyle,
                                bottom:borderStyle,
                                left:borderStyle,
                                right:borderStyle,
                              ),
                            ),
                            child: Row(children: [
                              Expanded(flex: 1,child: Padding(padding: const EdgeInsets.only(left: 5),
                                  child: Text('${billList[i]['InvoiceReference']??""}',style: fontSize9)
                              )),
                              Container(height: 25,width: 0.5,color: PdfColors.black),
                              Expanded(flex: 1,child: Padding(padding:const EdgeInsets.only(left: 5),
                                  child: Text(billList[i]['InvoiceDate'] != null ? formatDate(billList[i]['InvoiceDate']) : "",style: fontSize9)
                                //Text('NB26061-LEVER-1 NOS',style: fontSize8)
                              )),
                              Container(height: 25,width: 0.5,color: PdfColors.black),
                              Expanded(flex: 1,child: Padding(padding: const EdgeInsets.only(left: 5,right: 5),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text("${billList[i]['InvoiceAmount']??""}",style: fontSize9),)
                                //Text('90.24.1000',style: fontSize8)
                              )),
                              Container(height: 25,width: 0.5,color: PdfColors.black),
                              Expanded(flex: 1,child: Padding(padding:const EdgeInsets.only(left: 5,right: 5),
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('${billList[i]["TdsAmount"]??""}',style: fontSize9))
                                //Text('NOS',style: fontSize8)
                              )),
                              Container(height: 25,width: 0.5,color: PdfColors.black),
                              Expanded(flex: 1,child: Padding(padding:const EdgeInsets.only(left: 5,right: 5),
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('${billList[i]["PaidAmount"]??""}',style: fontSize9))
                                //Text('NOS',style: fontSize8)
                              )),

                            ])
                        ),
                      ]
                  );
                },),

            SizedBox(height: 20),
            //Amount In Words.
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(builder: (context) {
                    return
                      Text(
                          'In Words: $finalTotalAmount',
                          style: fontSize8WidthBold
                      );
                  },),
                  Text(
                      '',
                      // totalAmount,
                      style: fontSize8WidthBold
                  ),

                ]),
            SizedBox(height: 20),

            ///Prepared By.
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     Text('Prepared By',style: fontSize10),
            //     Text("",style: fontSize10),
            //     Text('',style: fontSize10),
            //     Text('',style: fontSize10),
            //   ],
            // ),

            SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('',style: fontSize9),
                  Text('Received the amount shown above',style: fontSize9),
                  Text('Signature',style: fontSize9),
                ]),
            SizedBox(height: 20),
            Text("This is a computer generated advice, does not need signature.",style: fontSize9WithBold),
          ],),
        )
      ],
    ),
  );

  // log('------pdf-------');
  // log(pdf.runtimeType.toString());

  // Return PDF as bytes.
  return pdf.save();
}
