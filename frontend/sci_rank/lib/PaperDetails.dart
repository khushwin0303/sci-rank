class PaperDetails {
  String abstract;
  String date;
  String sentiment;

  /// Constructor for Paper Details
  PaperDetails({this.abstract, this.date, this.sentiment});


  /// Function that will return the details of the paper
  factory PaperDetails.fromJson(final json) {
    return PaperDetails(
      abstract: json['abstract'],
      date: json['date'],
      sentiment: json['sentiment'],
    );
  }
}