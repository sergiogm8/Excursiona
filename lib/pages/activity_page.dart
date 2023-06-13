import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/widgets/activity_lists.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    border: Border(
                  bottom: BorderSide(color: Colors.grey),
                )),
                child: TabBar(
                  isScrollable: false,
                  splashBorderRadius: BorderRadius.circular(10.0),
                  indicatorWeight: 2.0,
                  indicatorColor: Constants.indigoDye,
                  labelColor: Colors.black,
                  labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                      letterSpacing: 0.3),
                  tabs: const [
                    Tab(text: 'Mi actividad'),
                    Tab(text: 'Comunidad'),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    MyActivity(),
                    CommunityActivity(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
