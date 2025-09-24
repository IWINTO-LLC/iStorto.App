class SectionModel {
  String id;
  String name;
 

  SectionModel(
      {required this.id, required this.name});
  static SectionModel empty() => SectionModel(id: '', name: '');

  factory SectionModel.fromMap(Map<String, dynamic> data, String documentId) {
    return SectionModel(
      id: documentId,
      name: data['name'] ??data['arabicName']?? '',
    
    );
  }
}
