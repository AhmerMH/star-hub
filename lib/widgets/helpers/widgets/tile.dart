import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/helpers/widgets/bpp-video-player.dart';
import 'package:starhub/widgets/movies/helpers/movie-detail.dart';
import 'package:starhub/widgets/series/helpers/series-details.dart';

final Color nameBackground = Colors.grey[800]!;
const Color textColor = Colors.white;
final Color focusedColor = Colors.red[500]!;

class Tile extends StatelessWidget {
  final int streamId;
  final String name;
  final String streamUrl;
  final CategoryType type;
  final String imageUrl;
  final bool horizontal;
  final Function()? customOnTap;

  const Tile({
    super.key,
    required this.streamId,
    required this.name,
    required this.streamUrl,
    required this.type,
    required this.imageUrl,
    this.horizontal = false,
    this.customOnTap,
  });

  void onTap(BuildContext context) {
    if (customOnTap != null) {
      customOnTap!();
      return;
    }

    if (type == CategoryType.movies) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieDetailsScreen(
            streamId: streamId,
            name: name,
            streamUrl: streamUrl,
          ),
        ),
      );
    } else if (type == CategoryType.series) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeriesDetails(streamId: streamId),
        ),
      );
    } else if (type == CategoryType.livetv) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BPVideoPlayer(
            streamUrl: streamUrl,
            name: name,
            isLiveTV: true,
          ),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.select) {
          onTap(context);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => onTap(context),
        child: Builder(builder: (context) {
          final isFocused = Focus.of(context).hasFocus;
          return AspectRatio(
            aspectRatio: horizontal ? 3 / 2 : 2 / 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isFocused
                    ? Border.all(color: focusedColor, width: 3)
                    : null,
                image: DecorationImage(
                  image: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl) as ImageProvider
                      : const AssetImage('assets/images/globe_red.png'),
                  fit: BoxFit.cover,
                  onError: (_, __) =>
                      const AssetImage('assets/images/globe_red.png'),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    height: 65,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: nameBackground,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
