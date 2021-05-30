

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';

import 'package:sci_rank/PaperDetails.dart';
/// class where pdf generation, and opening occurs
class PdfFunctions {
  /// static Future<File> generatePdfContents(PaperDetails paperDetails, String fileName) async
  /// Takes a parameter of PaperDetails and the desired name of the file
  /// Generates a file with the details of the pdf file and with a suitable name
  static Future<File> generatePdfContents(PaperDetails paperDetails, String fileName) async {
    final pdf = pw.Document();
    final _abstract = paperDetails.abstract;
    final _sentiment = paperDetails.sentiment;
    final _date = paperDetails.date;
    var data = await rootBundle.load("assets/OpenSans-Regular.ttf");
    var myFont = pw.Font.ttf(data);
    pdf.addPage(pw.MultiPage(
      build: (context) => <pw.Widget> [
        pw.Header(child: pw.Text("Abstract Overview", style: pw.TextStyle(font: myFont, fontSize: 20.0))),
        pw.Text(_abstract, style: pw.TextStyle(font: myFont)),
        pw.Header(child: pw.Text("Sentimental analysis", style: pw.TextStyle(font: myFont, fontSize: 20.0))),
        pw.Text(_sentiment, style: pw.TextStyle(font: myFont)),
        pw.Header(child: pw.Text("Date", style: pw.TextStyle(font: myFont, fontSize: 20.0))),
        pw.Text(_date, style: pw.TextStyle(font: myFont)),
      ]
    ));

    if (fileName == "") fileName = "output.pdf";
    else fileName = fileName + ".pdf";
    return savePdf(fileName, pdf);
  }

  /// static Future<File> savePdf(String name, pw.Document pdf) async
  /// outputs the required pdf with the desired name.
  static Future<File> savePdf(String name, pw.Document pdf) async{
    final bytes = await pdf.save();

    final path = (await getApplicationDocumentsDirectory()).path;

    final file = File('$path/$name');
    
    await file.writeAsBytes(bytes);

    return file;
  }

  /// static Future openFile(File file) async
  /// function which opens the file
  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }


}