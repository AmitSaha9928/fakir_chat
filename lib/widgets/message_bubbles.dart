import 'package:fakir_chat/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class TextMessageBubble extends StatelessWidget {
  final bool isOwnMessage;
  final ChatMessage message;
  final double height;
  final double width;

  TextMessageBubble({
    required this.isOwnMessage,
    required this.message,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> _colorScheme = isOwnMessage
        ? [Color.fromRGBO(0, 136, 249, 1.0), Color.fromRGBO(0, 82, 218, 1.0)]
        : [
            Color.fromRGBO(51, 49, 68, 1.0),
            Color.fromRGBO(51, 49, 68, 1.0),
          ];
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use min to avoid overflow
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4), // Add some spacing
          Text(
            timeago.format(message.sentTime),
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class FileMessageBubble extends StatelessWidget {
  final bool isOwnMessage;
  final ChatMessage message;
  final double height;
  final double width;

  FileMessageBubble({
    required this.isOwnMessage,
    required this.message,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> _colorScheme = isOwnMessage
        ? [Color.fromRGBO(0, 136, 249, 1.0), Color.fromRGBO(0, 82, 218, 1.0)]
        : [
            Color.fromRGBO(51, 49, 68, 1.0),
            Color.fromRGBO(51, 49, 68, 1.0),
          ];
    return GestureDetector(
      onTap: () {
        _launchURL(message.url!);
      },
      child: Container(
        height: height + (message.content.length / 20 * 6.0),
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: _colorScheme,
            stops: [0.30, 0.70],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download: ${message.content}', // Display "Download: filename"
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              timeago.format(message.sentTime),
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch URL
  void _launchURL(String url) async {
    if (url != null) {
      if (await canLaunchUrl(Uri(scheme: "https", path: url))) {
        await launchUrl(
          Uri.parse(url),
          //forceWebView: true,
        );
      } else {
        print('Could not launch $url');
        // Optionally, display an error message to the user
      }
    } else {
      print('URL is null');
      // Optionally, display an error message to the user
    }
  }
}

class ImageMessageBubble extends StatelessWidget {
  final bool isOwnMessage;
  final ChatMessage message;
  final double height;
  final double width;

  ImageMessageBubble(
      {required this.isOwnMessage,
      required this.message,
      required this.height,
      required this.width});

  @override
  Widget build(BuildContext context) {
    List<Color> _colorScheme = isOwnMessage
        ? [Color.fromRGBO(0, 136, 249, 1.0), Color.fromRGBO(0, 82, 218, 1.0)]
        : [
            Color.fromRGBO(51, 49, 68, 1.0),
            Color.fromRGBO(51, 49, 68, 1.0),
          ];
    DecorationImage _image = DecorationImage(
      image: NetworkImage(message.content),
      fit: BoxFit.cover,
    );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: height * 0.03,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: _image,
            ),
          ),
          SizedBox(height: height * 0.02),
          Text(
            timeago.format(message.sentTime),
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
