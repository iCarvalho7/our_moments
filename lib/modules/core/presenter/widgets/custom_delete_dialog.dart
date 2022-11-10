import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDeleteDialog extends StatefulWidget {
  const CustomDeleteDialog({
    required this.text,
    required this.onTapPositive,
    Key? key,
  }) : super(key: key);

  final String text;
  final VoidCallback onTapPositive;

  @override
  State<CustomDeleteDialog> createState() => _CustomDeleteDialogState();

  static void show(
    BuildContext parentContext, {
    required String text,
    required VoidCallback onTapPositive,
  }) {
    showDialog(
      context: parentContext,
      builder: (context) {
        return CustomDeleteDialog(
          text: text,
          onTapPositive: onTapPositive,
        );
      },
    );
  }
}

class _CustomDeleteDialogState extends State<CustomDeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.delete,
            color: Colors.red,
            size: 50,
          ),
          const SizedBox(height: 10),
          Text(widget.text, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateColor.resolveWith((_) => Colors.red),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Não'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateColor.resolveWith((_) => Colors.white),
                  ),
                  onPressed: widget.onTapPositive,
                  child: const Text(
                    'Sim',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
