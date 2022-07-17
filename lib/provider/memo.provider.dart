import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../index.dart';

DateTime getDateTime(String datetimeStr) {
  final _dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  DateTime result;

  // String→DateTime変換
  result = _dateFormatter.parse(datetimeStr);
  return result;
}

// StateNotifier のステート（状態）はイミュータブル（不変）である必要があります。
// ここは Freezed のようなパッケージを利用してイミュータブルにしても OK です。
@immutable
class Memo {
  const Memo(
      {required this.id,
      required this.content,
      required this.createTime,
      required this.updateTime,
      required this.isSelected});

  // イミュータブルなクラスのプロパティはすべて `final` にする必要があります。
  final String id;
  final String content;
  final DateTime createTime;
  final DateTime updateTime;
  final bool isSelected;

  Map<String, dynamic> toJson(
      String stringCreateTime, String stringUpdateTime) {
    return {
      'id': id,
      'content': content,
      'createTime': stringCreateTime,
      'updateTime': stringUpdateTime,
      'isEditing': isSelected,
    };
  }

  static Memo fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['id'],
      content: json['content'],
      createTime: getDateTime(json['createTime']),
      updateTime: getDateTime(json['updateTime']),
      isSelected: json['isEditing'],
    );
  }

  // Todo はイミュータブルであり、内容を直接変更できないためコピーを作る必要があります。
  // これはオブジェクトの各プロパティの内容をコピーして新たな Memo を返すメソッドです。
  Memo copyWith(
      {String? id,
      String? content,
      DateTime? createTime,
      DateTime? updateTime,
      bool? isSelected}) {
    return Memo(
      id: id ?? this.id,
      content: content ?? this.content,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

// StateNotifierProvider に渡すことになる StateNotifier クラスです。
// このクラスではステートを `state` プロパティの外に公開しません。
// つまり、ステートに関しては public なゲッターやプロパティは作らないということです。
// public メソッドを通じて UI 側にステートの操作を許可します。
class MemosNotifier extends StateNotifier<List<Memo>> {
  // Todo リストを空のリストとして初期化します。
  MemosNotifier() : super([]);

  // Todo の追加
  void addMemo(Memo memo) {
    // ステート自体もイミュータブルなため、`state.add(todo)`
    // のような操作はできません。
    // 代わりに、既存 Todo と新規 Todo を含む新しいリストを作成します。
    // Dart のスプレッド演算子を使うと便利ですよ!
    state = [...state, memo];
    for (final memo in state) {
      print('${memo.id},${memo.content},${memo.createTime}');
    }
    // `notifyListeners` などのメソッドを呼ぶ必要はありません。
    // `state =` により必要なときに UI側 に通知が届き、ウィジェットが更新されます。
  }

  void editMemo(Memo editingMemo) {
    List<Memo> editingState = [...state];
    editingState.removeAt(int.parse(editingMemo.id));
    editingState.insert(int.parse(editingMemo.id), editingMemo);

    state = [...editingState];
    for (final memo in state)
      print('${memo.id},${memo.content},${memo.createTime},${memo.isSelected}');
  }

  // Memo の削除
  void removeMemo(String memoId) {
    // しつこいですが、ステートはイミュータブルです。
    // そのため既存リストを変更するのではなく、新しくリストを作成する必要があります。
    state = [
      for (final memo in state)
        if (memo.id != memoId) memo,
    ];
    print('removed${memoId}');
  }

  void sortByOrder() {
    List<Memo> sortingState = [...state];
    sortingState.sort((a, b) => a.createTime.compareTo(b.createTime));
    state = [...sortingState];
    for (final memo in state)
      print('${memo.id},${memo.content},${memo.createTime}');
  }

  void sortByReverseOrder() {
    List<Memo> sortingState = [...state];
    sortingState.sort((a, b) => b.createTime.compareTo(a.createTime));
    state = [...sortingState];
    for (final memo in state)
      print('${memo.id},${memo.content},${memo.createTime}');
  }

  void sortByUpdateTimeOrder() {
    List<Memo> sortingState = [...state];
    sortingState.sort((a, b) => a.updateTime.compareTo(b.updateTime));
    state = [...sortingState];
    for (final memo in state)
      print('${memo.id},${memo.content},${memo.updateTime}');
  }

  void sortByUpdateTimeReverseOrder() {
    List<Memo> sortingState = [...state];
    sortingState.sort((a, b) => b.updateTime.compareTo(a.updateTime));
    state = [...sortingState];
    for (final memo in state)
      print('${memo.id},${memo.content},${memo.updateTime}');
  }

  void selectMemo(Memo item, bool value) {
    List<Memo> selectingState = [...state];

    selectingState.removeAt(int.parse(item.id));
    selectingState.insert(int.parse(item.id), item.copyWith(isSelected: value));
    state = [...selectingState];
    for (final memo in state)
      print('${memo.id},${memo.content},${memo.createTime},${memo.isSelected}');
  }

  void deleteSelectedMemo() {
    List<Memo> selectedList = [...state];
    selectedList = selectedList.where((e) => !e.isSelected).toList();
    state = [...selectedList];
    for (final memo in state)
      print('${memo.id},${memo.content},${memo.createTime},${memo.isSelected}');
  }

  void deleteAllMemo() {
    List<Memo> willDeleteList = [...state];
    willDeleteList = [];
    state = [...willDeleteList];
  }

}

// 最後に MemosNotifier のインスタンスを値に持つ StateNotifierProvider を作成し、
// UI 側から Memo リストを操作することを可能にします。
final memosProvider = StateNotifierProvider<MemosNotifier, List<Memo>>((ref) {
  return MemosNotifier();
});

final searchedListProvider = StateProvider<List<Memo>>((ref) => []);

final serchingProvider = Provider<List<Memo>>((ref) {
  final searchedList = ref.watch(searchedListProvider);
  final memosList = ref.watch(memosProvider);
  if (searchedList.length == 0){
    return memosList;   
  }
  if (searchedList.length != 0){
    return searchedList;
  }
  else{
    return memosList;
  }
});
