import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/app_colors.dart';

class NearlyImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const NearlyImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      image = errorWidget ?? _defaultError();
    } else {
      image = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 200),
        // Optimize memory by limiting cache size if dimensions are known
        memCacheWidth: width != null && width! > 0 ? (width! * 2).toInt() : null,
        memCacheHeight: height != null && height! > 0 ? (height! * 2).toInt() : null,
        placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _defaultError(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    return image;
  }

  Widget _defaultPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _defaultError() {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      color: AppColors.primary.withOpacity(0.05),
      child: const Center(
        child: Icon(Icons.person_rounded, color: AppColors.primary, size: 32),
      ),
    );
  }
}
