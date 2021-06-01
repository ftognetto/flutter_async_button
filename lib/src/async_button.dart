import 'package:flutter/material.dart';

enum AsyncButtonType {
  ICON,
  ELEVATED,
  TEXT,
  OUTLINE
}

class AsyncButton extends StatefulWidget {

  /// Can be IconButton, RaisedButton, FlatButton or OutlinedButton
  final AsyncButtonType type;

  /// In case of IconButton
  final Widget? icon;

  /// In case of IconButton. If null [CenterLoading] is rendered
  final Widget? busyIcon;

  /// The text of the button
  final Text? text;

  /// The color of the button
  final Color color;

  /// The color of the loading circle while button is busy
  final Color? loadingColor;

  /// The color of the background while button is busy
  final Color? loadingBackgroundColor;

  /// The border radius of the button
  final BorderRadius? borderRadius;

  /// The elevation of the elevated button
  final double? elevation;

  final AsyncStatus Function()? busyBuilder;

  final Future<void> Function()? onPressed;

  const AsyncButton.icon({ required this.icon, this.busyIcon, this.onPressed, this.color = Colors.grey, this.loadingColor, this.loadingBackgroundColor = Colors.grey, this.busyBuilder, Key? key}) : 
    type = AsyncButtonType.ICON,
    text = null,
    borderRadius = null,
    elevation = 0,
    assert(icon != null),
    super(key: key);

  const AsyncButton.elevatedButton({required this.text, this.onPressed, this.color = Colors.grey, this.borderRadius = BorderRadius.zero, this.loadingColor, this.loadingBackgroundColor = Colors.grey, this.elevation, this.busyBuilder, Key? key}):
    type = AsyncButtonType.ELEVATED,
    icon = null,
    busyIcon = null,
    assert(text != null),
    super(key: key);

  const AsyncButton.outlineButton({required this.text, this.onPressed, this.color = Colors.grey, this.borderRadius = BorderRadius.zero, this.loadingColor, this.loadingBackgroundColor = Colors.grey, this.busyBuilder, Key? key}):
    type = AsyncButtonType.OUTLINE,
    icon = null,
    busyIcon = null,
    elevation = 0,
    assert(text != null),
    super(key: key);
  
  const AsyncButton.textButton({required this.text, this.onPressed, this.color = Colors.grey, this.loadingColor, this.loadingBackgroundColor = Colors.grey, this.busyBuilder, Key? key}):
    type = AsyncButtonType.TEXT,
    icon = null,
    busyIcon = null,
    borderRadius = null,
    elevation = 0,
    assert(text != null),
    super(key: key);

  @override
  _AsyncButtonState createState() => _AsyncButtonState();
}

enum AsyncStatus { IDLE, BUSY, SUCCESS, FAILURE }

class _AsyncButtonState extends State<AsyncButton> {

  AsyncStatus _status = AsyncStatus.IDLE;

  @override
  Widget build(BuildContext context) {

    final status = (widget.busyBuilder != null) ? widget.busyBuilder!() : _status;

    switch (widget.type) {
      case AsyncButtonType.ICON:
        return IconButton(
          icon: _buttonChild(status),
          onPressed: _onPressed
        );
      case AsyncButtonType.ELEVATED:
        return ElevatedButton(
          child: _buttonChild(status),
          style: ElevatedButton.styleFrom(
            shape: widget.borderRadius != null ? RoundedRectangleBorder(borderRadius: widget.borderRadius!) : RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            primary: _status == AsyncStatus.IDLE ? widget.color : widget.loadingBackgroundColor,
            elevation: widget.elevation ?? 2
          ),
          onPressed: _onPressed
        );
      case AsyncButtonType.TEXT:
        return TextButton(
          child: _buttonChild(status),
          style: TextButton.styleFrom(textStyle: TextStyle(color: widget.color)),
          onPressed: _onPressed
        );
      case AsyncButtonType.OUTLINE:
        return OutlinedButton(
          child: _buttonChild(status),
          style: OutlinedButton.styleFrom(
            //backgroundColor: widget.color,
            textStyle: TextStyle(color: widget.color)
          ),
          onPressed: _onPressed
        );
    }
  }

  Widget _buttonChild(AsyncStatus status) {
    switch (status) {
      case AsyncStatus.BUSY: return _Loading(color: widget.loadingColor ?? widget.color,);
      case AsyncStatus.SUCCESS: return _Success(color: widget.loadingColor ?? widget.color);
      case AsyncStatus.FAILURE: return _Failure(color: widget.loadingColor ?? widget.color);
      case AsyncStatus.IDLE: return widget.text!;
    }
  }

  void _onPressed() {
    if (widget.onPressed == null) return;
    if (_status != AsyncStatus.IDLE) return;
    setState(() { _status = AsyncStatus.BUSY; });
    widget.onPressed!().then((_){
      setState((){ _status = AsyncStatus.SUCCESS; });
    }).catchError((_){
      setState(() { _status = AsyncStatus.FAILURE; });
    }).whenComplete(() {
      Future.delayed(Duration(seconds: 2), () { setState((){ _status = AsyncStatus.IDLE; }); }) ;
    }); 
  }
}


class _Loading extends StatelessWidget {

  final Color? color;

  const _Loading({Key? key, this.color }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _color = color ?? Theme.of(context).accentColor;
    Widget loading = SizedBox(
      width: 33,
      height: 33,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          )
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
    final _color = color ?? Theme.of(context).accentColor;
    // Widget loading = SizedBox(
    //   width: 33,
    //   height: 33,
    //   child: Padding(
    //     padding: EdgeInsets.all(8),
    //     child: Icon(Icons.check, color: _color)
    //   )
    // );
    // loading = Center(
    //   child: loading
    // );
    return Icon(Icons.check, color: _color);
  }
}

class _Failure extends StatelessWidget {

  final Color? color;

  const _Failure({Key? key, this.color }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _color = color ?? Theme.of(context).accentColor;
    // Widget loading = SizedBox(
    //   width: 33,
    //   height: 33,
    //   child: Padding(
    //     padding: EdgeInsets.all(8),
    //     child: Icon(Icons.close, color: _color)
    //   )
    // );
    // loading = Center(
    //   child: loading
    // );
    return Icon(Icons.close, color: _color);
  }
}