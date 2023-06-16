import 'package:flutter/material.dart';
import 'package:paigun/provider/passenger.dart';
import 'package:provider/provider.dart';

import '../../function/show_snackbar.dart';
import '../../provider/userinfo.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );
  bool _redirectCalled = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_redirectCalled && mounted) {
        _redirect();
      }
    });
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }

    _redirectCalled = true;
    final session = supabase.auth.currentSession;
    await Provider.of<UserInfo>(context, listen: false).getUserInfo();
    if (session != null) {
      // Provider.of<PassDB>(context, listen: false).getJourney(5);
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
