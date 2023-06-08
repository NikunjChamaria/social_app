import 'package:cloud_firestore/cloud_firestore.dart';

String formatdata(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  String year = dateTime.year.toString();

  String month = dateTime.month.toString();

  String day = dateTime.day.toString();

  String formatedData = '$day/$month/$year';
  return formatedData;
}
