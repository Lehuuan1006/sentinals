import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:sentinal/bloc/get_infor_profile/get_infor_profile_bloc.dart';
import 'package:sentinal/bloc/list_user/list_user_bloc.dart';
import 'package:sentinal/bloc/list_user_request_role/list_user_request_role_bloc.dart';
import 'package:sentinal/bloc/request_delete_user/request_delete_user_bloc.dart';
import 'package:sentinal/bloc/update_infor_profile/update_infor_profile_bloc.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/screens/load_users_profile.dart';
import 'package:sentinal/utils/stogares.dart';
import 'package:sentinal/widgets/custom_dialog.dart';
import 'package:sentinal/widgets/no_data_widget.dart';
import 'package:sentinal/widgets/text_app.dart';

class ListUserRequestRoleScreen extends StatefulWidget {
  const ListUserRequestRoleScreen({super.key});

  @override
  State<ListUserRequestRoleScreen> createState() =>
      _ListUserRequestRoleScreenState();
}

class _ListUserRequestRoleScreenState extends State<ListUserRequestRoleScreen>
    with SingleTickerProviderStateMixin {
  List<ExpansionTileController> expansionTileControllers = [];
  final scrollListBillController = ScrollController();
  final textSearchController = TextEditingController();

  String searchMethod = '...';
  String searchQuery = '';
  String requestID = '';
  File? selectedImage;
  bool hasMore = false;
  final ImagePicker picker = ImagePicker();
  String? selectedFile;
  void editUser({
    required String userId,
    required String requestId,
    required BuildContext context,
  }) {
    // Gửi sự kiện cập nhật role thành "Admin"
    context.read<UpdateProfileBloc>().add(
          UpdateProfileInfo(
            userId: userId,
            role: 'Admin', // Cập nhật role thành "Admin"
          ),
        );
    setState(() {
      requestID = requestId;
    });
    log("request ID: $requestID");
    log("User ID: $userId");
  }

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

  Future<void> handleDelete(String requestId, BuildContext context) async {
    try {
      // Xóa request từ Firestore
      await FirebaseFirestore.instance
          .collection('role_requests')
          .doc(requestId)
          .delete();

      // Kiểm tra nếu widget vẫn còn tồn tại
      if (mounted) {
        // Log và hiển thị thông báo thành công
        log('Request deleted successfully: $requestId');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa yêu cầu thành công!')),
        );
        init();
      }
    } catch (e) {
      // Kiểm tra nếu widget vẫn còn tồn tại
      if (mounted) {
        // Log và hiển thị thông báo lỗi
        log('DeleteRoleRequestFailure: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa yêu cầu: $e')),
        );
      }
    }
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
      final currentState = BlocProvider.of<ListRoleRequestBloc>(context).state;

      if (currentState is ListRoleRequestSuccess &&
          !currentState.hasReachedMax) {
        BlocProvider.of<ListRoleRequestBloc>(context).add(
          LoadMoreRoleRequests(
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
    BlocProvider.of<ListRoleRequestBloc>(context).add(FetchRoleRequests());
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
          text: "Request Role",
          fontsize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ListRoleRequestBloc, ListRoleRequestState>(
            listener: (context, state) {
              if (state is ListRoleRequestSuccess) {}
            },
          ),
          BlocListener<UpdateProfileBloc, UpdateProfileState>(
            listener: (context, state) {
              if (state is UpdateProfileSuccess) {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
                if (requestID != null && requestID!.isNotEmpty) {
                  handleDelete(requestID!, navigatorKey.currentContext!);
                } else {
                  log('RequestId is null or empty');
                }
              } else if (state is UpdateProfileFailure) {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: "Cập nhật thông tin thất bại",
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
                log('Lỗi: ${state.message}');
              }
            },
          ),
        ],
        child: BlocBuilder<ListRoleRequestBloc, ListRoleRequestState>(
          builder: (context, state) {
            if (state is ListRoleRequestLoading) {
              return Center(
                child: SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: Lottie.asset('assets/lotties/loading_sentinal.json'),
                ),
              );
            } else if (state is ListRoleRequestSuccess) {
              // Lọc danh sách người dùng dựa trên searchQuery
              final filteredUsers = state.data.where((user) {
                final name =
                    user['contactName']?.toString().toLowerCase() ?? '';

                return name.contains(searchQuery.toLowerCase());
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
                      BlocProvider.of<ListRoleRequestBloc>(context)
                          .add(FetchRoleRequests());
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
                                                        ListRoleRequestBloc>(
                                                    context)
                                                .add(SearchRoleRequests(query));
                                          } else {
                                            // Nếu trường nhập liệu trống, tải lại danh sách ban đầu
                                            BlocProvider.of<
                                                        ListRoleRequestBloc>(
                                                    context)
                                                .add(FetchRoleRequests());
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
                                      hintText: "Nhập tên user: $searchMethod",
                                      contentPadding: const EdgeInsets.all(15),
                                    ),
                                    onFieldSubmitted: (value) {
                                      // Gửi sự kiện tìm kiếm khi nhấn Enter
                                      if (value.isNotEmpty) {
                                        BlocProvider.of<ListRoleRequestBloc>(
                                                context)
                                            .add(SearchRoleRequests(value));
                                      } else {
                                        // Nếu trường nhập liệu trống, tải lại danh sách ban đầu
                                        BlocProvider.of<ListRoleRequestBloc>(
                                                context)
                                            .add(FetchRoleRequests());
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
                                                child: Slidable(
                                                  key: ValueKey(user),
                                                  endActionPane: role == 'Admin'
                                                      ? ActionPane(
                                                          extentRatio: 0.6,
                                                          dragDismissible:
                                                              false,
                                                          motion:
                                                              const ScrollMotion(),
                                                          dismissible:
                                                              DismissiblePane(
                                                            onDismissed: () {},
                                                          ),
                                                          children: [
                                                            SlidableAction(
                                                              onPressed:
                                                                  (context) async {
                                                                editUser(
                                                                  userId: user[
                                                                          'userId'] ??
                                                                      '',
                                                                  requestId:
                                                                      user['id'] ??
                                                                          '',
                                                                  context:
                                                                      context,
                                                                );
                                                              },
                                                              backgroundColor:
                                                                  Colors.green,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              icon: Icons.edit,
                                                              label: 'Approve',
                                                            ),
                                                            SlidableAction(
                                                              onPressed:
                                                                  (context) {
                                                                showCustomDialogModal(
                                                                  context:
                                                                      navigatorKey
                                                                          .currentContext!,
                                                                  textDesc:
                                                                      "Bạn có chắc muốn Reject request từ người dùng này?",
                                                                  title:
                                                                      "Thông báo",
                                                                  colorButtonOk:
                                                                      Colors
                                                                          .red,
                                                                  btnOKText:
                                                                      "Xác nhận",
                                                                  typeDialog:
                                                                      "question",
                                                                  eventButtonOKPress:
                                                                      () {
                                                                    handleDelete(
                                                                        user[
                                                                            'id'],
                                                                        navigatorKey
                                                                            .currentContext!);

                                                                    log('id request: ${user['id']}');
                                                                  },
                                                                  isTwoButton:
                                                                      true,
                                                                );
                                                              },
                                                              backgroundColor:
                                                                  Colors.red,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              icon:
                                                                  Icons.delete,
                                                              label: 'Reject',
                                                            ),
                                                          ],
                                                        )
                                                      : null,
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
                                                                isOverFlow:
                                                                    false,
                                                                text:
                                                                    "Tên liên lạc: ${user['contactName'] ?? ''}",
                                                                fontsize: 16.sp,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    59,
                                                                    58,
                                                                    58),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 280.w,
                                                              child: TextApp(
                                                                softWrap: true,
                                                                isOverFlow:
                                                                    false,
                                                                text:
                                                                    "Email: ${user['email'] ?? ''}",
                                                                fontsize: 16.sp,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    59,
                                                                    58,
                                                                    58),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 280.w,
                                                              child: TextApp(
                                                                softWrap: true,
                                                                isOverFlow:
                                                                    false,
                                                                text:
                                                                    "Request time: ${_formatTimestamp(user['timestamp'])}",
                                                                fontsize: 16.sp,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    59,
                                                                    58,
                                                                    58),
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
            } else if (state is ListRoleRequestFailure) {
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
