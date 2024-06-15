class Queries {
  static const getAllPosts = r'''
  query{
    posts{
      data{
        id
        title
        body
        user {
          id
          name
          username
        }
      }
    }
  }
''';

  static const getPost = r'''
  query GetPostWithId($postId: ID!){
    post(id: $postId){
      id
      title
      body
      user {
        id
        name
        username
      }
    }
  }
''';

  static const createPost = r'''
  mutation CreatePost($post: CreatePostInput!){
    createPost(input: $post){
      id
      title
      body
    }
  }
''';

  static const deletePost = r'''
  mutation DeletePost($postId: ID!){
    deletePost(id: $postId)
  }
''';

  static const updatePost = r'''
  mutation UpdatePost($postId: ID!, $post: UpdatePostInput!){
    updatePost(id: $postId, input: $post){
      id
      title
      body
    }
  }
''';

  static const getComments = r'''
  query GetComments($postId: ID!){
    post(id: $postId) {
      comments{
        data{
          id
          name
          body
        }
      }
    }
  }
''';
}
