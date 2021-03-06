// Copyright (c) 2016, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:jaguar_query_mysql1/jaguar_query_mysql1.dart';
import 'package:mysql1/mysql1.dart';
import 'model.dart';

/// The adapter
MysqlAdapter adapter =
    MysqlAdapter('jaguar', username: 'root', password: '', port: 3306);

main() async {
  // Connect
  await adapter.connect();
  final bean = new PostBean(adapter);

  await bean.drop();
  await bean.createTable();

  // Insert some posts
  await bean.insert(new Post.make(id: 1, msg: 'Whatever 1', author: 'mark'));
  await bean.insert(new Post.make(id: 2, msg: 'Whatever 2', author: 'bob'));

  print('Post inserted');
  // Find one post
  Post post = await bean.findById(1);
  print(post);

  // Find all posts
  List<Post> posts = await bean.getAll();
  print(posts);

  // Update a post
  await bean.updateAuthor(1, 'rowling');

  // Check that the post is updated
  post = await bean.findById(1);
  print(post);

  // Delete some posts
  await bean.remove(1);
  await bean.remove(2);

  // Find a post when none exists
  post = await bean.findById(1);
  print(post);

  // Close connection
  await adapter.close();

  exit(0);
}
