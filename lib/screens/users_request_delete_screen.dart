import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sentinal/bloc/list_request_delete_users/request_delete_users_list_bloc.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/utils/stogares.dart';
import 'package:sentinal/widgets/custom_dialog.dart';
import 'package:sentinal/widgets/no_data_widget.dart';
import 'package:sentinal/widgets/text_app.dart';

class ManageUserRequestDelete extends StatefulWidget {
  const ManageUserRequestDelete({super.key});

  @override
  State<ManageUserRequestDelete> createState() =>
      _ManageUserRequestDeleteState();
}

class _ManageUserRequestDeleteState extends State<ManageUserRequestDelete>
    with SingleTickerProviderStateMixin {
  List<ExpansionTileController> expansionTileControllers = [];
  final scrollListBillController = ScrollController();
  final textSearchController = TextEditingController();

  String searchMethod = '...';
  String searchQuery = '';
  File? selectedImage;
  bool hasMore = false;
  final ImagePicker picker = ImagePicker();
  String? selectedFile;

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Không có ngày';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return 'Định dạng ngày không hợp lệ';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    super.initState();
    init();
    for (int i = 0; i < 5; i++) {
      expansionTileControllers.add(ExpansionTileController());
    }
    scrollListBillController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollListBillController.position.maxScrollExtent ==
        scrollListBillController.offset) {
      final currentState =
          BlocProvider.of<RequestDeleteUsersListBloc>(context).state;

      if (currentState is RequestDeleteUserListStateSuccess &&
          !currentState.hasReachedMax) {
        BlocProvider.of<RequestDeleteUsersListBloc>(context).add(
          LoadMoreRequestDeleteUser(
            currentState.page + 1,
            currentState.searchQuery,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    textSearchController.clear();
  }

  void init() async {
    BlocProvider.of<RequestDeleteUsersListBloc>(context)
        .add(FetchRequestDeleteUser());
  }

  @override
  Widget build(BuildContext context) {
    final String? role = StorageUtils.instance.getString(key: 'user_role');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: TextApp(
          text: "Users Request Delete",
          fontsize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<RequestDeleteUsersListBloc, RequestDeleteUserListState>(
            listener: (context, state) {
              if (state is RequestDeleteUserListStateSuccess) {}
            },
          ),
        ],
        child:
            BlocBuilder<RequestDeleteUsersListBloc, RequestDeleteUserListState>(
          builder: (context, state) {
            if (state is RequestDeleteUserListStateLoading) {
              return Center(
                child: SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: Lottie.asset('assets/lotties/loading_sentinal.json'),
                ),
              );
            } else if (state is RequestDeleteUserListStateSuccess) {
              final filteredUsers = state.data.where((user) {
                final email = user['email']?.toString() ?? '';

                return email.contains(searchQuery);
              }).toList();
              return SlidableAutoCloseBehavior(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Slidable.of(context)?.close();
                  },
                  child: RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: () async {
                      BlocProvider.of<RequestDeleteUsersListBloc>(context)
                          .add(FetchRequestDeleteUser());
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: scrollListBillController,
                      child: Column(
                        children: [
                          Container(
                            width: 1.sw,
                            padding: EdgeInsets.all(10.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    controller:
                                        textSearchController, // Sử dụng controller để lấy giá trị
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          // Gửi sự kiện tìm kiếm khi nhấn nút tìm kiếm
                                          final query =
                                              textSearchController.text;
                                          if (query.isNotEmpty) {
                                            BlocProvider.of<
                                                        RequestDeleteUsersListBloc>(
                                                    context)
                                                .add(SearchRequestDeleteUser(
                                                    query));
                                          } else {
                                            // Nếu trường nhập liệu trống, tải lại danh sách ban đầu
                                            BlocProvider.of<
                                                        RequestDeleteUsersListBloc>(
                                                    context)
                                                .add(FetchRequestDeleteUser());
                                          }
                                        },
                                        child: const Icon(Icons.search),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      isDense: true,
                                      hintText:
                                          "Tìm kiếm theo Email: $searchMethod",
                                      contentPadding: const EdgeInsets.all(15),
                                    ),
                                    onFieldSubmitted: (value) {
                                      setState(() {
                                        searchQuery =
                                            value; // Cập nhật giá trị searchQuery
                                      });
                                      if (value.isNotEmpty) {
                                        BlocProvider.of<
                                                    RequestDeleteUsersListBloc>(
                                                context)
                                            .add(
                                                SearchRequestDeleteUser(value));
                                      } else {
                                        // Nếu trường nhập liệu trống, tải lại danh sách ban đầu
                                        BlocProvider.of<
                                                    RequestDeleteUsersListBloc>(
                                                context)
                                            .add(FetchRequestDeleteUser());
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 1.sw,
                                child: filteredUsers.isEmpty
                                    ? const NoDataFoundWidget()
                                    : ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: filteredUsers.length,
                                        itemBuilder: (context, index) {
                                          final user = filteredUsers[index];
                                          return Column(
                                            children: [
                                              const Divider(
                                                height: 1,
                                              ),
                                              Container(
                                                width: 1.sw,
                                                child: ListTile(
                                                  title: Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            width: 280.w,
                                                            child: TextApp(
                                                              softWrap: true,
                                                              isOverFlow: false,
                                                              text:
                                                                  "Email: ${user['email'] ?? ''}",
                                                              fontsize: 16.sp,
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  59, 58, 58),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 280.w,
                                                            child: TextApp(
                                                              softWrap: true,
                                                              isOverFlow: false,
                                                              text:
                                                                  "Ngày request: ${_formatTimestamp(user['timestamp'])}",
                                                              fontsize: 16.sp,
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  59, 58, 58),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (state is RequestDeleteUserListStateFailure) {
              log('Failed to fetch users: ${state.message}');
              return ErrorDialog(
                eventConfirm: () {
                  Navigator.pop(context);
                },
                errorText: 'Failed to fetch users',
              );
            }
            return const Center(child: NoDataFoundWidget());
          },
        ),
      ),
    );
  }
}
