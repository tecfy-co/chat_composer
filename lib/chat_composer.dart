import 'package:flutter/services.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:record/record.dart';

import 'consts/consts.dart';
import 'cubit/recordaudio_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/message_field.dart';
import 'package:flutter/material.dart';
import 'widgets/send_button.dart';

export 'package:flutter_portal/flutter_portal.dart';
export 'package:flutter_mentions/flutter_mentions.dart';

class ChatComposer extends StatefulWidget {
  /// A widget to display before the [TextField].
  final Widget? leading;

  /// A list of Widgets to display in a row after the [TextField] widget.
  final List<Widget>? actions;

  /// A callback when submit Text Message.
  final Future Function(String?) onReceiveText;

  /// A callback when start recording.
  final Function()? onRecordStart;

  /// A callback when end recording, return the recorder audio path.
  final Function(String?, List<int>?, Duration?) onRecordEnd;

  /// record encoder
  final AudioEncoder audioEncoder;

  /// record in file or stream
  final bool audioFile;

  /// disable Audio
  final bool disableAudio;

  /// A callback when cancel recording.
  final Function()? onRecordCancel;

  /// A callback when the user does not lock the recording or does not hold.
  final Function()? onPanCancel;

  /// Audio max duration should record then return recorder audio path.
  final Duration maxRecordLength;

  /// focusNode
  final FocusNode focusNode;

  /// controller
  final TextEditingController? controller;

  /// textCapitalization
  final TextCapitalization? textCapitalization;

  /// textInputAction
  final TextInputAction? textInputAction;

  /// keyboardType
  final TextInputType? keyboardType;

  /// textStyle
  final TextStyle? textStyle;

  /// textFieldDecoration
  final InputDecoration? textFieldDecoration;

  /// textPadding
  final EdgeInsetsGeometry? textPadding;

  /// borderRadius
  final BorderRadius? borderRadius;

  /// shadow
  final List<BoxShadow>? shadow;

  /// backgroundColor
  final Color? backgroundColor;

  /// composerColor
  final Color? composerColor;

  /// sendButtonColor
  final Color? sendButtonColor;

  /// sendButtonBackgroundColor
  final Color? sendButtonBackgroundColor;

  /// lockColor
  final Color? lockColor;

  /// lockBackgroundColor
  final Color? lockBackgroundColor;

  /// recordIconColor
  final Color? recordIconColor;

  /// deleteButtonColor
  final Color? deleteButtonColor;

  /// textColor
  final Color? textColor;

  /// padding
  final EdgeInsetsGeometry? padding;

  /// sendIcon
  final IconData? sendIcon;

  /// recordIcon
  final IconData? recordIcon;

  final BuildContext? context;

  /// mention global Key
  final GlobalKey<FlutterMentionsState>? mentionKey;

  /// mentions List
  final List<Mention>? mentions;

  final double? suggestionListWidth;
  final double? suggestionListHeight;
  ChatComposer(
      {Key? key,
      required this.onReceiveText,
      required this.onRecordEnd,
      this.onRecordStart,
      this.onRecordCancel,
      required this.focusNode,
      this.controller,
      this.leading,
      this.suggestionListHeight,
      this.suggestionListWidth,
      this.actions,
      this.context,
      this.textCapitalization,
      this.textInputAction,
      this.keyboardType,
      this.textStyle,
      this.textFieldDecoration,
      this.textPadding,
      this.backgroundColor,
      this.composerColor,
      this.sendButtonColor,
      this.sendButtonBackgroundColor,
      this.lockColor,
      this.lockBackgroundColor,
      this.recordIconColor,
      this.deleteButtonColor,
      this.textColor,
      this.padding,
      this.sendIcon,
      this.recordIcon,
      this.mentionKey,
      this.mentions,
      this.borderRadius,
      this.shadow,
      this.maxRecordLength = const Duration(minutes: 1),
      this.onPanCancel,
      this.disableAudio = false,
      this.audioFile = false,
      this.audioEncoder = AudioEncoder.pcm16bits})
      : assert(
            (mentionKey != null && mentions == null)
                ? false
                : (mentionKey == null && mentions != null)
                    ? false
                    : true,
            'mentions and mentionKey should be defined with each other'),
        super(key: key) {
    localBackgroundColor = backgroundColor ?? localBackgroundColor;
    localComposerColor = composerColor ?? localComposerColor;
    localSendButtonColor = sendButtonColor ?? localSendButtonColor;
    localSendButtonBackgroundColor =
        sendButtonBackgroundColor ?? localSendButtonBackgroundColor;
    localLockColor = lockColor ?? localLockColor;
    localLockBackgroundColor = lockBackgroundColor ?? localLockBackgroundColor;
    localRecordIconColor = recordIconColor ?? localRecordIconColor;
    localDeleteButtonColor = deleteButtonColor ?? localDeleteButtonColor;
    localTextColor = textColor ?? localTextColor;
    localPadding = padding ?? localPadding;
    localSendIcon = sendIcon ?? localSendIcon;
    localRecordIcon = recordIcon ?? localRecordIcon;
    localborderRadius = borderRadius ?? localborderRadius;
    localController = controller ?? localController;
  }

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecordAudioCubit(
        disableAudio: widget.disableAudio,
        onRecordEnd: widget.onRecordEnd,
        onRecordCancel: widget.onRecordCancel,
        onRecordStart: widget.onRecordStart,
        maxRecordLength: widget.maxRecordLength,
        audioFile: widget.audioFile,
        encoder: widget.audioEncoder,
      ),
      child: Container(
        color: localBackgroundColor,
        child: Padding(
          padding: localPadding,
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minHeight: composerHeight),
                      child: Container(
                        margin: EdgeInsets.zero,
                        decoration: BoxDecoration(
                            color: localComposerColor,
                            borderRadius: localborderRadius,
                            boxShadow: widget.shadow),
                        child: (widget.mentions != null &&
                                widget.mentionKey != null)
                            ? MessageFieldWithMention(
                                defaultText: localController.text,
                                suggestionListHeight:
                                    widget.suggestionListHeight,
                                suggestionListWidth: widget.suggestionListWidth,
                                actions: widget.actions,
                                mentions: widget.mentions,
                                mentionKey: widget.mentionKey,
                                focusNode: widget.focusNode,
                                keyboardType: widget.keyboardType,
                                textCapitalization: widget.textCapitalization,
                                textInputAction: widget.textInputAction,
                                textPadding: widget.textPadding,
                                textStyle: widget.textStyle,
                                textFieldDecoration: widget.textFieldDecoration,
                                leading: widget.leading,
                              )
                            : MessageField(
                                controller: localController,
                                focusNode: widget.focusNode,
                                keyboardType: widget.keyboardType,
                                textCapitalization: widget.textCapitalization,
                                textInputAction: widget.textInputAction,
                                textPadding: widget.textPadding,
                                textStyle: widget.textStyle,
                                decoration: widget.textFieldDecoration,
                                leading: widget.leading,
                                actions: widget.actions,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: composerHeight),
                ],
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: SendButton(
                  composerHeight: composerHeight,
                  onReceiveText: widget.onReceiveText,
                  onPanCancel: widget.onPanCancel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      localController.dispose();
    }
    // if (widget.focusNode != null) widget.focusNode!.dispose();
    super.dispose();
  }
}

class MessageFieldWithMention extends StatefulWidget {
  /// mention global Key
  final GlobalKey<FlutterMentionsState>? mentionKey;

  /// mentions List
  final List<Mention>? mentions;

  /// textPadding
  final EdgeInsetsGeometry? textPadding;

  /// textStyle
  final TextStyle? textStyle;

  /// focusNode
  final FocusNode focusNode;

  /// keyboardType
  final TextInputType? keyboardType;

  /// textCapitalization
  final TextCapitalization? textCapitalization;

  /// textInputAction
  final TextInputAction? textInputAction;

  /// textFieldDecoration
  final InputDecoration? textFieldDecoration;

  /// A widget to display before the [TextField].
  final Widget? leading;

  final List<Widget>? actions;

  final double? suggestionListWidth;
  final double? suggestionListHeight;

  final String? defaultText;

  const MessageFieldWithMention({
    super.key,
    this.mentionKey,
    this.textPadding,
    this.textStyle,
    required this.focusNode,
    this.keyboardType,
    this.defaultText,
    this.textCapitalization,
    this.textInputAction,
    this.actions,
    this.textFieldDecoration,
    this.leading,
    this.mentions,
    this.suggestionListHeight,
    this.suggestionListWidth,
  });

  @override
  State<MessageFieldWithMention> createState() =>
      _MessageFieldWithMentionState();
}

class _MessageFieldWithMentionState extends State<MessageFieldWithMention> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: composerHeight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (widget.leading != null) widget.leading!,
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 160,
              ),
              child: Padding(
                padding: widget.textPadding ??
                    const EdgeInsets.symmetric(horizontal: 8),
                child: FlutterMentions(
                    defaultText: widget.defaultText,
                    suggestionListWidth: widget.suggestionListWidth ?? 300,
                    suggestionListHeight: widget.suggestionListHeight ?? 300,
                    scrollController: ScrollController(),
                    suggestionListDecoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15)),
                    onChanged: (value) {
                      context
                          .read<RecordAudioCubit>()
                          .toggleRecord(canRecord: value.isEmpty);

                      localController.text = value;
                    },
                    style: widget.textStyle,
                    focusNode: widget.focusNode,
                    keyboardType: widget.keyboardType,
                    textCapitalization:
                        widget.textCapitalization ?? TextCapitalization.none,
                    textInputAction: widget.textInputAction,
                    decoration: widget.textFieldDecoration ??
                        const InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText: 'Type your message...'),
                    key: widget.mentionKey,
                    suggestionPosition: SuggestionPosition.Top,
                    maxLines: 50,
                    minLines: 1,
                    mentions: widget.mentions ?? []),
              ),
            ),
          ),
          if (widget.actions != null)
            BlocBuilder<RecordAudioCubit, RecordaudioState>(
              builder: (context, state) {
                if (state is RecordAudioReady) {
                  return Row(
                    children: widget.actions!,
                  );
                }
                return Container();
              },
            ),
          const SizedBox(width: 4)
        ],
      ),
    );
  }
}
