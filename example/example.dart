import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_password_generator/src/safe_password_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PasswordGeneratorScreen(),
    );
  }
}

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final passwordCharacterController = TextEditingController();
  bool includeUppercase = false;
  bool includeLowercase = false;
  bool includeNumber = false;
  bool includeSymbol = false;

  double progress = 0;
  String generatedPassword = '';

  @override
  dispose() {
    super.dispose();
    passwordCharacterController.dispose();
  }

  bool isAnyCheckboxSelected() {
    return includeUppercase ||
        includeLowercase ||
        includeNumber ||
        includeSymbol;
  }

  Color passwordStrengthColor(double strength) {
    if (strength < 40) {
      return Colors.red;
    } else if (strength >= 40 && strength < 60) {
      return Colors.orange;
    } else if (strength >= 60 && strength < 80) {
      return Colors.lightGreen;
    } else if (strength >= 80) {
      return Colors.green;
    } else {
      return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Password Generator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextField(
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 16, color: Colors.black),
                controller: passwordCharacterController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black)),
                  hintText: 'Enter password length',
                ),
              ),
              const SizedBox(height: 10),
              PasswordTypeWidget(
                title: 'Include uppercase',
                currentState: includeUppercase,
                onChanged: (value) {
                  setState(() {
                    includeUppercase = value!;
                  });
                },
              ),
              PasswordTypeWidget(
                title: 'Include lowercase',
                currentState: includeLowercase,
                onChanged: (value) {
                  setState(() {
                    includeLowercase = value!;
                  });
                },
              ),
              PasswordTypeWidget(
                title: 'Include numbers',
                currentState: includeNumber,
                onChanged: (value) {
                  setState(() {
                    includeNumber = value!;
                  });
                },
              ),
              PasswordTypeWidget(
                title: 'Include symbol',
                currentState: includeSymbol,
                onChanged: (value) {
                  setState(() {
                    includeSymbol = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !isAnyCheckboxSelected() ? null : Colors.blue,
                      ),
                      onPressed: !isAnyCheckboxSelected()
                          ? null
                          : () {
                              if (passwordCharacterController.text.isEmpty) {
                                SnackBarUtils.snackBar(
                                    context, 'Please enter  password length');
                                return;
                              }
                              final length = int.tryParse(
                                      passwordCharacterController.text) ??
                                  0;

                              if (length <= 0) {
                                SnackBarUtils.snackBar(context,
                                    'Please enter a valid password length');
                                return;
                              }

                              final generatePassword =
                                  SafePasswordGenerator.generatePassword(
                                      length: length,
                                      includeUppercase: includeUppercase,
                                      includeLowercase: includeLowercase,
                                      includeNumbers: includeNumber,
                                      includeSpecialCharacters: includeSymbol);

                              setState(() {
                                generatedPassword = generatePassword;
                                progress = SafePasswordGenerator
                                    .calculatePasswordStrength(
                                        generatePassword);
                              });
                            },
                      child: Text('Generate',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: !isAnyCheckboxSelected()
                                      ? Colors.grey
                                      : null)))),
              const SizedBox(height: 8),
              CopyAbleText(text: generatedPassword),
              const SizedBox(height: 12),
              Text('Password Strength',
                  style: Theme.of(context).textTheme.bodySmall),
              LinearTracker(
                progress: progress,
                color: passwordStrengthColor(progress),
                height: 10,
              ),
              const SizedBox(height: 5),
              Text(
                SafePasswordGenerator.getStrengthLabel(progress),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 15,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordTypeWidget extends StatelessWidget {
  final bool currentState;
  final void Function(bool?)? onChanged;
  final String title;

  const PasswordTypeWidget({
    super.key,
    required this.currentState,
    this.onChanged,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onChanged != null) {
          onChanged!(!currentState);
        }
      },
      child: Row(
        children: [
          Checkbox(
            value: currentState,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  )),
        ],
      ),
    );
  }
}

class SnackBarUtils {
  static void snackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
      )),
    );
  }
}

class CopyAbleText extends StatelessWidget {
  final String text;

  const CopyAbleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(text, style: const TextStyle(fontSize: 18)))),
        const SizedBox(width: 9),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: text.isEmpty ? Colors.grey : Colors.blue),
          onPressed: text.isEmpty
              ? null
              : () async {
                  await Clipboard.setData(ClipboardData(text: text));
                  SnackBarUtils.snackBar(context, '$text copied to clipboard');
                },
          child: Text(
            'Copy',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: text.isEmpty ? Colors.grey : null,
                ),
          ),
        ),
      ],
    );
  }
}

class LinearTracker extends StatefulWidget {
  final double progress;
  final Color? color;
  final bool shouldShowLabel;
  final double height;

  const LinearTracker({
    super.key,
    required this.progress,
    this.color,
    this.shouldShowLabel = false,
    required this.height,
  });

  @override
  State<LinearTracker> createState() => _LinearTrackerState();
}

class _LinearTrackerState extends State<LinearTracker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant LinearTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.shouldShowLabel)
          AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${_animation.value.round()}%',
                      style: Theme.of(context).textTheme.bodySmall),
                );
              }),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),
            // Progress
            AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (_animation.value / 100).clamp(0.0, 1.0),
                      child: Container(
                        height: widget.height,
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius:
                              BorderRadius.circular(widget.height / 2),
                        ),
                      ),
                    ),
                  );
                }),
            // Optional centered label
            if (widget.shouldShowLabel)
              Text(
                '${widget.progress.round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        )
      ],
    );
  }
}
