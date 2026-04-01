import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: CupertinoButton(
          padding: const EdgeInsets.all(8),
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(CupertinoIcons.back,
              color: AppColors.textPrimary(context), size: 22),
        ),
        title: Text(
          'Legal & Attributions',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _section(
            context,
            title: 'Non-Affiliation Disclaimer',
            body:
                'Cosmic Facts is an independent application and is not affiliated with, '
                'endorsed by, or officially connected to NASA, ISRO, ESA, SpaceX, or any '
                'other government space agency or private space company.\n\n'
                'The names NASA and ISRO, and all related marks, mission names, and '
                'identifiers belong to their respective organisations.',
          ),
          const SizedBox(height: 20),
          _section(
            context,
            title: 'Data & Image Sources',
            body:
                'Space imagery and scientific data displayed in this app are retrieved '
                'from publicly available APIs and archives, including:\n\n'
                '\u2022  NASA Astronomy Picture of the Day API (api.nasa.gov/planetary/apod)\n'
                '\u2022  NASA Image and Video Library (images-api.nasa.gov)\n'
                '\u2022  NASA EPIC / DSCOVR public archive (epic.gsfc.nasa.gov)\n'
                '\u2022  NASA Near Earth Object API (api.nasa.gov/neo)\n'
                '\u2022  Spaceflight News API (spaceflightnewsapi.net)\n\n'
                'All NASA content is provided under NASA\'s open data policy. '
                'Content is presented for educational and informational purposes only.',
          ),
          const SizedBox(height: 20),
          _section(
            context,
            title: 'Audio Content',
            body:
                'Space sounds featured in this app are sourced from NASA\'s publicly '
                'available audio archive (nasa.gov/audio-and-ringtones). '
                'These recordings are the property of NASA and are used under their '
                'open media usage guidelines.',
          ),
          const SizedBox(height: 20),
          _section(
            context,
            title: 'Educational Content',
            body:
                'Quiz questions, historical timelines, glossary entries, and learning '
                'content reference NASA, ISRO, and other space agencies in a factual and '
                'educational context. Such references do not imply any official relationship '
                'between this app and those organisations.',
          ),
          const SizedBox(height: 20),
          _section(
            context,
            title: 'Trademarks',
            body:
                'All organisation names, mission names, and related terms mentioned in '
                'this app are trademarks or service marks of their respective owners. '
                'Their use here is purely informational and does not imply sponsorship, '
                'affiliation, or endorsement.',
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context,
      {required String title, required String body}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
