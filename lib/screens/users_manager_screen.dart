import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:sentinal/bloc/get_infor_profile/get_infor_profile_bloc.dart';
import 'package:sentinal/bloc/list_user/list_user_bloc.dart';
import 'package:sentinal/bloc/request_delete_user/request_delete_user_bloc.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/screens/load_users_profile.dart';
import 'package:sentinal/utils/stogares.dart';
import 'package:sentinal/widgets/custom_dialog.dart';
import 'package:sentinal/widgets/no_data_widget.dart';
import 'package:sentinal/widgets/text_app.dart';

class ManageUser extends StatefulWidget {
  const ManageUser({super.key});

  @override
  State<ManageUser> createState() => _ManageUserState();
}

class _ManageUserState extends State<ManageUser>
    with SingleTickerProviderStateMixin {
  List<ExpansionTileController> expansionTileControllers = [];
  final scrollListBillController = ScrollController();
  final textSearchController = TextEditingController();
  final searchTypeTextController = TextEditingController();

  String searchMethod = '...';
  String searchQuery = '';
  String currentSearchMethod = "shipment_code";
  File? selectedImage;
  bool hasMore = false;
  final ImagePicker picker = ImagePicker();
  String? selectedFile;
  late TabController _tabController;
  // late SlidableController _slidableController;
  void editUser({
    required String userId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsersProfileScreen(userId: userId),
      ),
    );
    log("User ID: $userId");
  }

  Future<void> handleDeleteUser(
      {required String userId, required String email}) async {
    // Lấy context từ navigatorKey
    final context = navigatorKey.currentContext!;

    // Gửi event RequestDeleteUser đến bloc
    context.read<RequestDeleteUserBloc>().add(
          RequestDeleteUser(uid: userId, email: email),
        );
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _slidableController = SlidableController(vsync: this);
    init();
    for (int i = 0; i < 5; i++) {
      expansionTileControllers.add(ExpansionTileController());
    }
    scrollListBillController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollListBillController.position.maxScrollExtent ==
        scrollListBillController.offset) {
      // Lấy trạng thái hiện tại của ListUserBloc
      final currentState = BlocProvider.of<ListUserBloc>(context).state;

      // Kiểm tra xem trạng thái hiện tại có phải là ListUserStateSuccess không
      if (currentState is ListUserStateSuccess && !currentState.hasReachedMax) {
        // Gọi sự kiện LoadMoreListUser với page hiện tại + 1
        BlocProvider.of<ListUserBloc>(context).add(
          LoadMoreListUser(currentState.page + 1),
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
    // Gọi sự kiện FetchListUser để tải danh sách người dùng
    BlocProvider.of<ListUserBloc>(context).add(FetchListUser());
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
          text: "User Manager",
          fontsize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ListUserBloc, ListUserState>(
            listener: (context, state) {
              if (state is ListUserStateSuccess) {}
            },
          ),
          BlocListener<RequestDeleteUserBloc, RequestDeleteUserState>(
            listener: (context, state) {
              if (state is RequestDeleteUserSuccess) {
                showCustomDialogModal(
                  context: navigatorKey.currentContext!,
                  textDesc: "Request Xóa user thành công",
                  title: "Thông báo",
                  colorButtonOk: Colors.green,
                  btnOKText: "Xác nhận",
                  typeDialog: "success",
                  eventButtonOKPress: () {},
                  isTwoButton: false,
                );
                init();
              } else if (state is RequestDeleteUserFailure) {
                showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (BuildContext context) {
                    return ErrorDialog(
                      eventConfirm: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ListUserBloc, ListUserState>(
          builder: (context, state) {
            if (state is ListUserStateLoading) {
              return Center(
                child: SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: Lottie.asset('assets/lotties/loading_sentinal.json'),
                ),
              );
            } else if (state is ListUserStateSuccess) {
              // Lọc danh sách người dùng dựa trên searchQuery
              final filteredUsers = state.data.where((user) {
                final name =
                    user['contactName']?.toString().toLowerCase() ?? '';
                final phoneNumber =
                    user['phoneNumber']?.toString().toLowerCase() ?? '';
                final role = user['role']?.toString().toLowerCase() ?? '';

                return name.contains(searchQuery.toLowerCase()) ||
                    phoneNumber.contains(searchQuery.toLowerCase()) ||
                    role.contains(searchQuery.toLowerCase());
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
                      BlocProvider.of<ListUserBloc>(context)
                          .add(FetchListUser());
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
                                            BlocProvider.of<ListUserBloc>(
                                                    context)
                                                .add(SearchListUser(query));
                                          } else {
                                            // Nếu trường nhập liệu trống, tải lại danh sách ban đầu
                                            BlocProvider.of<ListUserBloc>(
                                                    context)
                                                .add(FetchListUser());
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
                                      hintText: "Tìm kiếm: $searchMethod",
                                      contentPadding: const EdgeInsets.all(15),
                                    ),
                                    onFieldSubmitted: (value) {
                                      // Gửi sự kiện tìm kiếm khi nhấn Enter
                                      if (value.isNotEmpty) {
                                        BlocProvider.of<ListUserBloc>(context)
                                            .add(SearchListUser(value));
                                      } else {
                                        // Nếu trường nhập liệu trống, tải lại danh sách ban đầu
                                        BlocProvider.of<ListUserBloc>(context)
                                            .add(FetchListUser());
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
                                                                    userId:
                                                                        user['id'] ??
                                                                            '');
                                                              },
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              icon: Icons.edit,
                                                              label: 'Sửa',
                                                            ),
                                                            SlidableAction(
                                                              onPressed:
                                                                  (context) {
                                                                showCustomDialogModal(
                                                                  context:
                                                                      navigatorKey
                                                                          .currentContext!,
                                                                  textDesc:
                                                                      "Bạn có chắc muốn xóa người dùng này?",
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
                                                                    handleDeleteUser(
                                                                      userId:
                                                                          user['id'] ??
                                                                              '',
                                                                      email:
                                                                          user['email'] ??
                                                                              '',
                                                                    );
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
                                                              label: 'Xoá',
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
                                                                    "Số điện thoại: ${user['phoneNumber'] ?? ''}",
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
                                                                    "Role: ${user['role'] ?? ''}",
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
            } else if (state is ListUserStateFailure) {
              log('Failed to fetch users: ${state.message}');
              return ErrorDialog(
                eventConfirm: () {
                  Navigator.pop(context);
                },
                errorText: 'Failed to fetch users: ${state.message}',
              );
            }
            return const Center(child: NoDataFoundWidget());
          },
        ),
      ),
    );
  }
}
