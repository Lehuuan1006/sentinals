part of 'list_user_bloc.dart';

abstract class ListUserEvent {}

class FetchListUser extends ListUserEvent {}

class LoadMoreListUser extends ListUserEvent {}
