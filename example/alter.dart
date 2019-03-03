import 'package:jaguar_query/jaguar_query.dart';
import 'package:jaguar_query_mysql1/composer.dart';
import 'package:jaguar_query_mysql1/jaguar_query_mysql1.dart';

main() {
  print(composeAlter(Alter('people').addInt('id').addString('name').modifyString('zipcode')));
}
