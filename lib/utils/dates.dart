const List<String> months = ["Jan.", "Feb.", "March", "April", "May", "June", "July", "Aug.", "Sept.", "Oct.", "Nov.", "Dec."];

String parseDateWords(String date) {
  final month = months[int.parse(date.substring(5, 7)) - 1];
  return "${months[int.parse(date.substring(5, 7)) - 1]} ${int.parse(date.substring(8)).toString()}, ${date.substring(0, 4)}";
}