import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'analysisResultPage.dart';

/// This class define the layout of the home page
/// When it is a StatefulWidget, it means that the screen
/// will change appearance
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}


/// This class is of type State<MyHomePage >
/// It contains a TextField where the user can type or paste its doi8
/// It does not allow the user to redirect to the analysisResultsPage.dart
/// if the input is empty
class _MyHomePageState extends State<MyHomePage> {

  TextEditingController _myController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _myController,
                decoration: InputDecoration(
                  labelText: 'Paste or Type DOI',
                  border: OutlineInputBorder(
                  ),
                  hintText: 'DOI',
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
            ],
          ),
        )
      )
    );
  }
}
