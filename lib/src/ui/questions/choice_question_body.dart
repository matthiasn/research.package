part of '../../../ui.dart';

/// The UI representation of [RPChoiceAnswerFormat]. This UI part appears embedded in a [RPUIQuestionStep].
/// Depending on the [RPChoiceAnswerFormat]'s [ChoiceAnswerStyle] property, the user can select only one or multiple options.
class RPUIChoiceQuestionBody extends StatefulWidget {
  final RPChoiceAnswerFormat answerFormat;
  final void Function(dynamic) onResultChange;

  const RPUIChoiceQuestionBody(
    this.answerFormat,
    this.onResultChange, {
    super.key,
  });

  @override
  RPUIChoiceQuestionBodyState createState() => RPUIChoiceQuestionBodyState();
}

class RPUIChoiceQuestionBodyState extends State<RPUIChoiceQuestionBody>
    with AutomaticKeepAliveClientMixin<RPUIChoiceQuestionBody> {
  List<RPChoice> selectedChoices = [];

  @override
  void initState() {
    super.initState();
    selectedChoices = [];
  }

  void _buttonCallBack(RPChoice selectedChoice) {
    if (widget.answerFormat.answerStyle == RPChoiceAnswerStyle.SingleChoice) {
      // Setting the state here is calling the build method so the check marks can be rendered.
      // Only one choice can be selected.
      if (selectedChoices.contains(selectedChoice)) {
        setState(() {
          selectedChoices.remove(selectedChoice);
        });
      } else {
        setState(() {
          selectedChoices = [];
          selectedChoices.add(selectedChoice);
        });
      }
    }
    if (widget.answerFormat.answerStyle == RPChoiceAnswerStyle.MultipleChoice) {
      // Setting the state here is calling the build method so the check marks can be rendered.
      // Multiple choice can be selected.
      if (selectedChoices.contains(selectedChoice)) {
        setState(() {
          selectedChoices.remove(selectedChoice);
        });
      } else {
        setState(() {
          selectedChoices.add(selectedChoice);
        });
      }
    }

    selectedChoices.isNotEmpty
        ? widget.onResultChange(selectedChoices)
        : widget.onResultChange(null);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    RPLocalizations? locale = RPLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.answerFormat.answerStyle ==
            RPChoiceAnswerStyle.MultipleChoice)
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text((widget.answerFormat.answerStyle ==
                      RPChoiceAnswerStyle.MultipleChoice)
                  ? "(${locale?.translate('choose_one_or_more_options') ?? 'Choose one or more options'})"
                  : "(${locale?.translate('choose_one_option') ?? 'Choose one option'})")),
        ...widget.answerFormat.choices.map((choice) {
          return _ChoiceButton(
            choice: choice,
            selectedCallBack: _buttonCallBack,
            selected: selectedChoices.contains(choice),
            currentChoices: selectedChoices,
            index: widget.answerFormat.choices.indexOf(choice),
            isLastChoice: widget.answerFormat.choices.indexOf(choice) ==
                widget.answerFormat.choices.length - 1,
            answerStyle: widget.answerFormat.answerStyle,
          );
        }),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ChoiceButton extends StatefulWidget {
  final RPChoice choice;
  final Function selectedCallBack;
  final List<RPChoice> currentChoices;
  final bool selected;
  final bool isLastChoice;
  final int index;
  final RPChoiceAnswerStyle answerStyle;

  const _ChoiceButton(
      {required this.choice,
      required this.selectedCallBack,
      required this.currentChoices,
      required this.index,
      required this.answerStyle,
      required this.selected,
      required this.isLastChoice});

  @override
  _ChoiceButtonState createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<_ChoiceButton> {
  RPChoice? grpChoice;
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    grpChoice = widget.selected ? widget.choice : null;
    RPLocalizations? locale = RPLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: InkWell(
        onTap: () => widget.selectedCallBack(widget.choice),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          (widget.answerStyle == RPChoiceAnswerStyle.SingleChoice)
              ? Radio(
                  value: widget.choice,
                  groupValue: grpChoice,
                  onChanged: (x) => widget.selectedCallBack(widget.choice),

                  /// If the CupertinoTheme is in use, the primary color won't be the default one.
                  /// In that case we use the CupertinoTheme primary color here, to match the rest of the app.
                  activeColor: (CupertinoTheme.of(context).primaryColor ==
                          CupertinoColors.activeBlue)
                      ? Theme.of(context).primaryColor
                      : CupertinoTheme.of(context).primaryColor)
              : Checkbox(
                  value: widget.selected,
                  onChanged: (x) => widget.selectedCallBack(widget.choice),
                  activeColor: (CupertinoTheme.of(context).primaryColor ==
                          CupertinoColors.activeBlue)
                      ? Theme.of(context).primaryColor
                      : CupertinoTheme.of(context).primaryColor,
                ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: widget.choice.isFreeText
                  ? null
                  : const EdgeInsets.symmetric(vertical: 16),
              child: widget.choice.isFreeText
                  ? TextField(
                      onChanged: (newText) => widget.choice.text = newText,
                      decoration: InputDecoration(
                        hintText: locale?.translate(widget.choice.text) ??
                            widget.choice.text,
                      ),
                    )
                  : Text(
                      locale?.translate(widget.choice.text) ??
                          widget.choice.text,
                      style: Theme.of(context).textTheme.bodyMedium,
                      softWrap: true,
                    ),
            ),
          ),
          if (widget.choice.detailText != null)
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<dynamic>(
                      builder: (context) => _DetailTextRoute(
                        title: widget.choice.text,
                        content: widget.choice.detailText!,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.info))
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
