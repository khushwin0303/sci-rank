import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'analysisResultPage.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _myController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _myController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter DOI',
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  String doi = _myController.text;
                  if (doi != "") {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AnalysisResultPage(doi)));
                    });
                  }
                },
                child: Text("Get Analysis Results")
            ),
            Text("OR", style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),),
            ElevatedButton(
              onPressed: () {
              },
              child: Text("Select a PDF file from your device"),
            )

          ],
        ),
      ),
    );
  }
}
