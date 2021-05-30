import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'pdf_functions.dart';
import 'PaperDetails.dart';
String url = "https://danjoe4.pythonanywhere.com/doi";

Future<PaperDetails> _getPaperDetails(String doi) async {
  Map<String, String> body = <String, String> {
    'doi' : doi
  };
  final response = await https.post(url, body: jsonEncode(body), headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  },);

  if (response.statusCode == 200) {
    final responseJson = jsonDecode(response.body);
    return PaperDetails.fromJson(responseJson);
  }
  else {
    print(response.body);
    throw Exception("$response");
  }
}




class AnalysisResultPage extends StatefulWidget {
  final String _doi;
  _AnalysisResultPageState createState() => _AnalysisResultPageState();
  AnalysisResultPage(this._doi);
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  String _doi;
  PaperDetails _paperDetails;
  Future<PaperDetails> _futurePaperDetails;
  @override
  void initState() {
    _doi = widget._doi;
    _futurePaperDetails = _getPaperDetails(_doi);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analysis Results"),
      ),
      body: SingleChildScrollView(
        child: Container(
            height: MediaQuery.of(context).size.height,
            child: FutureBuilder<PaperDetails> (
                future: _futurePaperDetails,
                builder: buildPaperDetails
            )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()  {
          _returnGenPDFDialog(context);
        },
        child: Icon(Icons.picture_as_pdf),
      )
    );
  }

  Widget buildPaperDetails(BuildContext context, AsyncSnapshot<PaperDetails> snapshot) {
    if (snapshot.hasData) return returnPaperDetails(snapshot.data);
    else if (snapshot.hasError) return Center(child: Text("Error, DOI NOT FOUND"));
    else return Center(child: CircularProgressIndicator());
  }

  Widget returnPaperDetails(PaperDetails paperDetails) {
    _paperDetails = paperDetails;
    String _abstract = paperDetails.abstract;
    String _date = paperDetails.date;
    String _sentiment = paperDetails.sentiment;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        createCard(_abstract, "Abstract Overview"),
        createCard(_sentiment, "Sentimental Analysis"),
        createCard(_date, "Date of paper"),
      ],
    );
  }

  Widget createCard(String text, String title) {
    return Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),),
            Text("\n$text")
          ],
        )
    );
  }

  Future<void> _returnGenPDFDialog(BuildContext context) async{
    final myController = TextEditingController();
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Generate PDF"),
            content: Column(
              children: [
                Text("Please type the name you want the file to be generated with. If no input is given, the default name will be 'output'"),
                TextField(
                  controller: myController,
                  decoration: InputDecoration(
                      hintText: 'Enter file name'
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Okay"),
                onPressed: () async {
                  String fileName = myController.text;
                  final pdf = await PdfFunctions.generatePdfContents(_paperDetails, fileName);
                  PdfFunctions.openFile(pdf);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}





