import 'package:flutter/material.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/meta/comment_meta.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/service/comment_service.dart';
import "package:flutter_screenutil/flutter_screenutil.dart";
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/constants/common.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/avatar.dart';
import 'package:vod_flutter_mini_drama/src/solutions/minidrama/utils/number_unit.dart';
import 'package:intl/intl.dart';

class CommentsDrawContent extends StatefulWidget {
  const CommentsDrawContent({super.key, required this.comments});

  final Comments comments;
  @override
  State<CommentsDrawContent> createState() => _CommentsDrawContentState();
}

class _CommentsDrawContentState extends State<CommentsDrawContent> {
  late TextEditingController _textEditingController;

  LoadStatus _loadStatus = LoadStatus.LOADING;

  late int uid;
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _loadComments();
    uid = int.parse(USER_ID, radix: 10);
  }

  _loadComments() async {
    final result = await widget.comments.loadComments();
    if (result == RequestStatus.SUCCESS) {
      _loadStatus = LoadStatus.SUCCESS;
    } else {
      _loadStatus = LoadStatus.FAILED;
    }
    setState(() {});
  }

  onSubmitted(String? value) {
    if (value == null || value.isEmpty) {
      return;
    }
    widget.comments.add(Comment(
      content: value,
      createTime: DateTime.now().toString(),
      like: 0,
      name: USERNAME,
      uid: uid,
    ));
    _textEditingController.clear();
    setState(() {});
  }

  toggleLike(int index) {
    setState(() {
      final incAmount = widget.comments.comments[index].liked ? -1 : 1;
      widget.comments.comments[index].like =
          widget.comments.comments[index].like! + incAmount;
      widget.comments.comments[index].liked =
          !widget.comments.comments[index].liked;
    });
  }

  showTip() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Tips"),
          content:
              const Text("Comments you post are temporary and will be visible only to you. BytePlus assures that no collection, storage or backups of these comments will be made."),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  delete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm deletion"),
          content: const Text("The comment content can not be restored after deletion. Please confirm the operation."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                setState(() {
                  widget.comments.comments.removeAt(index);
                });
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(children: [
              Container(
                height: 52,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      bottom: BorderSide(
                          color: Color.fromRGBO(235, 235, 235, 1), width: 1)),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: showTip,
                      child: const Icon(Icons.help_outline,
                          color: Color.fromRGBO(136, 139, 144, 1)),
                    ),
                    Center(
                      child: Text(
                        '${widget.comments.commentCount} comments',
                        style: const TextStyle(
                            fontSize: 16,
                            height: 24 / 16,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(12, 13, 15, 1)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.close,
                          color: Color.fromRGBO(12, 13, 15, 1)),
                    ),
                  ],
                ),
              ),
              Builder(builder: (context) {
                if (_loadStatus == LoadStatus.SUCCESS) {
                  return Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildComments(),
                        ),
                        _buildInput(),
                      ],
                    ),
                  );
                } else if (_loadStatus == LoadStatus.LOADING) {
                  return const Expanded(
                      child: Center(child: CircularProgressIndicator()));
                }
                return const Expanded(child: Text('加载失败'));
              })
            ])));
  }

  _buildComments() {
    return ListView.builder(
        itemCount: widget.comments.comments.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    height: 36,
                    width: 36,
                    child: CircleAvatar(
                      backgroundImage: AssetImage(getAvatarUrl(
                          widget.comments.comments[index].uid.toString())),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.comments.comments[index].name ?? '',
                          style: const TextStyle(
                              fontSize: 14,
                              height: 16 / 14,
                              color: Color.fromRGBO(128, 131, 138, 1)),
                        ),
                        Text(
                          widget.comments.comments[index].content ?? '',
                          style: const TextStyle(
                              fontSize: 14,
                              height: 20 / 14,
                              color: Color.fromRGBO(2, 8, 20, 1)),
                        ),
                        Row(
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(DateTime.parse(
                                  widget.comments.comments[index].createTime!)),
                              style: const TextStyle(
                                  color: Color.fromRGBO(128, 131, 138, 1),
                                  fontSize: 12,
                                  height: 16 / 12),
                            ),
                            if (widget.comments.comments[index].uid == uid)
                              GestureDetector(
                                onTap: () => delete(index),
                                child: const Row(
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 12, right: 4),
                                      child: Icon(
                                        Icons.delete,
                                        size: 14,
                                        color: Color.fromRGBO(78, 89, 105, 1),
                                      ),
                                    ),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                          color: Color.fromRGBO(78, 89, 105, 1),
                                          fontSize: 12,
                                          height: 16 / 12),
                                    ),
                                  ],
                                ),
                              )
                          ],
                        ),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => toggleLike(index),
                        child: Image.asset(
                          widget.comments.comments[index].liked
                              ? 'assets/minidrama/common/like.png'
                              : 'assets/minidrama/common/unlikeComment.png',
                          height: 20,
                          width: 20,
                        ),
                      ),
                      Text(
                          formatNumberEN(
                              widget.comments.comments[index].like ?? 0),
                          style: const TextStyle(
                              fontSize: 12,
                              height: 16 / 12,
                              color: Color.fromRGBO(128, 131, 138, 1)))
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  _buildInput() {
    const inputBorder = OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromRGBO(201, 205, 212, 1)),
        borderRadius: BorderRadius.all(Radius.circular(16)));
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        border: Border(
            top: BorderSide(color: Color.fromRGBO(235, 235, 235, 1), width: 1)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: TextFormField(
          style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: Color.fromRGBO(2, 8, 20, 1)),
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              hintText: 'Add comment…',
              hintStyle: TextStyle(
                  fontSize: 14, color: Color.fromRGBO(163, 167, 173, 1)),
              filled: true,
              fillColor: Color.fromRGBO(245, 245, 245, 1),
              border: inputBorder,
              enabledBorder: inputBorder,
              disabledBorder: inputBorder,
              focusedBorder: inputBorder,
              suffixIcon: Icon(
                Icons.emoji_emotions_outlined,
                color: Colors.grey,
              )),
          autofocus: false,
          textInputAction: TextInputAction.send,
          onFieldSubmitted: onSubmitted,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          controller: _textEditingController),
    );
  }
}
