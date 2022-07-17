import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memo_app/edit.dart';
import 'package:memo_app/provider/memo.provider.dart';
import 'package:memo_app/model/shared_preferences.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final _myController = TextEditingController();
  static const searchDelayMillSec = 1000;
  DateTime _lastChangedDate = DateTime.now();
  bool isEditing = false;
  bool isSelected = false;
  List<Memo> searchedNames = [];


  @override
  void initState() {
    super.initState();
    ref.read(prefsProvider).getData();
    print('Geiitng json $memosProvider');
  }

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
  }

  void search(String text) {
    if (text.trim().isEmpty) {
      ref.watch(searchedListProvider.notifier).state = [];
    } else {
      List<Memo> searchingList = [...ref.watch(memosProvider.notifier).state];
      searchingList =
          searchingList.where((e) => e.content == text).toList();
      ref.watch(searchedListProvider.notifier).state = [...searchingList];
      for (final memo in ref.watch(searchedListProvider.notifier).state)
      print('${memo.id},${memo.content},${memo.createTime},${memo.isSelected}');
    }
    
  }

  void delayedSearch(String text) {
    Future.delayed(const Duration(milliseconds: searchDelayMillSec), () {
      final nowDate = DateTime.now();
      if (nowDate.difference(_lastChangedDate).inMilliseconds > searchDelayMillSec) {
        print("delayed");
        _lastChangedDate = nowDate;
        search(text);
      }
    });
    //キーワードが入力されるごとに、検索処理を待たずに_lastChangedDateを更新する
    _lastChangedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // 購読
    final memoList = ref.watch(serchingProvider);
    List<Memo> memosList = memoList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memo App'),
        actions: [
          TextButton(
            child: isEditing
                ? const Text(
                    'キャンセル',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )
                : const Text(
                    '選択',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
            onPressed: () {
              print('クリックされました');
              setState(() => isEditing = !isEditing);
              print('${isEditing}');
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _myController,
                decoration: InputDecoration(
                  hintText: "投稿する文字を入力してください",
                ),
              ),
            ),
            // テキストフィールド
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "検索する文字を入力してください",
                ),
                onChanged: delayedSearch,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('作成日時'),
                ElevatedButton(
                  child: const Text('昇順'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    ref.read(prefsProvider).getData();
                    ref.read(memosProvider.notifier).sortByOrder();
                    print('sorted');
                  },
                ),
                ElevatedButton(
                  child: const Text('降順'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    ref.read(memosProvider.notifier).sortByReverseOrder();
                    print('sorted by reverse');
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('編集日時'),
                ElevatedButton(
                  child: const Text('昇順'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    ref.read(memosProvider.notifier).sortByUpdateTimeOrder();
                    print('sorted by updateTime');
                  },
                ),
                ElevatedButton(
                  child: const Text('降順'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    ref.read(memosProvider.notifier).sortByUpdateTimeReverseOrder();
                    print('sorted by updateTime reverse');
                  },
                ),
              ],
            ),
            // リストビュー
            Expanded(
              child: ListView.builder(
                itemCount: memosList.length,
                itemBuilder: (_, int index) {
                  final item = memosList[index];

                  return Dismissible(
                    key: ObjectKey(item),
                    onDismissed: (direction) {
                      memoList.removeAt(index);
                      ref.read(memosProvider.notifier).removeMemo(item.id);
                      ref.read(prefsProvider).saveData();
                    },
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: Card(
                      child: ListTile(
                        leading: isEditing
                            ? Checkbox(
                                value: item.isSelected,
                                onChanged: (value) {
                                  ref
                                      .read(memosProvider.notifier)
                                      .selectMemo(item, value!);
                                  print('${item.isSelected}');
                                },
                              )
                            : Text('${item.content}'),
                        trailing: Text('${item.updateTime}'),
                        onTap: () async {
                          await Navigator.push(
                              _,
                              MaterialPageRoute(
                                builder: (context) => EditPage(item, index),
                              ));
                          ref.read(prefsProvider).getData();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        verticalDirection: VerticalDirection.up, // childrenの先頭を下に配置
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              Memo memo = Memo(
                  id: (memoList.length).toString(),
                  content: _myController.text,
                  isSelected: false,
                  createTime: DateTime.now(),
                  updateTime: DateTime.now());
              ref.read(memosProvider.notifier).addMemo(memo);
              ref.read(prefsProvider).saveData();
              _myController.clear();
            },
            child: const Icon(Icons.add),
          ),
          isEditing
              ? Container(
                  // 余白のためContainerでラップ
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red, // background
                        onPrimary: Colors.white, // foreground
                      ),
                      child: const Icon(Icons.remove),
                      onPressed: () {
                        ref.read(memosProvider.notifier).deleteSelectedMemo();
                      },
                      onLongPress: () {
                        ref.read(memosProvider.notifier).deleteAllMemo();
                        ref.read(prefsProvider).deleteData();
                      }),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
