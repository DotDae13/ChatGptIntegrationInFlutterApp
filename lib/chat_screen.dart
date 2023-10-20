import 'dart:async';

import 'package:Dost/threedots.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
// ignore: depend_on_referenced_packages
import 'package:velocity_x/velocity_x.dart';
import 'chatmessage.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late OpenAI? openAI;

  StreamSubscription? _subscription;
  bool _isTyping = false;


  @override
  void initState() {
    openAI = OpenAI.instance;
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }


  void _sendMessage() async{
    if (_controller.text.isEmpty) return;
    ChatMessage message = ChatMessage(text: _controller.text, sender: "Sugam");

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    _controller.clear();
    final request =
    CompleteText(prompt: message.text, model: kTranslateModelV3);

  _subscription = openAI
      !.build(token: "YOUR_API_KEY(Generate from OpenAI")
      .onCompleteStream(request: request)
      .listen((response) {
    Vx.log(response!.choices[0].text);
    ChatMessage botMessage =
    ChatMessage(
        text: response.choices[0].text,
        sender: "Dost");

    setState(() {
      _messages.length = 0;
     _isTyping = false;
     _messages.insert(0, botMessage);
   });
  });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
         Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (value) => _sendMessage(),
              decoration: const InputDecoration.collapsed(hintText: "Send a message"),
            ),
        ),
        IconButton(
            onPressed: () => _sendMessage(),
            icon: const Icon(Icons.send_rounded))
      ],
    ).px16();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DostApp')),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
                child: ListView.builder(
              reverse: true,
              padding: Vx.m8,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            )),
            if(_isTyping) const ThreeDots(),
            const Divider(
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(
                color:  context.cardColor
              ),
              child: _buildTextComposer(),
            )
          ],
        ),
      ),

    );
  }
}
