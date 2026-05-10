import '../../domain/entities/tag.dart';

class TagModel extends Tag {
  const TagModel({required super.tagId, required super.tagName});

  factory TagModel.fromString(String tagName, {required int index}) =>
      TagModel(tagId: index, tagName: tagName);

  Map<String, dynamic> toJson() => {'tagName': tagName};
}
