import 'package:athlo/presentation/main_navigation.dart';
import 'package:athlo/presentation/pages/register_page.dart';
import 'package:athlo/presentation/widgets/app_loading.dart';
import 'package:athlo/data/services/auth_service.dart';
import 'package:flutter/cupertino.dart';

class AuthLayout extends StatelessWidget{
  const AuthLayout({
    super.key,
    this.pageIfNotConnected,
});

final Widget? pageIfNotConnected;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: authService, builder: (context, authService, child){
      return StreamBuilder(stream: authService.authStateChanges, builder: (context, snapshot){
        Widget widget;
        if(snapshot.connectionState == ConnectionState.waiting){
          widget = AppLoading();
        }
        else if (snapshot.hasData){
          widget = const MainNavigation();
        } else{
          widget = pageIfNotConnected ?? const RegisterPage();
        }
        return widget;
      });
    });
  }}