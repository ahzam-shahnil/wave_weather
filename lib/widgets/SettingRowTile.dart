import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingRowTile extends StatelessWidget {
  SettingRowTile({
    required this.popMenuItem,
    required this.selected,
    required this.onSelected,
    required this.title,
  });
  final String selected;
  final String title;
  final Function(String) onSelected;
  final List<PopupMenuItem<String>> popMenuItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, top: 25, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: AutoSizeText(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Get.isDarkMode ? Color(0xFFD8D8D8) : Colors.black,
              ),
            ),
          ),
          Flexible(
            child: Card(
              color: Get.isDarkMode ? Color(0xff424242) : Color(0xFFD8D8D8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: PopupMenuButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        flex: 1,
                        child: AutoSizeText(
                          selected,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.sort,
                            size: 16,
                          )
                        ],
                      )
                    ],
                  ),
                  initialValue: selected,
                  onSelected: onSelected,
                  color: Get.isDarkMode ? Color(0xff3167A6) : Color(0xFF936DF3),
                  padding: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  itemBuilder: (context) => popMenuItem,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
