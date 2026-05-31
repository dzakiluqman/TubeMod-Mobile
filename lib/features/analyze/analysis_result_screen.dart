import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_bottom_navbar.dart';
import '../../services/youtube_service.dart';

class AnalysisResultScreen extends StatefulWidget {

  final String videoId;

  const AnalysisResultScreen({
    Key? key,
    required this.videoId,
  }) : super(key: key);

  @override
  State<AnalysisResultScreen> createState() =>
      _AnalysisResultScreenState();
}

class _AnalysisResultScreenState
    extends State<AnalysisResultScreen> {

  int _selectedIndex = 0;

  bool isLoading = true;

  final YouTubeService _youtubeService =
      YouTubeService();

  List<Map<String, dynamic>> toxicComments = [];

  @override
  void initState() {
    super.initState();

    _loadComments();
  }

  Future<void> _loadComments() async {

    try {

      final comments =
          await _youtubeService.fetchComments(
        widget.videoId,
      );

      setState(() {

        toxicComments = comments.map((comment) {

          return {
            ...comment,
            'type': 'comment',
          };

        }).toList();

        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      debugPrint(
        'ERROR LOAD COMMENTS: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,

      body: SafeArea(
        child: Column(
          children: [

            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPurple,
                    AppColors.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),

              child: Padding(
                padding: const EdgeInsets.all(24.0),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        Row(
                          children: [

                            Container(
                              width: 32,
                              height: 32,

                              decoration: BoxDecoration(
                                color:
                                    AppColors.textWhite,

                                borderRadius:
                                    BorderRadius.circular(6),
                              ),

                              child: Center(
                                child: Text(
                                  'T',

                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.bold,

                                    color:
                                        AppColors.primaryPurple,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Text(
                              'TubeMod',

                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,

                                color:
                                    AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.menu,

                            color:
                                AppColors.iconWhite,

                            size: 28,
                          ),

                          onPressed: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'One tool to manage toxic comments in your YouTube channels.',

                      style:
                          AppTextStyle.heading1
                              .copyWith(
                        fontSize: 24,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24.0,
              ),

              child: Text(
                'Analysis Result',

                style:
                    AppTextStyle.heading2,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading

                  ? const Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            AppColors.primaryPurple,
                      ),
                    )

                  : toxicComments.isEmpty

                      ? const Center(
                          child: Text(
                            'No toxic comments detected',
                          ),
                        )

                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),

                          itemCount:
                              toxicComments.length,

                          itemBuilder:
                              (context, index) {

                            final comment =
                                toxicComments[index];

                            return Container(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),

                              padding:
                                  const EdgeInsets.all(20),

                              decoration:
                                  BoxDecoration(
                                color:
                                    AppColors.primaryDark,

                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                              ),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,

                                    children: [

                                      Expanded(
                                        child: Text(
                                          comment['username'],

                                          style:
                                              AppTextStyle
                                                  .cardTitle
                                                  .copyWith(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),

                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              Colors.red,

                                          borderRadius:
                                              BorderRadius.circular(
                                            20,
                                          ),
                                        ),

                                        child: Text(
                                          comment['type'],

                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.white,

                                            fontSize: 10,

                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    comment['comment'],

                                    style:
                                        AppTextStyle
                                            .cardSubtitle
                                            .copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),

              child: PrimaryButton(
                text:
                    'Delete all sensitive comments',

                onPressed: () {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Delete feature coming soon',
                      ),
                    ),
                  );
                },

                backgroundColor:
                    AppColors.accentRed,
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          CustomBottomNavbar(
        selectedIndex: _selectedIndex,

        onTap: (index) {

          setState(() {
            _selectedIndex = index;
          });

          switch (index) {

            case 0:

              Navigator.pushReplacementNamed(
                context,
                '/home',
              );

              break;

            case 1:

              Navigator.pushNamed(
                context,
                '/history',
              );

              break;

            case 2:

              Navigator.pushNamed(
                context,
                '/keywords',
              );

              break;

            case 3:

              Navigator.pushNamed(
                context,
                '/dashboard',
              );

              break;
          }
        },
      ),
    );
  }
}