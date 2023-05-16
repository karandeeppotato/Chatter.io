import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_io/api/apis.dart';
import 'package:chatter_io/helper/my_date_util.dart';
import 'package:chatter_io/main.dart';
import 'package:chatter_io/models/chat_user.dart';
import 'package:chatter_io/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/message.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.blue.shade100,
      margin: EdgeInsets.symmetric(
          horizontal: screen_size.width * .04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) {
                  _message = list[0];
                }

                return ListTile(
                    // leading: CircleAvatar( child: Icon(CupertinoIcons.person)),
                    leading: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(
                                  user: widget.user,
                                ));
                      },
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(screen_size.height * .3),
                        child: CachedNetworkImage(
                            width: screen_size.height * .055,
                            height: screen_size.height * .055,
                            imageUrl: widget.user.image,
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                )),
                      ),
                    ),
                    title: Text(widget.user.name),
                    subtitle: Text(
                      _message != null
                          ? _message!.type == Type.image
                              ? '🖼️ Image'
                              : _message!.msg
                          : widget.user.about,
                      maxLines: 1,
                    ),
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty &&
                                _message!.fromId != APIs.user.uid
                            ? Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                    color: Colors.greenAccent.shade400,
                                    borderRadius: BorderRadius.circular(10)),
                              )
                            : Text(
                                MyDateUtil.getLastMessageTime(
                                    context: context, time: _message!.sent),
                                style: TextStyle(color: Colors.black54),
                              ));
              })),
    );
  }
}
