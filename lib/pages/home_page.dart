import 'package:flutter/material.dart';
import 'package:flutter_gql/core/queries.dart';
import 'package:flutter_gql/models/post_model.dart';
import 'package:flutter_gql/pages/widgets/add_post_dialog.dart';
import 'package:flutter_gql/pages/widgets/post_card.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GraphQl Demo: Post App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return const AddPostDialog();
            },
          );
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Query(
      options: QueryOptions(
        document: gql(Queries.getAllPosts),
        parserFn: (data) {
          final posts = data['posts']['data'] as List;

          final models = posts.map((post) => PostModel.fromJson(post));

          return models;
        },
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (result.data == null) {
          return const Center(
            child: Text("No Post found"),
          );
        }
        final posts = result.parsedData!;

        return ListView.separated(
          itemCount: posts.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            return PostCard(
              post: posts.elementAt(index),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        );
      },
    );
  }
}
