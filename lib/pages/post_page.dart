import 'package:flutter/material.dart';
import 'package:flutter_gql/core/queries.dart';
import 'package:flutter_gql/core/show_loading_overlay.dart';
import 'package:flutter_gql/models/comment_model.dart';
import 'package:flutter_gql/models/post_model.dart';
import 'package:flutter_gql/pages/widgets/add_post_dialog.dart';
import 'package:flutter_gql/pages/widgets/comment_tile.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class PostPage extends StatefulWidget {
  const PostPage({
    super.key,
    required this.post,
  });

  final PostModel post;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late PostModel _post = widget.post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 24,
                    ),
                    const SizedBox(width: 8),
                    Query(
                      options: QueryOptions(
                        document: gql(Queries.getPost),
                        variables: {
                          'postId': _post.id,
                        },
                        parserFn: (data) {
                          return PostModel.fromJson(data['post']);
                        },
                        onComplete: (data) {
                          final post = PostModel.fromJson(data['post']);

                          _post = post;
                        },
                      ),
                      builder: (result, {fetchMore, refetch}) {
                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildUserInfo(),
                                  _buildPopupMenu(),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildPostTitle(),
                              const SizedBox(height: 8),
                              _buildPostBody(),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Text(
            'Comments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          _buildComments()
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _post.user.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        Text(
          _post.user.username,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  void _updatePost() {
    showDialog(
      context: context,
      builder: (context) {
        return AddPostDialog(
          post: _post,
        );
      },
    );
  }

  Widget _buildPopupMenu() {
    return Mutation(
      options: MutationOptions(
        document: gql(Queries.deletePost),
        onCompleted: (data) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
      builder: (runMutation, result) => PopupMenuButton(
        icon: const Icon(Icons.more_horiz),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () => _updatePost(),
            ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: () {
                showLoadingOverlay(context);
                runMutation({
                  'postId': _post.id,
                });
              },
            ),
          ];
        },
      ),
    );
  }

  Widget _buildPostTitle() {
    return Text(
      _post.title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildPostBody() {
    return Text(
      _post.body,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
    );
  }

  Widget _buildComments() {
    return Query(
      options: QueryOptions(
        document: gql(Queries.getComments),
        variables: {
          'postId': _post.id,
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

        final comments = result.parserFn(result.data!);

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
    );
  }
}
