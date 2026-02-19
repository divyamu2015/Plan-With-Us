import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:house_construction_pro/authantication/engineer_auth/eng_reg/bloc/eng_reg_bloc.dart';
import 'package:house_construction_pro/authantication/user_authentication/login_screen/bloc/login_bloc.dart';
import 'package:house_construction_pro/authantication/user_authentication/registration_screen/bloc/register_bloc_bloc.dart';
import 'package:house_construction_pro/front_screen/splash_screen.dart';
import 'package:house_construction_pro/screen/engineer_screen/eng_profile_management/bloc/eng_profile_bloc.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_pro_bio/bloc/engineer_bio_bloc.dart';
import 'package:house_construction_pro/screen/user_screen/house_details/bloc/property_input_bloc.dart';
import 'package:house_construction_pro/screen/user_screen/request_view/bloc/request_bloc.dart';
import 'package:house_construction_pro/screen/user_screen/view_engineers/bloc/view_engineers_bloc.dart';

//import 'screen/3d_image/3d_image_widget.dart' show HomePageView;
//import 'package:house_construction_pro/front_screen/splash_screen.dart';
//import 'package:house_construction_pro/screen/house_details/property_input_view.dart';

void main() {
   WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext t) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RegisterBlocBloc()),
        BlocProvider(create: (context) => LoginBloc()),
        BlocProvider(create: (context) => PropertyInputBloc()),
        BlocProvider(create: (context) => EngRegBloc()),
        BlocProvider(create: (context) => EngProfileBloc()),
        BlocProvider(create: (context) => EngineerBioBloc()),
        BlocProvider(create: (context) => RequestBloc()),
        BlocProvider(create: (context) => ViewEngineersBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dream House',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home:
            //MyHomePage(),
            // RoleSelectionScreen(),
            // LoginScreen()
            //PropertyInputPage(),
            SplashScreen(),
        //  HomePageView(),
      ),
    );
  }
}
