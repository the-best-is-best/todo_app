class TaskModel {
  int id;
  String title;
  DateTime dateTime;
  String status;

  TaskModel(this.id, this.title, this.dateTime, this.status);

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'title': title,
      'dateTime': dateTime.toString(),
      'status': status
    };

    return map;
  }
}
