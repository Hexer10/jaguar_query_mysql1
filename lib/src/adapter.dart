// Copyright (c) 2016, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library jaguar_query_mysql1.src;

import 'dart:async';

import 'package:jaguar_query/jaguar_query.dart';
import 'package:jaguar_query_mysql1/composer.dart';
import 'package:mysql1/mysql1.dart' as mysql;

class MysqlAdapter implements Adapter<mysql.MySqlConnection> {
  mysql.MySqlConnection _connection;
  mysql.ConnectionSettings _connectionSettings;

  final String host;

  final int port;

  final String databaseName;
  final String username;
  final String password;

  mysql.MySqlConnection get connection => _connection;

  MysqlAdapter(this.databaseName,
      {this.username, this.password, this.host: 'localhost', this.port: 5432});

  MysqlAdapter.FromConnection(mysql.MySqlConnection connection)
      : _connection = connection,
        host = connection.connectionSettings.host,
        port = connection.connectionSettings.port,
        databaseName = connection.connectionSettings.db,
        username = connection.connectionSettings.user,
        password = connection.connectionSettings.password;

  /// Connects to the database
  Future<void> connect() async {
    if (_connection == null) {
      _connection = mysql.MySqlConnection(mysql.ConnectionSettings(
          host: host,
          port: port,
          db: databaseName,
          user: username,
          password: password));
      await _connection.connect();
    }
  }

  List<Map<dynamic, dynamic>> _mapResult(mysql.Results result) {
    List results = <Map>[];
    List keys = <String>[];

    for (var field in result.fields) {
      keys.add(field.name);
    }

    for (var value in result) {
      List values = [];
      for (var value1 in value) {
        values.add(value1);
      }
      results.add(Map.fromIterables(keys, values));
    }
    return results;
  }

  /// Closes all connections to the database.
  Future<void> close() => _connection.close();

  /// Finds one record in the table
  Future<Map> findOne(Find st) async {
    String stStr = composeFind(st);
    List<Map<dynamic, dynamic>> rows =
        _mapResult(await _connection.query(stStr));

    if (rows.isEmpty) return null;

    Map<dynamic, dynamic> row = rows.first;

    if (row.length == 0) return {};

    return rows.first;
  }

  /// Finds many records in the table
  Future<List<Map>> find(Find st) async {
    String stStr = composeFind(st);

    return _mapResult(await _connection.query(stStr));
  }

  /// Inserts a record into the table
  Future<T> insert<T>(Insert st) async {
    String strSt = composeInsert(st);
    var ret = await _connection.query(strSt);
    if (ret.isEmpty || ret.first.isEmpty) return null;
    return ret.first.first;
  }

  @override
  Future<void> insertMany<T>(InsertMany statement) {
    throw UnimplementedError('InsertMany is not implemented yet!');
  }

  /// Executes the insert or update statement and returns the primary key of
  /// inserted row
  Future<T> upsert<T>(Upsert statement) {
    throw UnimplementedError();
  }

  /// Executes bulk insert or update statement
  Future<void> upsertMany<T>(UpsertMany statement) {
    throw UnimplementedError();
  }

  /// Updates a record in the table
  Future<int> update(Update st) async =>
      (await _connection.query(composeUpdate(st))).affectedRows;

  /// Deletes a record from the table
  Future<int> remove(Remove st) async =>
      (await _connection.query(composeRemove(st))).affectedRows;

  @override
  Future<void> alter(Alter statement) async =>
      await _connection.query(composeAlter(statement));

  /// Creates the table
  Future<void> createTable(Create statement) =>
      _connection.query(composeCreate(statement));

  /// Create the database
  Future<void> createDatabase(CreateDb st) =>
      _connection.query(composeCreateDb(st));

  /// Drops tables from database
  Future<void> dropTable(Drop st) => _connection.query(composeDrop(st));

  Future<void> dropDb(DropDb st) => _connection.query(composeDropDb(st));

  @override
  T parseValue<T>(dynamic v) {
    return v as T;
  }

  @override
  Future<void> updateMany(UpdateMany statement) {
    throw UnimplementedError('TODO need to be implemented');
  }
}
