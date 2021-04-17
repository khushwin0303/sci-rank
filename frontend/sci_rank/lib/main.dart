import 'package:flutter/material.dart';
import 'package:sci_rank/analysisResultPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCI-RANK',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'SCI-RANK'),
    );
  }
}

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
            )
          ],
        ),
     ),
   );
  }
}
