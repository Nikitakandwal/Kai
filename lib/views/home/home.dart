import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_to_image/views/home/home_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class HomePage extends ConsumerWidget {
  HomePage({super.key});
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fWatch = ref.watch(homeProvider);
    final fRead = ref.read(homeProvider.notifier);
    final themeMode = ref.read(themeProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Download Image Function
    Future<void> _downloadImage(Uint8List imageData) async {
      final result = await ImageGallerySaver.saveImage(imageData);
      if (result != null && result.isNotEmpty) {
        // Show a snackbar or toast message indicating successful download
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image downloaded successfully')),
        );
      } else {
        // Show a snackbar or toast message indicating download failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download image')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('KAI - Image Generator', style: GoogleFonts.openSans()),
        actions: [
          IconButton(
            icon: Icon(
              themeMode.state == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () {
              themeMode.toggleTheme();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Stack(
                    children: [
                      // Generated Image
                      Container(
                        alignment: Alignment.center,
                        height: 320,
                        width: 320,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Theme.of(context).dividerColor
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: fWatch.isLoading
                            ? Image.memory(fWatch.imageData!)
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 100,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Let KAI weave its digital artistry...',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: GoogleFonts.openSans().fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Download Button
                      Visibility(
                        visible: fWatch.isLoading,
                        child: Positioned(
                          bottom: 6,
                          right: 6,
                          child: Material(
                            shape: const CircleBorder(),
                            color: Colors.transparent,
                            child: IconButton(
                              onPressed: () {
                                _downloadImage(fWatch.imageData!);
                              },
                              icon: Icon(
                                Icons.download,
                                color: isDarkMode ? Colors.white : Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Theme.of(context).dividerColor : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: TextField(
                      controller: textController,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        fontFamily: GoogleFonts.openSans().fontFamily,
                      ),
                      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Enter your prompt here...',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Theme.of(context).hintColor : Colors.grey[800],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.openSans().fontFamily,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Generate Button
                      GestureDetector(
                        onTap: () {
                          fRead.textToImage(textController.text, context);
                          fRead.searchingChange(true);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 60,
                          width: 160,
                          decoration: BoxDecoration(
                              color: isDarkMode ? Colors.deepPurple[100]! : Colors.lightBlue[200]!,
                              borderRadius: const BorderRadius.all(Radius.circular(12.0))),
                          child: fWatch.isSearching
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : Text(
                            'Generate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.openSans().fontFamily,
                            ),
                          ),
                        ),
                      ),

                      // Clear Button
                      GestureDetector(
                        onTap: () {
                          fRead.loadingChange(false);
                          textController.clear();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 60,
                          width: 160,
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.lightGreen[100]! : Colors.orange[200]!,
                            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                          ),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.openSans().fontFamily,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
