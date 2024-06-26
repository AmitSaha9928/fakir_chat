//Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/chats_page_provider.dart';

//Services
import '../services/navigation_service.dart';

//Pages
import '../pages/chat_page.dart';

//Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

//Models
import '../models/chat.dart';
import '../models/chat_user.dart';
import '../models/chat_message.dart';

class ChatsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChatsPageState();
  }
}

class _ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late ChatsPageProvider _pageProvider;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatsPageProvider>(
          create: (_) => ChatsPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext _context) {
        _pageProvider = _context.watch<ChatsPageProvider>();
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03,
            vertical: _deviceHeight * 0.02,
          ),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                'Chats',
                primaryAction: IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Color.fromRGBO(0, 82, 218, 1.0),
                  ),
                  onPressed: () {
                    _auth.logout();
                  },
                ),
              ),
              _chatsList(),
            ],
          ),
        );
      },
    );
  }

  Widget _chatsList() {
    List<Chat>? _chats = _pageProvider.chats;
    return Expanded(
      child: (() {
        if (_chats != null) {
          if (_chats.length != 0) {
            // _pageProvider.calculateUnreadMessagesCount();
            return ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (BuildContext _context, int _index) {
                return _chatTile(
                  _chats[_index],
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                "No Chats Found.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      })(),
    );
  }

  Widget _chatTile(Chat _chat) {
    List<ChatUser> _recepients = _chat.recepients();
    bool _isActive = _recepients.any((_d) => _d.wasRecentlyActive());
    String _subtitleText = "";
    if (_chat.messages.isNotEmpty) {
      if (_chat.messages.first.type != MessageType.TEXT) {
        _subtitleText = "Media Attachment";
      } else {
        String messageContent = _chat.messages.first.content;
        // Split the message content into words
        List<String> words = messageContent.split(' ');
        // Take the first 10 words and join them back together
        _subtitleText =
            '${words.take(10).join(' ')}${words.length > 10 ? '...' : ''}';
      }
    }

    Widget _unreadMessagesCountWidget() {
      _pageProvider.listenToUnreadMessagesCount(_chat.uid);
      bool currentUserIsNotSender = _chat.messages.isNotEmpty &&
          _chat.messages.first.senderID != _auth.user.uid;
      if (_chat.unreadMessagesCount > 0 && currentUserIsNotSender) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${_chat.unreadMessagesCount}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    }

    return Row(
      children: [
        Expanded(
          child: CustomListViewTileWithActivity(
            height: _deviceHeight * 0.10,
            title: _chat.title(),
            subtitle: _subtitleText,
            imagePath: _chat.imageURL(),
            isActive: _isActive,
            isActivity: _chat.activity,
            onTap: () {
              _pageProvider.markMessagesAsRead(_chat);
              _navigation.navigateToPage(
                ChatPage(chat: _chat),
              );
            },
          ),
        ),
        _unreadMessagesCountWidget(),
      ],
    );
  }
}
