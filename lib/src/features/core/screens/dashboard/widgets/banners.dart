import 'package:flutter/material.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/image_strings.dart';
import '../../../../../constants/text_strings.dart';
import 'package:login_flutter_app/src/constants/sizes.dart';
import '../widgets/colorspage.dart';
import '../widgets/shapespage.dart';
import '../widgets/personpage.dart';
import '../widgets/housepage.dart';
import '../widgets/schoolpage.dart';
import '../widgets/functionalpage.dart';
import '../widgets/addobjectpage.dart';

class DashboardBanners extends StatelessWidget {
  const DashboardBanners({
    Key? key,
    required this.txtTheme,
    required this.isDark,
  }) : super(key: key);

  final TextTheme txtTheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //1st banner
        //2nd Banner
        Expanded(
          child: Column(
            children: [
              //Card
              InkWell(
                onTap: () {
              // Handle Assessment button click
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ColorsPage()),
              );
                },
                child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                  //For Dark Color
                  color: isDark ? tSecondaryColor : tCardBgColor,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        //Flexible(child: Image(image: AssetImage(tBookmarkIcon))),
                        Flexible(child: Image(image: AssetImage(tBannerImage1))),
                      ],
                    ),
                    Text(tDashboardBannerSubTitle, style: txtTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                    Text(tDashboardBannerTitle1, style: txtTheme.headlineMedium, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),),
              const SizedBox(height: 5),
              
              InkWell(
                onTap: () {
              // Handle Assessment button click
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PersonPage()),
              );
                },
                child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                  //For Dark Color
                  color: isDark ? tSecondaryColor : tCardBgColor,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        //Flexible(child: Image(image: AssetImage(tBookmarkIcon))),
                        Flexible(child: Image(image: AssetImage(tBannerImage3))),
                      ],
                    ),
                    Text(tDashboardBannerSubTitle, style: txtTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                    Text(tDashboardBannerTitle3, style: txtTheme.headlineMedium, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),),
              const SizedBox(height: 5),
              
              InkWell(
                onTap: () {
              // Handle Assessment button click
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SchoolPage()),
              );
                },
                child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                  //For Dark Color
                  color: isDark ? tSecondaryColor : tCardBgColor,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        //Flexible(child: Image(image: AssetImage(tBookmarkIcon))),
                        Flexible(child: Image(image: AssetImage(tBannerImage5))),
                      ],
                    ),
                    Text(tDashboardBannerSubTitle, style: txtTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                    Text(tDashboardBannerTitle5, style: txtTheme.headlineMedium, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),),
            ],
          ),
        ),
        const SizedBox(width: tDashboardCardPadding),
        //2nd Banner
        Expanded(
          child: Column(
            children: [
              //Card
              InkWell(
                onTap: () {
              // Handle Assessment button click
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShapesPage()),
              );
                },
                child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                  //For Dark Color
                  color: isDark ? tSecondaryColor : tCardBgColor,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        //Flexible(child: Image(image: AssetImage(tBookmarkIcon))),
                        Flexible(child: Image(image: AssetImage(tBannerImage2))),
                      ],
                    ),
                    Text(tDashboardBannerSubTitle, style: txtTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                    Text(tDashboardBannerTitle2, style: txtTheme.headlineMedium, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),),
              const SizedBox(height: 5),
              
              InkWell(
                onTap: () {
                  Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FunctionalPage()),
              );
                },
                child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                  //For Dark Color
                  color: isDark ? tSecondaryColor : tCardBgColor,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        //Flexible(child: Image(image: AssetImage(tBookmarkIcon))),
                        Flexible(child: Image(image: AssetImage(tBannerImage4))),
                      ],
                    ),
                    Text(tDashboardBannerSubTitle4, style: txtTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                    Text(tDashboardBannerTitle4, style: txtTheme.headlineMedium, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),),
              const SizedBox(height: 5),
              
              InkWell(
                onTap: () {
              // Handle Assessment button click
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HousePage()),
              );
                },
                child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                  //For Dark Color
                  color: isDark ? tSecondaryColor : tCardBgColor,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        //Flexible(child: Image(image: AssetImage(tBookmarkIcon))),
                        Flexible(child: Image(image: AssetImage(tBannerImage6))),
                      ],
                    ),
                    Text(tDashboardBannerSubTitle, style: txtTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                    Text(tDashboardBannerTitle6, style: txtTheme.headlineMedium, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    ),
    //
   SizedBox(
            width: 320,
            height: 100,
            child: Padding(
              padding: const EdgeInsets.only(right: 10, top: 5),
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                  //For Dark Color
                  color: isDark ? tSecondaryColor : tCardBgColor,
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                onTap: () {
              // Handle Assessment button click
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddObjectPage()),
              );
                },
                child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: 
                          Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    Text(tDashboardBannerTitle7, style: txtTheme.headlineMedium, overflow: TextOverflow.ellipsis),
                          ],
                        )
                        ),
                        Flexible(child: Image(image: AssetImage(tBannerImage7))),
                      ],
                    ),),
                    
                  ],
                ),
              ),
            ),
          ),
  ]
    );
  }
}
