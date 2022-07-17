// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:intl/intl.dart';

// DateTime getDateTime(String datetimeStr) {
//   final _dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
//   DateTime result;

//   // String→DateTime変換
//   result = _dateFormatter.parse(datetimeStr);
//   return result;
// }

// class Memo {
//   Memo({
//     this.content = '',
//     required this.createTime,
//     required this.updateTime,
//     this.isSelected = false,
//   });

//   String content;
//   DateTime createTime;
//   DateTime updateTime;
//   bool isSelected;

//   Map<String, dynamic> toJson(
//       String stringCreateTime, String stringUpdateTime) {
//     return {
//       'content': content,
//       'createTime': stringCreateTime,
//       'updateTime': stringUpdateTime,
//       'isEditing': isSelected,
//     };
//   }

//   static Memo fromJson(Map<String, dynamic> json) {
//     return Memo(
//       content: json['content'],
//       createTime: getDateTime(json['createTime']),
//       updateTime: getDateTime(json['updateTime']),
//       isSelected: json['isEditing'],
//     );
//   }
// }







// // List<Memo> _memos = [];
// // final memosProvider = Provider<List<Memo>>((ref)=>
// //   //  Memo.;
// // );

// // import 'package:freezed_annotation/freezed_annotation.dart';
// // import 'package:app/data/utils/json_converter.dart';

// // part 'hoge.freezed.dart';
// // part 'hoge.g.dart';

// // @freezed
// // class Hoge with _$Hoge {
// //   const Hoge._();
// //   factory Hoge({
// //     @Default('') String uid,
// //     @Default('') String title,
// //     @Default(false) bool isFavorite,
// //     @Default(<String>[]) List<String> tags,
// //     @JsonKey(fromJson: datetimeOrNullFromString) required DateTime? createdAt,
// //     @JsonKey(fromJson: datetimeOrNullFromString) required DateTime? updatedAt,
// //   }) = _Hoge;

// //   factory Hoge.fromJson(Map<String, dynamic> json) => _$HogeFromJson(json);

// // }


// // // fromJson staticとかグローバルな関数じゃないとダメ
// // DateTime? datetimeOrNullFromString(String? dateString) {
// //   // 文字列をDateTimeに変換する処理
// //   return DateFormatter.parse(dateString, "フォーマット");
// // }