import 'package:flutter/material.dart';
import 'package:flutter_gql/core/queries.dart';
import 'package:flutter_gql/core/show_loading_overlay.dart';
import 'package:flutter_gql/models/post_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AddPostDialog extends StatefulWidget {
  const AddPostDialog({
    super.key,
    this.post,
  });

  final PostModel? post;

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  late final _titleController = TextEditingController(
    text: widget.post?.title ?? '',
  );

  late final _bodyController = TextEditingController(
    text: widget.post?.body ?? '',
  );

  @override
  void initState() {
    super.initState();

    _titleController.addListener(() => setState(() {}));
    _bodyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();

    super.dispose();
  }

  bool get _canPost =>
      _titleController.text.trim().isNotEmpty &&
      _bodyController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(8),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 24,
          bottom: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.post == null ? 'Add Post' : 'Update Post',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildPostTitleField(),
            const SizedBox(height: 12),
            Flexible(
              child: _buildPostBodyField(),
            ),
            const SizedBox(height: 24),
            Mutation(
              options: MutationOptions(
                document: widget.post == null
                    ? gql(Queries.createPost)
                    : gql(Queries.updatePost),
                onError: (error) {},
                onCompleted: (data) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              builder: (runMutation, result) {
                return widget.post == null
                    ? _buildCreatePostBtn(context, runMutation)
                    : _buildUpdatePostBtn(context, runMutation);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostTitleField() {
    return TextField(
      controller: _titleController,
      decoration: const InputDecoration(
        hintText: 'Title',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildPostBodyField() {
    return TextField(
      controller: _bodyController,
      keyboardType: TextInputType.multiline,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      maxLines: null,
      decoration: const InputDecoration(
        hintText: 'Body',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildCreatePostBtn(
    BuildContext context,
    RunMutation<Object?> runMutation,
  ) {
    return FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
        ),
        onPressed: _canPost
            ? () {
                showLoadingOverlay(context);
                runMutation({
                  'post': {
                    'title': _titleController.text.trim(),
                    'body': _bodyController.text.trim(),
                  }
                });
              }
            : null,
        child: const Text('Add Post'));
  }

  Widget _buildUpdatePostBtn(
    BuildContext context,
    RunMutation<Object?> runMutation,
  ) {
    return FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
        ),
        onPressed: _canPost
            ? () {
                showLoadingOverlay(context);
                runMutation({
                  'postId': widget.post!.id,
                  'post': {
                    'title': _titleController.text.trim(),
                    'body': _bodyController.text.trim(),
                  }
                });
              }
            : null,
        child: const Text('Update Post'));
  }
}
