import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo_app/model/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'model/memo.dart';
import 'provider/memo.provider.dart';

class EditPage extends ConsumerWidget {
  EditPage(this.memo, this.index);
  final Memo memo; 
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _myController = TextEditingController(text: memo.content);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Page"),
      ),
      body: Container(
      child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _myController,
              ),
            ),
        height: double.infinity,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Memo editedMemo = Memo(
              id: index.toString(),
              content: _myController.text,
              isSelected: false,
              createTime: memo.createTime,
              updateTime: DateTime.now());
          ref.read(memosProvider.notifier).editMemo(editedMemo);
          ref.read(prefsProvider).saveData();
        },
        child: const Text('保存'),
      ),
    );
  }
}