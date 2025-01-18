// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// // import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:lottie/lottie.dart';
// import 'package:http/http.dart' as http;
// import 'package:sentinal/bloc/list_user/list_user_bloc.dart';
// import 'package:sentinal/router/index.dart';
// import 'package:sentinal/utils/stogares.dart';
// import 'package:sentinal/widgets/custom_dialog.dart';
// import 'package:sentinal/widgets/text_app.dart';

// enum MethodPayCharater { bank, cash }

// class PackageManagerScreen extends StatefulWidget {
//   const PackageManagerScreen({super.key});

//   @override
//   State<PackageManagerScreen> createState() => _PackageManagerScreenState();
// }

// class _PackageManagerScreenState extends State<PackageManagerScreen>
//     with SingleTickerProviderStateMixin {
//   List<ExpansionTileController> expansionTileControllers = [];
//   final scrollListBillController = ScrollController();
//   final textSearchController = TextEditingController();
//   final statusTextController = TextEditingController();
//   final branchTextController = TextEditingController();
//   final searchTypeTextController = TextEditingController();

//   final TextEditingController _dateStartController = TextEditingController();
//   final TextEditingController _dateEndController = TextEditingController();
//   String query = '';
//   List<IconData> iconStatus = [
//     Icons.all_inbox,
//     Icons.add,
//     Icons.create,
//     Icons.outbond,
//     Icons.refresh
//   ];
//   List<String> listStatus = [
//     "Created Bill",
//     "Imported",
//     "Exported",
//     "Returned"
//   ];
//   List<String> listSearchMethod = [
//     "Mã shipment",
//     "Mã giới thiệu",
//     "Tên người nhận",
//     "Mã kiện hàng",
//     "Mã vận đơn"
//   ];
//   List<String> listKeyType = [
//     "shipment_code",
//     "shipment_reference_code",
//     "receiver_contact_name",
//     "package_code",
//     "tracking_code"
//   ];
//   String searchMethod = 'Mã shipment';
//   String currentSearchMethod = "shipment_code";
//   DateTime? _startDate; //type ngày bắt đầu
//   DateTime? _endDate; //type ngày kết thúc
//   String? _endDateError; //text lỗi khi ngày kết thúc nhỏ hơn ngày bắt đầu
//   int? branchID;
//   File? selectedImage;
//   bool hasMore = false;
//   final ImagePicker picker = ImagePicker();
//   MethodPayCharater? _methodPay = MethodPayCharater.bank;
//   String? selectedFile;
//   late TabController _tabController;
//   // late SlidableController _slidableController;
//   void editShipment({
//     required String shipmentCode,
//   }) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => CreateShipmentScreen(
//                 shipmentCode: shipmentCode,
//                 isEditMode: true,
//               )),
//     );
//     log("mã shipment: $shipmentCode");
//   }

//   void handleDeleteShipment({required String? shipmentCode}) {
//     context
//         .read<DeleteShipmentBloc>()
//         .add(HanldeDeleteShipment(shipmentCode: shipmentCode));
//   }

//   void getDetailsShipment({required String? shipmentCode}) {
//     context
//         .read<DetailsShipmentBloc>()
//         .add(HanldeDetailsShipment(shipmentCode: shipmentCode));
//   }

//   void showDialogDetailsShipment({required String shipmentCode}) {
//     showModalBottomSheet(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             topRight: Radius.circular(15.r),
//             topLeft: Radius.circular(15.r),
//           ),
//         ),
//         clipBehavior: Clip.antiAliasWithSaveLayer,
//         context: context,
//         isScrollControlled: true,
//         builder: (context) {
//           return DraggableScrollableSheet(
//             maxChildSize: 0.8,
//             initialChildSize: 0.8,
//             expand: false,
//             builder: (BuildContext context,
//                 ScrollController scrollControllerMoreInfor) {
//               return StatefulBuilder(
//                   builder: (BuildContext context, StateSetter setState) {
//                 return Container(
//                     color: Colors.white,
//                     child: Column(
//                       children: [
//                         TabBar(
//                           controller: _tabController,
//                           tabs: [
//                             Tab(
//                               child: TextApp(
//                                 text: 'Thông tin lô hàng',
//                                 fontsize: 16.sp,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             Tab(
//                               child: TextApp(
//                                 text: 'Thông tin kiện hàng',
//                                 fontsize: 16.sp,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Expanded(
//                           child: TabBarView(
//                             controller: _tabController,
//                             children: [
//                               PackageInfoWidgetTab1(
//                                 shipmentCode: shipmentCode,
//                                 scrollController: scrollControllerMoreInfor,
//                                 detailsShipment: detailsShipment,
//                                 selectedPDFLabelString: selectedFile,
//                                 selectedImage: selectedImage,
//                                 methodPay: _methodPay,
//                               ),
//                               PackageInfoWidgetTab2(
//                                 scrollController: scrollControllerMoreInfor,
//                                 detailsShipment: detailsShipment,
//                                 allUnitShipmentModel: allUnitShipmentModel,
//                               )
//                             ],
//                           ),
//                         ),
//                       ],
//                     ));
//               });
//             },
//           );
//         });
//   }

  

//   @override
//   void initState() {
//     WidgetsFlutterBinding.ensureInitialized();

//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     // _slidableController = SlidableController(vsync: this);
//     init();
//     for (int i = 0; i < 5; i++) {
//       expansionTileControllers.add(ExpansionTileController());
//     }
//     scrollListBillController.addListener(_onScroll);
//   }

//   void _onScroll() {
//     if (scrollListBillController.position.maxScrollExtent ==
//         scrollListBillController.offset) {
//       BlocProvider.of<ListUserBloc>(context).add(LoadMoreListUser(
//           status: listStatus.indexOf(statusTextController.text) == -1
//               ? null
//               : listStatus.indexOf(statusTextController.text),
//           startDate: _startDate?.toString(),
//           endDate: _endDate?.toString(),
//           branchId: branchID,
//           keywords: query,
//           searchMethod: currentSearchMethod));
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     textSearchController.clear();
//     _dateStartController.clear();
//     _dateEndController.clear();
//     statusTextController.clear();
//   }

//   void searchProduct(String query) {
//     mounted
//         ? setState(() {
//             this.query = query;

//             BlocProvider.of<ListUserBloc>(context).add(FetchListUser(
//                 status: listStatus.indexOf(statusTextController.text) == -1
//                     ? null
//                     : listStatus.indexOf(statusTextController.text),
//                 startDate: _startDate?.toString(),
//                 endDate: _endDate?.toString(),
//                 branchId: branchID,
//                 keywords: query,
//                 searchMethod: currentSearchMethod));
//           })
//         : null;
//   }

 

//   /// This builds cupertion date picker in iOS
//   void buildCupertinoDateStartPicker(BuildContext context) {
//     showCupertinoDatePicker(
//       context,
//       initialDate: _startDate,
//       onDateChanged: (picked) {
//         setState(() {
//           _startDate = picked;
//         });
//       },
//       onCancel: () {
//         Navigator.of(context).pop();
//       },
//       onConfirm: () {
//         setState(() {
//           _dateStartController.text = formatDateMonthYear(
//               (_startDate ?? DateTime.now()).toString().split(" ")[0]);
//           _endDateError = null;
//           Navigator.of(context).pop();
//         });
//       },
//     );
//   }

//   void buildCupertinoDateEndPicker(BuildContext context) {
//     showCupertinoDatePicker(
//       context,
//       initialDate: _endDate,
//       onDateChanged: (picked) {
//         setState(() {
//           _endDate = picked;
//         });
//       },
//       onCancel: () {
//         Navigator.of(context).pop();
//       },
//       onConfirm: () {
//         if ((_endDate ?? DateTime.now())
//             .isBefore(_startDate ?? DateTime.now())) {
//           showCustomDialogModal(
//               context: navigatorKey.currentContext!,
//               textDesc: "Nhỏ hơn ngày bắt đầu",
//               title: "Thông báo",
//               colorButtonOk: Colors.red,
//               btnOKText: "Xác nhận",
//               typeDialog: "error",
//               eventButtonOKPress: () {},
//               isTwoButton: false);
//         } else {
//           setState(() {
//             _dateEndController.text = formatDateMonthYear(
//                 (_endDate ?? DateTime.now()).toString().split(" ")[0]);
//             _endDateError = null;
//             Navigator.of(context).pop();
//           });
//         }
//       },
//     );
//   }

//   /// This builds material date picker in Android
//   Future<void> buildMaterialDateStartPicker(BuildContext context) async {
//     showMaterialDatePicker(
//       context,
//       initialDate: _startDate ?? DateTime.now(),
//       firstDate: DateTime(DateTime.now().year - 2),
//       lastDate: DateTime(DateTime.now().year + 2),
//       onDatePicked: (picked) {
//         setState(() {
//           _startDate = picked;
//           _dateStartController.text = formatDateMonthYear(
//               (_startDate ?? DateTime.now()).toString().split(" ")[0]);
//           _endDateError = null;
//         });
//       },
//     );
//   }

//   Future<void> buildMaterialDateEndPicker(BuildContext context) async {
//     showMaterialDatePicker(
//       context,
//       initialDate: _endDate ?? DateTime.now(),
//       firstDate: DateTime(DateTime.now().year - 2),
//       lastDate: DateTime(DateTime.now().year + 2),
//       onDatePicked: (picked) {
//         setState(() {
//           _endDate = picked;
//           _dateEndController.text = formatDateMonthYear(
//               (_endDate ?? DateTime.now()).toString().split(" ")[0]);
//           _endDateError = null;
//         });
//       },
//     );
//   }

//   Future<void> selectDayStart() async {
//     final ThemeData theme = Theme.of(context);
//     switch (theme.platform) {
//       case TargetPlatform.android:
//       case TargetPlatform.fuchsia:
//       case TargetPlatform.linux:
//       case TargetPlatform.windows:
//         return buildMaterialDateStartPicker(context);
//       case TargetPlatform.iOS:
//       case TargetPlatform.macOS:
//         return buildCupertinoDateStartPicker(context);
//       // return buildMaterialDateStartPicker(context);
//     }
//   }

//   Future<void> selectDayEnd() async {
//     final ThemeData theme = Theme.of(context);
//     switch (theme.platform) {
//       case TargetPlatform.android:
//       case TargetPlatform.fuchsia:
//       case TargetPlatform.linux:
//       case TargetPlatform.windows:
//         return buildMaterialDateEndPicker(context);
//       case TargetPlatform.iOS:
//       case TargetPlatform.macOS:
//         return buildCupertinoDateEndPicker(context);
//       // return buildMaterialDateEndPicker(context);
//     }
//   }

//   void _updateBrandID(int newBrandID) {
//     setState(() {
//       branchID = newBrandID;
//     });
//   }

//   void _updateSearchTypeChanged(String newTypeSearch) {
//     setState(() {
//       currentSearchMethod = newTypeSearch;
//     });
//   }

//   void _updateSearchStringChanged(String newStringSearch) {
//     setState(() {
//       searchMethod = newStringSearch;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String? position =
//         StorageUtils.instance.getString(key: 'user_position');
//     final bool? isShipper = StorageUtils.instance.getBool(key: 'is_shipper');
//     return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           iconTheme: const IconThemeData(
//             color: Colors.black, //change your color here
//           ),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.white,
//           shadowColor: Colors.white,
//           surfaceTintColor: Colors.white,
//           title: TextApp(
//             text: "Package Manager",
//             fontsize: 20.sp,
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         body: MultiBlocListener(
//             listeners: [
//               BlocListener<ListUserBloc, ListUserState>(
//                 listener: (context, state) {
//                   if (state is ListUserStateSuccess) {}
//                 },
//               ),
//               BlocListener<DeleteShipmentBloc, DeleteShipmentState>(
//                 listener: (context, state) {
//                   if (state is DeleteShipmentStateSuccess) {
//                     showCustomDialogModal(
//                         context: navigatorKey.currentContext!,
//                         textDesc: "Xóa shipment thành công",
//                         title: "Thông báo",
//                         colorButtonOk: Colors.green,
//                         btnOKText: "Xác nhận",
//                         typeDialog: "success",
//                         eventButtonOKPress: () {},
//                         isTwoButton: false);
//                     init();
//                   } else if (state is DeleteShipmentStateFailure) {
//                     showDialog(
//                         context: navigatorKey.currentContext!,
//                         builder: (BuildContext context) {
//                           return ErrorDialog(
//                             eventConfirm: () {
//                               Navigator.pop(context);
//                             },
//                           );
//                         });
//                   }
//                 },
//               ),
//             ],
//             child: BlocBuilder<ListUserBloc, ListUserState>(
//               builder: (context, state) {
//                 if (state is ListUserStateLoading) {
//                   return Center(
//                     child: SizedBox(
//                       width: 100.w,
//                       height: 100.w,
//                       child: Lottie.asset('assets/lotties/loading_sentinal.json'),
//                     ),
//                   );
//                 } else if (state is ListUserStateSuccess) {
//                   return SlidableAutoCloseBehavior(
//                     child: GestureDetector(
//                       behavior: HitTestBehavior.opaque,
//                       onTap: () {
//                         // Close any open slidable when tapping outside
//                         Slidable.of(context)?.close();
//                       },
//                       child: RefreshIndicator(
//                         color: Theme.of(context).colorScheme.primary,
//                         onRefresh: () async {
//                           // shipmentItemData.clear();
//                           _endDateError = null;
//                           statusTextController.clear();
//                           _dateStartController.clear();
//                           _dateEndController.clear();
//                           listStatus.clear();
//                           _startDate = null;
//                           _endDate = null;
//                           branchID = null;
//                           BlocProvider.of<ListUserBloc>(context).add(
//                               FetchListUser(
//                                   status: null,
//                                   startDate: null,
//                                   endDate: null,
//                                   branchId: null,
//                                   keywords: query,
//                                   searchMethod: currentSearchMethod));
//                         },
//                         child: SingleChildScrollView(
//                           physics: const AlwaysScrollableScrollPhysics(),
//                           controller: scrollListBillController,
//                           child: Column(
//                             children: [
//                               Container(
//                                   width: 1.sw,
//                                   padding: EdgeInsets.all(10.w),
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: TextFormField(
//                                           onTapOutside: (event) {
//                                             FocusManager.instance.primaryFocus
//                                                 ?.unfocus();
//                                           },
//                                           // onChanged: searchProduct,
//                                           controller: textSearchController,
//                                           style: const TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.black),
//                                           cursorColor: Colors.black,
//                                           decoration: InputDecoration(
//                                               suffixIcon: InkWell(
//                                                 onTap: () {
//                                                   searchProduct(
//                                                       textSearchController
//                                                           .text);
//                                                 },
//                                                 child: const Icon(Icons.search),
//                                               ),
//                                               filled: true,
//                                               fillColor: Colors.white,
//                                               focusedBorder: OutlineInputBorder(
//                                                 borderSide: BorderSide(
//                                                     color: Theme.of(context)
//                                                         .colorScheme
//                                                         .primary,
//                                                     width: 2.0),
//                                                 borderRadius:
//                                                     BorderRadius.circular(8.r),
//                                               ),
//                                               border: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(8.r),
//                                               ),
//                                               isDense: true,
//                                               hintText:
//                                                   "Tìm kiếm theo: $searchMethod",
//                                               contentPadding:
//                                                   const EdgeInsets.all(15)),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: 15.w,
//                                       ),
                                      
//                                     ],
//                                   )),
//                               SizedBox(
//                                 height: 15.h,
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   SizedBox(
//                                     width: 1.sw,
//                                     child: state.data.isEmpty
//                                         ? const NoDataFoundWidget()
//                                         : ListView.builder(
//                                             physics:
//                                                 const NeverScrollableScrollPhysics(),
//                                             shrinkWrap: true,
//                                             itemCount: state.hasReachedMax
//                                                 ? state.data.length
//                                                 : state.data.length + 1,
//                                             itemBuilder: (context, index) {
//                                               if (index >= state.data.length) {
//                                                 return Center(
//                                                   child: SizedBox(
//                                                     width: 100.w,
//                                                     height: 100.w,
//                                                     child: Lottie.asset(
//                                                         'assets/lotties/loading_sentinal.json'),
//                                                   ),
//                                                 );
//                                               } else {
//                                                 final dataShipment =
//                                                     state.data[index];
//                                                 return Column(
//                                                   children: [
//                                                     const Divider(
//                                                       height: 1,
//                                                     ),
//                                                     Container(
//                                                       width: 1.sw,
//                                                       child: Slidable(
//                                                         // controller:
//                                                         //     _slidableController,
//                                                         key: ValueKey(
//                                                             dataShipment),
//                                                         endActionPane:
//                                                             ActionPane(
//                                                           extentRatio:
//                                                               isShipper!
//                                                                   ? 0.6
//                                                                   : 0.8,
//                                                           dragDismissible:
//                                                               false,
//                                                           motion:
//                                                               const ScrollMotion(),
//                                                           dismissible:
//                                                               DismissiblePane(
//                                                                   onDismissed:
//                                                                       () {}),
//                                                           children: [
//                                                             ((position !=
//                                                                     'fwd'))
//                                                                 ? SlidableAction(
//                                                                     onPressed:
//                                                                         (context) async {
//                                                                       getDetailsShipment(
//                                                                           shipmentCode:
//                                                                               dataShipment.shipmentCode);
//                                                                     },
//                                                                     backgroundColor: Theme.of(
//                                                                             context)
//                                                                         .colorScheme
//                                                                         .primary,
//                                                                     foregroundColor:
//                                                                         Colors
//                                                                             .white,
//                                                                     icon: Icons
//                                                                         .info,
//                                                                     label:
//                                                                         'Thêm',
//                                                                   )
//                                                                 : Container(),
//                                                             ((position == 'ops_pickup' &&
//                                                                         (dataShipment.shipmentStatus ==
//                                                                                 0 ||
//                                                                             dataShipment.shipmentStatus ==
//                                                                                 1)) ||
//                                                                     position ==
//                                                                         'ops_leader' ||
//                                                                     position ==
//                                                                         'admin' ||
//                                                                     (position ==
//                                                                             'sale' &&
//                                                                         dataShipment.shipmentStatus ==
//                                                                             0) ||
//                                                                     (position ==
//                                                                             'fwd' &&
//                                                                         dataShipment.shipmentStatus ==
//                                                                             0))
//                                                                 ? SlidableAction(
//                                                                     onPressed:
//                                                                         (context) async {
//                                                                       editShipment(
//                                                                         shipmentCode: dataShipment
//                                                                             .shipmentCode
//                                                                             .toString(),
//                                                                       );
//                                                                     },
//                                                                     backgroundColor:
//                                                                         Colors
//                                                                             .blue,
//                                                                     foregroundColor:
//                                                                         Colors
//                                                                             .white,
//                                                                     icon: Icons
//                                                                         .edit,
//                                                                     label:
//                                                                         'Sửa',
//                                                                   )
//                                                                 : Container(),
//                                                             !(isShipper ||
//                                                                     position ==
//                                                                         'sale' ||
//                                                                     position ==
//                                                                         'fwd') // Disable for sale and fwd
//                                                                 ? SlidableAction(
//                                                                     onPressed:
//                                                                         (context) {
//                                                                       showCustomDialogModal(
//                                                                         context:
//                                                                             navigatorKey.currentContext!,
//                                                                         textDesc:
//                                                                             "Bạn có chắc muốn thực hiện tác vụ này ?",
//                                                                         title:
//                                                                             "Thông báo",
//                                                                         colorButtonOk:
//                                                                             Colors.blue,
//                                                                         btnOKText:
//                                                                             "Xác nhận",
//                                                                         typeDialog:
//                                                                             "question",
//                                                                         eventButtonOKPress:
//                                                                             () {
//                                                                           handleDeleteShipment(
//                                                                               shipmentCode: dataShipment.shipmentCode);
//                                                                         },
//                                                                         isTwoButton:
//                                                                             true,
//                                                                       );
//                                                                     },
//                                                                     backgroundColor:
//                                                                         Colors
//                                                                             .red,
//                                                                     foregroundColor:
//                                                                         Colors
//                                                                             .white,
//                                                                     icon: Icons
//                                                                         .delete,
//                                                                     label:
//                                                                         'Xoá',
//                                                                   )
//                                                                 : Container(),
//                                                           ],
//                                                         ),
//                                                         child: ListTile(
//                                                             onTap: () {
//                                                               // _slidableController
//                                                               //     .openCurrentActionPane();
//                                                             },
//                                                             title: Row(
//                                                               children: [
//                                                                 dataShipment.shipmentStatus ==
//                                                                         0
//                                                                     ? SizedBox(
//                                                                         width:
//                                                                             80.w,
//                                                                         child:
//                                                                             Column(
//                                                                           children: [
//                                                                             Icon(
//                                                                               Icons.circle_notifications,
//                                                                               color: Theme.of(context).colorScheme.secondary,
//                                                                               size: 48.sp,
//                                                                             ),
//                                                                             TextApp(
//                                                                               isOverFlow: false,
//                                                                               softWrap: true,
//                                                                               text: "Create Bill",
//                                                                               fontsize: 14.sp,
//                                                                               color: Colors.black,
//                                                                               textAlign: TextAlign.center,
//                                                                               fontWeight: FontWeight.normal,
//                                                                             ),
//                                                                           ],
//                                                                         ),
//                                                                       )
//                                                                     : dataShipment.shipmentStatus ==
//                                                                             1
//                                                                         ? SizedBox(
//                                                                             width:
//                                                                                 80.w,
//                                                                             child:
//                                                                                 Column(
//                                                                               children: [
//                                                                                 Icon(
//                                                                                   Icons.check_circle_rounded,
//                                                                                   color: Theme.of(context).colorScheme.primary,
//                                                                                   size: 48.sp,
//                                                                                 ),
//                                                                                 TextApp(
//                                                                                   isOverFlow: false,
//                                                                                   softWrap: true,
//                                                                                   text: "Imported",
//                                                                                   fontsize: 14.sp,
//                                                                                   color: Colors.black,
//                                                                                   textAlign: TextAlign.center,
//                                                                                   fontWeight: FontWeight.normal,
//                                                                                 ),
//                                                                               ],
//                                                                             ),
//                                                                           )
//                                                                         : dataShipment.shipmentStatus ==
//                                                                                 2
//                                                                             ? SizedBox(
//                                                                                 width: 80.w,
//                                                                                 child: Column(
//                                                                                   children: [
//                                                                                     Icon(
//                                                                                       Icons.outbound_rounded,
//                                                                                       color: Theme.of(context).colorScheme.primary,
//                                                                                       size: 48.sp,
//                                                                                     ),
//                                                                                     TextApp(
//                                                                                       isOverFlow: false,
//                                                                                       softWrap: true,
//                                                                                       text: "Exported",
//                                                                                       fontsize: 14.sp,
//                                                                                       color: Colors.black,
//                                                                                       textAlign: TextAlign.center,
//                                                                                       fontWeight: FontWeight.normal,
//                                                                                     ),
//                                                                                   ],
//                                                                                 ),
//                                                                               )
//                                                                             : SizedBox(
//                                                                                 width: 80.w,
//                                                                                 child: Column(
//                                                                                   children: [
//                                                                                     Icon(
//                                                                                       Icons.history,
//                                                                                       color: Colors.red,
//                                                                                       size: 48.sp,
//                                                                                     ),
//                                                                                     TextApp(
//                                                                                       isOverFlow: false,
//                                                                                       softWrap: true,
//                                                                                       text: "Returned",
//                                                                                       fontsize: 14.sp,
//                                                                                       color: Colors.black,
//                                                                                       textAlign: TextAlign.center,
//                                                                                       fontWeight: FontWeight.normal,
//                                                                                     ),
//                                                                                   ],
//                                                                                 ),
//                                                                               ),
//                                                                 SizedBox(
//                                                                   width: 10.w,
//                                                                 ),
//                                                                 Column(
//                                                                   crossAxisAlignment:
//                                                                       CrossAxisAlignment
//                                                                           .start,
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .start,
//                                                                   children: [
//                                                                     Row(
//                                                                       crossAxisAlignment:
//                                                                           CrossAxisAlignment
//                                                                               .center,
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .spaceBetween,
//                                                                       children: [
//                                                                         TextApp(
//                                                                           text:
//                                                                               dataShipment.shipmentCode,
//                                                                           fontsize:
//                                                                               18.sp,
//                                                                           color:
//                                                                               Colors.black,
//                                                                           fontWeight:
//                                                                               FontWeight.bold,
//                                                                         ),
//                                                                         SizedBox(
//                                                                           width:
//                                                                               50.w,
//                                                                         ),
//                                                                         TextApp(
//                                                                             text:
//                                                                                 formatDateTime(dataShipment.createdAt.toString()),
//                                                                             fontsize: 12.sp,
//                                                                             color: Colors.grey,
//                                                                             fontWeight: FontWeight.bold),
//                                                                       ],
//                                                                     ),
//                                                                     Row(
//                                                                       crossAxisAlignment:
//                                                                           CrossAxisAlignment
//                                                                               .start,
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .start,
//                                                                       children: [
//                                                                         SizedBox(
//                                                                           width:
//                                                                               280.w,
//                                                                           child:
//                                                                               TextApp(
//                                                                             softWrap:
//                                                                                 true,
//                                                                             isOverFlow:
//                                                                                 false,
//                                                                             text:
//                                                                                 "Receiver: ${dataShipment.receiverContactName}",
//                                                                             fontsize:
//                                                                                 16.sp,
//                                                                             color:
//                                                                                 Colors.grey,
//                                                                             fontWeight:
//                                                                                 FontWeight.normal,
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                     Row(
//                                                                       crossAxisAlignment:
//                                                                           CrossAxisAlignment
//                                                                               .center,
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .spaceBetween,
//                                                                       children: [
//                                                                         SizedBox(
//                                                                           width:
//                                                                               250.w,
//                                                                           child:
//                                                                               TextApp(
//                                                                             softWrap:
//                                                                                 true,
//                                                                             isOverFlow:
//                                                                                 false,
//                                                                             text:
//                                                                                 "Địa chỉ: ${dataShipment.receiverAddress1}",
//                                                                             maxLines:
//                                                                                 3,
//                                                                             fontsize:
//                                                                                 16.sp,
//                                                                             color:
//                                                                                 Colors.grey,
//                                                                             fontWeight:
//                                                                                 FontWeight.normal,
//                                                                           ),
//                                                                         ),
//                                                                         InkWell(
//                                                                           onTap:
//                                                                               () async {
//                                                                             log("Fetching details for shipment: ${dataShipment.shipmentCode}");

//                                                                             // Trigger DetailsShipmentBloc to fetch shipment details by shipmentCode
//                                                                             context.read<DetailsShipmentBloc>().add(HanldeDetailsShipment(shipmentCode: dataShipment.shipmentCode));

//                                                                             // Listen to the DetailsShipmentBloc state to handle navigation after fetching data
//                                                                             final detailsState = await context.read<DetailsShipmentBloc>().stream.firstWhere((state) =>
//                                                                                 state is DetailsShipmentStateSuccess ||
//                                                                                 state is DetailsShipmentStateFailure);

//                                                                             if (detailsState
//                                                                                 is DetailsShipmentStateSuccess) {
//                                                                               final shipmentDetails = detailsState.detailsShipmentModel.shipment;

//                                                                               // Check if packages exist and navigate accordingly
//                                                                               if (shipmentDetails.packages.isNotEmpty) {
//                                                                                 log("Package HAWB Code: ${shipmentDetails.packages[0].packageHawbCode}");
//                                                                                 Navigator.push(
//                                                                                   context,
//                                                                                   MaterialPageRoute(
//                                                                                     builder: (context) => TrackingShipmentStatusScreen(
//                                                                                       packageHawbCode: shipmentDetails.packages[0].packageHawbCode!,
//                                                                                     ),
//                                                                                   ),
//                                                                                 );
//                                                                               } else {
//                                                                                 log("No packages available!");
//                                                                                 showCustomDialogModal(
//                                                                                   context: navigatorKey.currentContext!,
//                                                                                   textDesc: "Mã này không tồn tại",
//                                                                                   title: "Thông báo",
//                                                                                   colorButtonOk: Colors.red,
//                                                                                   btnOKText: "Xác nhận",
//                                                                                   typeDialog: "error",
//                                                                                   eventButtonOKPress: () {},
//                                                                                   isTwoButton: false,
//                                                                                 );
//                                                                               }
//                                                                             } else if (detailsState
//                                                                                 is DetailsShipmentStateFailure) {
//                                                                               log("Error fetching details: ${detailsState.message}");
//                                                                               showCustomDialogModal(
//                                                                                 context: navigatorKey.currentContext!,
//                                                                                 textDesc: detailsState.message,
//                                                                                 title: "Thông báo",
//                                                                                 colorButtonOk: Colors.red,
//                                                                                 btnOKText: "Xác nhận",
//                                                                                 typeDialog: "error",
//                                                                                 eventButtonOKPress: () {},
//                                                                                 isTwoButton: false,
//                                                                               );
//                                                                             }
//                                                                           },
//                                                                           child:
//                                                                               Icon(
//                                                                             Icons.arrow_circle_right,
//                                                                             size:
//                                                                                 42.sp,
//                                                                             color:
//                                                                                 Theme.of(context).colorScheme.primary,
//                                                                           ),
//                                                                         )
//                                                                       ],
//                                                                     ),
//                                                                     Row(
//                                                                       crossAxisAlignment:
//                                                                           CrossAxisAlignment
//                                                                               .start,
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .start,
//                                                                       children: [
//                                                                         SizedBox(
//                                                                           width:
//                                                                               250.w,
//                                                                           child:
//                                                                               TextApp(
//                                                                             softWrap:
//                                                                                 true,
//                                                                             isOverFlow:
//                                                                                 false,
//                                                                             text:
//                                                                                 "Dịch vụ: ${dataShipment.service.serviceName}",
//                                                                             fontsize:
//                                                                                 16.sp,
//                                                                             color:
//                                                                                 Colors.grey,
//                                                                             fontWeight:
//                                                                                 FontWeight.normal,
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ],
//                                                                 )
//                                                               ],
//                                                             )),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 );
//                                               }
//                                             }),
//                                   )
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 } else if (state is ListUserStateFailure) {
//                   return ErrorDialog(
//                     eventConfirm: () {
//                       Navigator.pop(context);
//                     },
//                     errorText: 'Failed to fetch orders: ${state.message}',
//                   );
//                 }
//                 return const Center(child: NoDataFoundWidget());
//               },
//             )));
//   }
// }
