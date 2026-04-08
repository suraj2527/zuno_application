// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:zuno_application/utils/constants/app_colors.dart';
// import 'package:zuno_application/utils/constants/app_text_styles.dart';
// import 'package:zuno_application/utils/constants/app_gradients.dart';
// import 'package:zuno_application/presentation/screens/Dashboard/Chat/models/chat_preview_model.dart';

// import 'chat_controller.dart';

// class ChatDetailScreen extends StatelessWidget {
//   final ChatPreviewModel chat;
//   final ChatController controller = Get.find<ChatController>();

//   ChatDetailScreen({super.key}) : chat = Get.arguments as ChatPreviewModel;

//   final TextEditingController messageController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark
//           ? AppColors.chatSectionSurfaceDark
//           : AppColors.chatSectionSurfaceLight,
//       appBar: AppBar(
//         automaticallyImplyLeading: false, // <-- prevent duplicate back arrow
//         backgroundColor: isDark
//             ? AppColors.chatHeaderSurfaceDark
//             : AppColors.chatHeaderSurfaceLight,
//         elevation: 0,
//         titleSpacing: 0,
//         title: Row(
//           children: [
//             IconButton(
//               icon: Icon(
//                 Icons.arrow_back,
//                 color: isDark
//                     ? AppColors.textPrimaryDark
//                     : AppColors.textPrimary,
//               ),
//               onPressed: () => Get.back(),
//             ),
//             const SizedBox(width: 8),
//             CircleAvatar(
//               radius: 20,
//               backgroundColor: isDark
//                   ? AppColors.chatHeaderSurfaceDark
//                   : AppColors.profileAvatarBackground,
//               backgroundImage: chat.imageUrl.isNotEmpty
//                   ? NetworkImage(chat.imageUrl)
//                   : null,
//               child: chat.imageUrl.isEmpty
//                   ? Text(
//                       controller.getInitials(chat.name),
//                       style: AppTextStyles.bodyMedium(isDark: isDark),
//                     )
//                   : null,
//             ),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   chat.name,
//                   style: AppTextStyles.headingMedium(isDark: isDark),
//                 ),
//                 Text(
//                   chat.isOnline ? 'Online now' : 'Offline',
//                   style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
//                     color: chat.isOnline
//                         ? AppColors.green
//                         : isDark
//                         ? AppColors.textSecondaryDark
//                         : AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Builder(
//               builder: (_) {
//                 // Hardcoded messages demo
//                 final messages = [
//                   {'text': 'Hey! Saw you nearby. 👋', 'isMe': false, 'time': '2:15 PM'},
//                   {'text': 'Hey there! 😁 That was quick!', 'isMe': true, 'time': '2:16 PM'},
//                   {'text': 'Yeah, thought why not. What are you up to?', 'isMe': false, 'time': '2:17 PM'},
//                   {'text': 'Just grabbing a coffee ☕', 'isMe': true, 'time': '2:18 PM'},
//                   {'text': 'Nice! Maybe I’ll join you. 🐱', 'isMe': false, 'time': '2:19 PM'},
//                 ];

//                 return ListView.builder(
//                   reverse: true,
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   itemCount: messages.length,
//                   itemBuilder: (_, index) {
//                     final message = messages[messages.length - 1 - index];
//                     final isMe = message['isMe'] as bool;
//                     return Align(
//                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 4),
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         constraints: BoxConstraints(maxWidth: Get.width * 0.7),
//                         decoration: BoxDecoration(
//                           gradient: isMe ? AppGradients.primary : null,
//                           color: isMe
//                               ? null
//                               : (isDark
//                                   ? AppColors.chatTileHoverDark
//                                   : AppColors.chatTileHoverLight),
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(16),
//                             topRight: Radius.circular(16),
//                             bottomLeft: isMe ? Radius.circular(16) : Radius.circular(0),
//                             bottomRight: isMe ? Radius.circular(0) : Radius.circular(16),
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(message['text'].toString(),
//                                 style: AppTextStyles.bodyMedium(isDark: !isMe)),
//                             const SizedBox(height: 4),
//                             Text(message['time'].toString(),
//                                 style: AppTextStyles.bodySmall(isDark: !isMe)),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           _buildMessageInput(context, isDark),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageInput(BuildContext context, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       color: isDark
//           ? AppColors.chatHeaderSurfaceDark
//           : AppColors.chatHeaderSurfaceLight,
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: messageController,
//               style: AppTextStyles.body(isDark: isDark),
//               decoration: InputDecoration(
//                 hintText: 'Type a message...',
//                 hintStyle: AppTextStyles.bodySmall(isDark: isDark),
//                 filled: true,
//                 fillColor: isDark
//                     ? AppColors.inputFillDark
//                     : AppColors.inputFillLight,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(22),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 0,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: () {
//               if (messageController.text.trim().isNotEmpty) {
//                 Get.snackbar(
//                   'Send Message',
//                   messageController.text.trim(),
//                   snackPosition: SnackPosition.BOTTOM,
//                   duration: const Duration(seconds: 1),
//                 );
//                 messageController.clear();
//               }
//             },
//             child: Container(
//               height: 48,
//               width: 48,
//               decoration: BoxDecoration(
//                 gradient: AppGradients.primary,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.send, color: AppColors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/utils/constants/app_colors.dart';
import 'package:zuno_application/utils/constants/app_text_styles.dart';
import 'package:zuno_application/utils/constants/app_gradients.dart';
import 'package:zuno_application/presentation/screens/Dashboard/Chat/models/chat_preview_model.dart';

import '../home/home_controller.dart';
import 'chat_controller.dart';
import 'widgets/profile_detail_screen.dart';

class ChatDetailScreen extends StatelessWidget {
  final ChatPreviewModel chat;
  final ChatController controller = Get.find<ChatController>();

  ChatDetailScreen({super.key}) : chat = Get.arguments as ChatPreviewModel;

  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profiles = Get.find<HomeController>().allProfiles;
    final profile = profiles.where((p) => p.id == chat.id).isNotEmpty
        ? profiles.firstWhere((p) => p.id == chat.id)
        : null;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.chatSectionSurfaceDark
          : AppColors.chatSectionSurfaceLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Get.to(
                  () => ProfileDetailsScreen(
                    profile: profile,
                    heroTag: "profile_${profile?.id}",
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.3),
                backgroundImage: chat.imageUrl.isNotEmpty
                    ? NetworkImage(chat.imageUrl)
                    : null,
                child: chat.imageUrl.isEmpty
                    ? Text(
                        controller.getInitials(chat.name),
                        style: AppTextStyles.bodyMedium(
                          isDark: false,
                        ).copyWith(color: Colors.white),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: AppTextStyles.headingMedium(
                      isDark: false,
                    ).copyWith(color: Colors.white),
                  ),
                  Text(
                    chat.isOnline ? 'Online now' : 'Offline',
                    style: AppTextStyles.bodySmall(
                      isDark: false,
                    ).copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                switch (value) {
                  case 'clear_chat':
                    Get.snackbar(
                      'Action',
                      'Chat Cleared',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    break;
                  case 'mute':
                    Get.snackbar(
                      'Action',
                      'Chat Muted',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'clear_chat',
                  child: Text('Clear Chat'),
                ),
                const PopupMenuItem<String>(
                  value: 'mute',
                  child: Text('Mute Notifications'),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (_) {
                final messages = [
                  {
                    'text': 'Hey! Saw you nearby. 👋',
                    'isMe': false,
                    'time': '2:15 PM',
                  },
                  {
                    'text': 'Hey there! 😁 That was quick!',
                    'isMe': true,
                    'time': '2:16 PM',
                  },
                  {
                    'text': 'Yeah, thought why not. What are you up to?',
                    'isMe': false,
                    'time': '2:17 PM',
                  },
                  {
                    'text': 'Just grabbing a coffee ☕',
                    'isMe': true,
                    'time': '2:18 PM',
                  },
                  {
                    'text': 'Nice! Maybe I’ll join you. 🐱',
                    'isMe': false,
                    'time': '2:19 PM',
                  },
                ];

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMe = message['isMe'] as bool;
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        constraints: BoxConstraints(maxWidth: Get.width * 0.7),
                        decoration: BoxDecoration(
                          gradient: isMe ? AppGradients.primary : null,
                          color: isMe
                              ? null
                              : (isDark
                                    ? AppColors.chatTileHoverDark
                                    : AppColors.chatTileHoverLight),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isMe
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              message['text'].toString(),
                              style: AppTextStyles.bodyMedium(isDark: !isMe),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message['time'].toString(),
                              style: AppTextStyles.bodySmall(isDark: !isMe),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: isDark
          ? AppColors.chatHeaderSurfaceDark
          : AppColors.chatHeaderSurfaceLight,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              style: AppTextStyles.body(isDark: isDark),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTextStyles.bodySmall(isDark: isDark),
                filled: true,
                fillColor: isDark
                    ? AppColors.inputFillDark
                    : AppColors.inputFillLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (messageController.text.trim().isNotEmpty) {
                Get.snackbar(
                  'Send Message',
                  messageController.text.trim(),
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 1),
                );
                messageController.clear();
              }
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
