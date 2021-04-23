import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnalysisResultPage extends StatefulWidget {
  final String _doi;
  _AnalysisResultPageState createState() => _AnalysisResultPageState();
  AnalysisResultPage(this._doi);
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  @override
  Widget build(BuildContext context) {
    String _doi = widget._doi;
    return Scaffold(
      appBar: AppBar(
        title: Text("Analyis Results"),
      ),
      body: Container(

      ),
    );
  }

}