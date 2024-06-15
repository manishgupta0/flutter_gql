import 'package:flutter/material.dart';
import 'package:flutter_gql/core/queries.dart';
import 'package:flutter_gql/models/comment_model.dart';
import 'package:flutter_gql/models/post_model.dart';
import 'package:flutter_gql/pages/widgets/comment_tile.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CommentsBottomsheet extends StatelessWidget {
  const CommentsBottomsheet({
    super.key,
    required this.post,
  });

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 24),
            Text(
              'Comments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            const Divider(height: 0),
            Query(
              options: QueryOptions(
                document: gql(Queries.getComments),
                variables: {
                  'postId': post.id,
                },
                parserFn: (data) {
                  final comments = data['post']['comments']['data'] as List;

                  final models = comments.map(
                    (comment) => CommentModel.fromJson(comment),
                  );
                  return models;
                },
                onError: (error) {},
              ),
              builder: (result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (result.data == null) {
                  return const Center(
                    child: Text("No Comments"),
                  );
                }

                final comments = result.parsedData!;

                return Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments.elementAt(index);

                      return CommentTile(comment: comment);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
