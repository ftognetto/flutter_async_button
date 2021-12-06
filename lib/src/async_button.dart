import 'package:flutter/material.dart';

enum AsyncButtonType {
  icon,
  elevated,
  text,
  textIcon,
  outlined
}

class AsyncButton extends StatefulWidget {

  /// Can be IconButton, RaisedButton, FlatButton or OutlinedButton
  final AsyncButtonType type;



  // /// In case of IconButton. If null [CenterLoading] is rendered
  // final Widget? busyIcon;

  /// The child of the button, usually [Text] for [ElevatedButton] [TextButton] or [OutlinedButton] and [Icon] for [IconButton]
  final Widget? child;

  final Widget Function(AsyncStatus)? childBuilder;

  /// The color of the loading circle while button is busy
  final Color? loadingColor;

  /// The color of the background while button is busy
  final Color? loadingBackgroundColor;

  final ButtonStyle? style;

  /// Only for [TextIconButton]
  final Widget? label;


  final Future<void> Function()? onPressed;

  const AsyncButton.icon({ this.child, this.style, this.onPressed, this.loadingColor, this.loadingBackgroundColor, this.childBuilder, Key? key}) : 
    assert(child != null || childBuilder != null),
    type = AsyncButtonType.icon,
    label = null,
    super(key: key);

  const AsyncButton.elevatedButton({ this.child, this.style, this.onPressed, this.loadingColor, this.loadingBackgroundColor,  this.childBuilder, Key? key}):
    assert(child != null || childBuilder != null),
    type = AsyncButtonType.elevated,
    label = null,
    super(key: key);

  const AsyncButton.outlineButton({ this.child, this.style, this.onPressed, this.loadingColor, this.loadingBackgroundColor, this.childBuilder, Key? key}):
    assert(child != null || childBuilder != null),
    type = AsyncButtonType.outlined,
    label = null,
    super(key: key);
  
  const AsyncButton.textButton({ this.child, this.style, this.onPressed, this.loadingColor, this.loadingBackgroundColor, this.childBuilder, Key? key}):
    assert(child != null || childBuilder != null),
    type = AsyncButtonType.text,
    label = null,
    super(key: key);

  const AsyncButton.textIconButton({required this.label, this.child, this.style, this.onPressed, this.loadingColor, this.loadingBackgroundColor, this.childBuilder, Key? key}):
    assert(child != null || childBuilder != null),
    type = AsyncButtonType.textIcon,
    super(key: key);

  @override
  _AsyncButtonState createState() => _AsyncButtonState();
}

enum AsyncStatus { idle, busy, success, failure }

class _AsyncButtonState extends State<AsyncButton> {

  AsyncStatus _status = AsyncStatus.idle;

  @override
  Widget build(BuildContext context) {


    switch (widget.type) {
      case AsyncButtonType.icon:
        return IconButton(
          icon: widget.childBuilder != null ? widget.childBuilder!(_status) : _iconButtonChild(_status),
          onPressed: _onPressed
        );
      case AsyncButtonType.elevated:
        var style = widget.style ?? ElevatedButton.styleFrom();
        if (_status != AsyncStatus.idle) { style = style.copyWith(backgroundColor: MaterialStateProperty.all<Color>(widget.loadingBackgroundColor ?? Theme.of(context).primaryColor)); }
        return ElevatedButton(
          child: widget.childBuilder != null ? widget.childBuilder!(_status) : _elevatedButtonChild(_status),
          style: style,
          onPressed: _onPressed
        );
      case AsyncButtonType.text:
        return TextButton(
          child: widget.childBuilder != null ? widget.childBuilder!(_status) : _textButtonChild(_status),
          style: widget.style ?? TextButton.styleFrom(),
          onPressed: _onPressed
        );
      case AsyncButtonType.textIcon:
        return TextButton.icon(
          label: widget.label!,
          icon: widget.childBuilder != null ? widget.childBuilder!(_status) : _iconButtonChild(_status),
          style: widget.style ?? TextButton.styleFrom(),
          onPressed: _onPressed
        );
      case AsyncButtonType.outlined:
        return OutlinedButton(
          child: widget.childBuilder != null ? widget.childBuilder!(_status) : _outlinedButtonChild(_status),
          style: widget.style ?? OutlinedButton.styleFrom(),
          onPressed: _onPressed
        );
    }
  }

  Widget _outlinedButtonChild(AsyncStatus status) {
    switch (status) {
      case AsyncStatus.busy: return _Loading(color: widget.loadingColor ?? Theme.of(context).colorScheme.secondary);
      case AsyncStatus.success: return _Success(color: widget.loadingColor ?? Theme.of(context).colorScheme.secondary);
      case AsyncStatus.failure: return _Failure(color: widget.loadingColor ?? Theme.of(context).colorScheme.secondary);
      case AsyncStatus.idle: return widget.child!;
    }
  }

  Widget _iconButtonChild(AsyncStatus status) {
    switch (status) {
      case AsyncStatus.busy: return _Loading(color: widget.loadingColor ?? Theme.of(context).colorScheme.secondary);
      case AsyncStatus.success: return _Success(color: widget.loadingColor ?? Theme.of(context).colorScheme.secondary);
      case AsyncStatus.failure: return _Failure(color: widget.loadingColor ?? Theme.of(context).colorScheme.secondary);
      case AsyncStatus.idle: return widget.child!;
    }
  }

  Widget _elevatedButtonChild(AsyncStatus status) {
    switch (status) {
      case AsyncStatus.busy: return _Loading(color: widget.loadingColor ?? Theme.of(context).colorScheme.secondary);
      case AsyncStatus.success: return _Success(color: widget.loadingColor ?? Theme.of(context).colorScheme.secondary);
      case AsyncStatus.failure: return _Failure(color: widget.loadingColor ?? Theme.of(context).colorScheme.secondary);
      case AsyncStatus.idle: return widget.child!;
    }
  }

  Widget _textButtonChild(AsyncStatus status) {
    switch (status) {
      case AsyncStatus.busy: return _Loading(color: widget.loadingColor ?? Theme.of(context).colorScheme.primary);
      case AsyncStatus.success: return _Success(color: widget.loadingColor ?? Theme.of(context).colorScheme.primary);
      case AsyncStatus.failure: return _Failure(color: widget.loadingColor ?? Theme.of(context).colorScheme.primary);
      case AsyncStatus.idle: return widget.child!;
    }
  }

  void _onPressed() {
    if (widget.onPressed == null) return;
    if (_status != AsyncStatus.idle) return;
    setState(() { _status = AsyncStatus.busy; });
    widget.onPressed!().then((_){
      if (mounted) { setState((){ _status = AsyncStatus.success; }); }
    }).catchError((_){
      if (mounted) { setState(() { _status = AsyncStatus.failure; }); }
    }).whenComplete(() {
      Future.delayed(const Duration(seconds: 2), () { if (mounted) { setState((){ _status = AsyncStatus.idle; }); } }) ;
    }); 
  }
}


class _Loading extends StatelessWidget {

  final Color color;

  const _Loading({Key? key, required this.color }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget loading = SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      )
      
    );
    loading = Center(
      child: loading
    );
    return loading;
  }
}

class _Success extends StatelessWidget {

  final Color? color;

  const _Success({Key? key, this.color }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _color = color ?? Theme.of(context).colorScheme.secondary;
    return Icon(Icons.check, color: _color);
  }
}

class _Failure extends StatelessWidget {

  final Color? color;

  const _Failure({Key? key, this.color }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _color = color ?? Theme.of(context).colorScheme.secondary;
    return Icon(Icons.close, color: _color);
  }
}