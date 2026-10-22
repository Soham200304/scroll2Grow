import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:scrool2grow/app/routes/AppRoutes.dart';
import 'package:scrool2grow/app/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';

class OnboardingIntroView extends StatelessWidget {
  const OnboardingIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFF7FAF5),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 45.0),
            child: Center(
              child: Text(
                'Scroll2Grow',
                style: GoogleFonts.aboreto(fontSize: 38, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 50.0,),
          Lottie.asset(
            'assets/animations/no_bg_gworing.json',
            repeat: true,
            animate: true,
          ),
          const SizedBox(height: 50.0,),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Don\'t Just Stop ', style: GoogleFonts.abel(fontSize: 20, fontWeight: FontWeight.w600,),),
                    Text('Scrolling.', style: GoogleFonts.abel(fontSize: 24, fontWeight: FontWeight.bold,  color: Colors.redAccent),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Start ', style:  GoogleFonts.abel(fontSize: 20, fontWeight: FontWeight.w600),),
                    Text('Growing !!', style:  GoogleFonts.abel(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24.0,),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            child: Text(
              ' Turn unproductive scrolling into meaningful activities,goals, and personal growth.',
              style: GoogleFonts.abel(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0,),
            child: SlideAction(
              innerColor: AppColors.primaryLight,
              outerColor: AppColors.leafGreen,
              text: "Let's Get Started!",
              sliderButtonIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.surfaceMint,
              ),
              textStyle: GoogleFonts.abel(
                fontSize: 20,
                color: AppColors.surfaceMint,
              ),
              onSubmit: () async {
                final prefs = await SharedPreferences.getInstance();

                await prefs.setBool('introCompleted', true);

                if (!context.mounted) return;

                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.login,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
