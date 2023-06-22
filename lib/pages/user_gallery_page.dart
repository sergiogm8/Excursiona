import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/image_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

class UserGalleryPage extends StatefulWidget {
  const UserGalleryPage({super.key});

  @override
  State<UserGalleryPage> createState() => _UserGalleryPageState();
}

class _UserGalleryPageState extends State<UserGalleryPage> {
  bool _isLoading = true;
  bool _hasMore = true;
  List<ImageModel> _items = [];
  static const int _docsLimit = 20;
  final ScrollController _scrollController = ScrollController();
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        _fetchImages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _fetchImages() async {
    try {
      var newPhotos = await _userController.getGalleryImages(_docsLimit);
      setState(() {
        if (newPhotos.length < _docsLimit) {
          _hasMore = false;
        }
        _items.addAll(newPhotos);
      });
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      showSnackBar(context, Colors.red, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.darkWhite,
      appBar: AppBar(
        title: Text(
          "Tu galería de imágenes",
          style: GoogleFonts.inter(),
        ),
        backgroundColor: Constants.indigoDye,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Loader()
          : GridView.builder(
              itemCount: _items.length + 1,
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
              ),
              itemBuilder: (BuildContext context, int index) {
                if (index == _items.length) {
                  if (_hasMore) {
                    return const Center(
                      child: Loader(),
                    );
                  } else {
                    return const SizedBox();
                  }
                }
                return GestureDetector(
                  onTap: () =>
                      showFullscreenImage(context, _items[index].imageUrl),
                  child: CachedNetworkImage(
                    imageUrl: _items[index].imageUrl,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Constants.indigoDye),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}
