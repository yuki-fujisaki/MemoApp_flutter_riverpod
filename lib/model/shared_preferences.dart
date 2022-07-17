import 'dart:convert';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memo_app/provider/memo.provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getDateString() {
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = outputFormat.format(now);
    return date;
  }

  String getDateTimeToString(DateTime now) {
    DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    String date = outputFormat.format(now);
    return date;
  }

  DateTime getDateTime(String datetimeStr) {
    final _dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime result;

    // String→DateTime変換
    result = _dateFormatter.parseStrict(datetimeStr);
    return result;
  }

final prefsProvider = Provider.autoDispose((ref) => SharedPreference(ref));

class SharedPreference {
  const SharedPreference(this._ref);

  final Ref _ref;

  Future<void> getData() async {
    // 毎回インスタンス生成している訳ではなく、内部的に
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? memoJson = await prefs.getStringList('memo');

    print('Geiitng json $memoJson');

    if (memoJson == null || memoJson == []) {
      memosProvider;
      return;
    }
    List<Memo> decodedJson = memoJson
        .map((e) => Memo.fromJson(json.decode(e) as Map<String, dynamic>))
        .toList();
    _ref.watch(memosProvider.notifier).state = decodedJson;
    print('Geiitng provider $memosProvider');

    final memomemo = _ref.watch(memosProvider);
    memomemo.forEach((e) => print('${e.content}'));
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // List<String> memoCoverted = _memos.map((e) => e.createTime　= getDateTimeToString(e.createTime as DateTime)).toList();
    
    List<String> memoJson = _ref.read(memosProvider.notifier).state
        .map((e) => json.encode(e.toJson(getDateTimeToString(e.createTime),
            getDateTimeToString(e.updateTime))))
        .toList();
    print('Setting json $memoJson');
    await prefs.setStringList('memo', memoJson);
  }

  Future<void> deleteData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('memo');
  }
  
}