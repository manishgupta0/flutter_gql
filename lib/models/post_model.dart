import 'package:flutter_gql/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PostModel {
  const PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.user,
  });

  final String id;
  final String title;
  final String body;
  final UserModel user;

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);
}
