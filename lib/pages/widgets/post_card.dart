import 'package:flutter/material.dart';
import 'package:flutter_gql/core/queries.dart';
import 'package:flutter_gql/models/post_model.dart';
import 'package:flutter_gql/pages/post_page.dart';
import 'package:flutter_gql/pages/widgets/add_post_dialog.dart';
import 'package:flutter_gql/pages/widgets/comments_bottomsheet.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
  });

  final PostModel post;

  void _updatePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddPostDialog(
          post: post,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        document: gql(Queries.deletePost),
        onCompleted: (data) {},
      ),
      builder: (runMutation, result) {
        return Stack(
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return PostPage(post: post);
                        },
                      ),
                    );
                  },
                  child: Padding(
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildUserInfo(context),
                                      _buildPopupMenu(runMutation),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPostTitle(context),
                                  const SizedBox(height: 4),
                                  _buildPostBody(context),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildCommentsBtn(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (result != null && result.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black12,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.user.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        Text(
          post.user.username,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPopupMenu(RunMutation<Object?> runMutation) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_horiz),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            child: const Text('Edit'),
            onTap: () => _updatePost(context),
          ),
          PopupMenuItem(
            child: const Text('Delete'),
            onTap: () {
              runMutation({
                'postId': post.id,
              });
            },
          ),
        ];
      },
    );
  }

  Widget _buildPostTitle(BuildContext context) {
    return Text(
      post.title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildPostBody(BuildContext context) {
    return Text(
      post.body,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
    );
  }

  Widget _buildCommentsBtn(BuildContext context) {
    return TextButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => CommentsBottomsheet(post: post),
        );
      },
      child: const Text('View Comments'),
    );
  }
}
