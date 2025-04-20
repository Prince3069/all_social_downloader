// // services/platform_services/facebook_service.dart
// class FacebookService {
//   Future<String> getDownloadUrl(String shareUrl) async {
//     // Would extract the direct download URL
//     return 'https://example.com/facebook_video.mp4';
//   }

//   Future<Map<String, dynamic>> getMediaInfo(String url) async {
//     return {
//       'title': 'Facebook Video',
//       'thumbnail': 'https://example.com/thumb.jpg',
//       'isVideo': true,
//     };
//   }
// }

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:html/parser.dart' as parser;
// import '../../utils/url_extractor.dart';
// import '../../utils/constants.dart';

// class FacebookService {
//   /// Extracts the direct download URL from a Facebook video share URL
//   /// Returns a direct video URL that can be downloaded
//   Future<String> getDownloadUrl(String shareUrl) async {
//     try {
//       // Normalize the URL (handle mobile links, etc.)
//       final normalizedUrl = _normalizeUrl(shareUrl);

//       // First approach: Try to fetch the page and extract video URL from HTML
//       final response = await http.get(Uri.parse(normalizedUrl), headers: {
//         'User-Agent': Constants.USER_AGENT,
//         'Accept': 'text/html,application/xhtml+xml'
//       });

//       if (response.statusCode == 200) {
//         // Parse the HTML document
//         final document = parser.parse(response.body);

//         // Look for meta tags containing video URL
//         final videoElements =
//             document.querySelectorAll('meta[property="og:video"]');
//         if (videoElements.isNotEmpty) {
//           final videoUrl = videoElements.first.attributes['content'];
//           if (videoUrl != null && videoUrl.isNotEmpty) {
//             return videoUrl;
//           }
//         }

//         // Alternative: Look for standard video elements
//         final scriptElements = document.querySelectorAll('script');
//         for (final script in scriptElements) {
//           if (script.text.contains('video_url')) {
//             // Extract URL using regex from script content
//             final RegExp regExp = RegExp(r'"video_url":"([^"]+)"');
//             final match = regExp.firstMatch(script.text);
//             if (match != null && match.groupCount >= 1) {
//               String url = match.group(1)!;
//               // Facebook often escapes URLs in their JS
//               url = url.replaceAll(r'\/', '/');
//               return url;
//             }
//           }
//         }
//       }

//       // Second approach: Use a fallback method with a more complex extraction
//       return await _extractWithFallbackMethod(normalizedUrl);
//     } catch (e) {
//       print('Error extracting Facebook video URL: $e');
//       throw Exception(
//           'Could not extract Facebook video. Please check the URL and try again.');
//     }
//   }

//   /// Fallback method using additional techniques
//   Future<String> _extractWithFallbackMethod(String url) async {
//     try {
//       // Make request with mobile user agent which sometimes provides simpler page structure
//       final response = await http.get(Uri.parse(url), headers: {
//         'User-Agent': Constants.MOBILE_USER_AGENT,
//       });

//       if (response.statusCode == 200) {
//         // Look for SD_SRC or HD_SRC patterns
//         final RegExp hdRegExp = RegExp(r'"hd_src":"([^"]+)"');
//         final RegExp sdRegExp = RegExp(r'"sd_src":"([^"]+)"');

//         final hdMatch = hdRegExp.firstMatch(response.body);
//         if (hdMatch != null && hdMatch.groupCount >= 1) {
//           String hdUrl = hdMatch.group(1)!.replaceAll(r'\/', '/');
//           return hdUrl;
//         }

//         final sdMatch = sdRegExp.firstMatch(response.body);
//         if (sdMatch != null && sdMatch.groupCount >= 1) {
//           String sdUrl = sdMatch.group(1)!.replaceAll(r'\/', '/');
//           return sdUrl;
//         }
//       }

//       // If all methods fail, throw an exception
//       throw Exception('Could not extract Facebook video URL');
//     } catch (e) {
//       throw Exception('Facebook extraction failed: $e');
//     }
//   }

//   /// Normalizes Facebook URLs to handle different formats
//   String _normalizeUrl(String url) {
//     // Handle m.facebook.com and www.facebook.com differences
//     if (url.contains('m.facebook.com')) {
//       url = url.replaceFirst('m.facebook.com', 'www.facebook.com');
//     }

//     // Handle fb.watch short URLs
//     if (url.contains('fb.watch')) {
//       // We need to follow redirects for these
//       return url;
//     }

//     // Handle /watch/ paths
//     if (url.contains('/watch/')) {
//       final Uri uri = Uri.parse(url);
//       final pathSegments = uri.pathSegments;
//       final int watchIndex = pathSegments.indexOf('watch');
//       if (watchIndex >= 0 && watchIndex < pathSegments.length - 1) {
//         final videoId = pathSegments[watchIndex + 1];
//         return 'https://www.facebook.com/watch/?v=$videoId';
//       }
//     }

//     return url;
//   }

//   /// Get media information including title, thumbnail, and type
//   Future<Map<String, dynamic>> getMediaInfo(String url) async {
//     try {
//       final response = await http.get(Uri.parse(_normalizeUrl(url)),
//           headers: {'User-Agent': Constants.USER_AGENT});

//       if (response.statusCode == 200) {
//         final document = parser.parse(response.body);

//         // Extract title
//         String title = 'Facebook Video';
//         final titleElements =
//             document.querySelectorAll('meta[property="og:title"]');
//         if (titleElements.isNotEmpty) {
//           final extractedTitle = titleElements.first.attributes['content'];
//           if (extractedTitle != null && extractedTitle.isNotEmpty) {
//             title = extractedTitle;
//           }
//         }

//         // Extract thumbnail
//         String thumbnail = '';
//         final imageElements =
//             document.querySelectorAll('meta[property="og:image"]');
//         if (imageElements.isNotEmpty) {
//           final extractedImage = imageElements.first.attributes['content'];
//           if (extractedImage != null && extractedImage.isNotEmpty) {
//             thumbnail = extractedImage;
//           }
//         }

//         return {
//           'title': title,
//           'thumbnail': thumbnail,
//           'isVideo': true,
//         };
//       }

//       // Return default info if extraction fails
//       return {
//         'title': 'Facebook Video',
//         'thumbnail': '',
//         'isVideo': true,
//       };
//     } catch (e) {
//       print('Error extracting Facebook media info: $e');
//       return {
//         'title': 'Facebook Video',
//         'thumbnail': '',
//         'isVideo': true,
//       };
//     }
//   }
// }
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as parser;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/url_extractor.dart';
import '../../utils/constants.dart';

class FacebookService {
  static const Map<String, String> _defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    'Referer': 'https://m.facebook.com/',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1'
  };

  final _secureStorage = const FlutterSecureStorage();
  static const _cookieKey = 'facebook_session_cookie';

  /// Provide a custom session cookie string from a real browser login session
  static Map<String, String> buildSessionHeaders(String cookieHeader) {
    return {
      ..._defaultHeaders,
      'Cookie': cookieHeader,
    };
  }

  /// Save Facebook session cookie to secure storage
  Future<void> saveCookie(String cookieHeader) async {
    await _secureStorage.write(key: _cookieKey, value: cookieHeader);
  }

  /// Retrieve Facebook session cookie from secure storage
  Future<Map<String, String>?> getStoredSessionHeaders() async {
    final cookie = await _secureStorage.read(key: _cookieKey);
    if (cookie != null && cookie.isNotEmpty) {
      return buildSessionHeaders(cookie);
    }
    return null;
  }

  Future<String> getDownloadUrl(String shareUrl,
      {Map<String, String>? extraHeaders}) async {
    try {
      final normalizedUrl = _normalizeUrl(shareUrl);
      final combinedHeaders = {
        ..._defaultHeaders,
        if (extraHeaders != null) ...extraHeaders
      };

      final response =
          await http.get(Uri.parse(normalizedUrl), headers: combinedHeaders);
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final videoElements =
            document.querySelectorAll('meta[property="og:video"]');
        if (videoElements.isNotEmpty) {
          final videoUrl = videoElements.first.attributes['content'];
          if (videoUrl != null && videoUrl.isNotEmpty) {
            return videoUrl;
          }
        }

        final scriptElements = document.querySelectorAll('script');
        for (final script in scriptElements) {
          if (script.text.contains('video_url')) {
            final RegExp regExp = RegExp(r'"video_url":"([^"\\]+)"');
            final match = regExp.firstMatch(script.text);
            if (match != null && match.groupCount >= 1) {
              String url = match.group(1)!.replaceAll(r'\/', '/');
              return url;
            }
          }
        }
      } else {
        print('HTML fetch failed with status: ${response.statusCode}');
        print(
            'Response body snippet: ${response.body.substring(0, response.body.length.clamp(0, 500))}');
        throw Exception(
            'Facebook video is not publicly accessible (${response.statusCode} Error)');
      }

      return await _extractWithFallbackMethod(normalizedUrl,
          extraHeaders: extraHeaders);
    } catch (e) {
      print('Error extracting Facebook video URL: $e');
      throw Exception(
          'Could not extract Facebook video. Please check the URL and try again.');
    }
  }

  Future<String> _extractWithFallbackMethod(String url,
      {Map<String, String>? extraHeaders}) async {
    try {
      final response = await http.get(Uri.parse(url), headers: {
        ..._defaultHeaders,
        if (extraHeaders != null) ...extraHeaders
      });

      print('Fallback response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);

        final title = document.querySelector('title')?.text.toLowerCase() ?? '';
        if (title.contains('error') || title.contains('login')) {
          print('Page title indicates error/login: $title');
          throw Exception(
              'Facebook redirected to error/login page. This video might be private.');
        }

        final RegExp hdRegExp = RegExp(r'"hd_src":"([^"\\]+)"');
        final RegExp sdRegExp = RegExp(r'"sd_src":"([^"\\]+)"');

        final hdMatch = hdRegExp.firstMatch(response.body);
        if (hdMatch != null) {
          return hdMatch.group(1)!.replaceAll(r'\/', '/');
        }

        final sdMatch = sdRegExp.firstMatch(response.body);
        if (sdMatch != null) {
          return sdMatch.group(1)!.replaceAll(r'\/', '/');
        }

        print(
            'Fallback failed. Sample body: ${response.body.substring(0, response.body.length.clamp(0, 500))}');
      } else {
        print('Fallback fetch failed with status: ${response.statusCode}');
        throw Exception(
            'Facebook video is not publicly accessible (${response.statusCode} Error)');
      }

      throw Exception('Could not extract Facebook video URL');
    } catch (e) {
      throw Exception('Facebook extraction failed: $e');
    }
  }

  String _normalizeUrl(String url) {
    if (url.contains('m.facebook.com')) {
      url = url.replaceFirst('m.facebook.com', 'www.facebook.com');
    }

    if (url.contains('fb.watch')) {
      return url;
    }

    if (url.contains('/watch/')) {
      final Uri uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final int watchIndex = pathSegments.indexOf('watch');
      if (watchIndex >= 0 && watchIndex < pathSegments.length - 1) {
        final videoId = pathSegments[watchIndex + 1];
        return 'https://www.facebook.com/watch/?v=$videoId';
      }
    }

    return url;
  }

  Future<Map<String, dynamic>> getMediaInfo(String url,
      {Map<String, String>? extraHeaders}) async {
    try {
      final response = await http.get(Uri.parse(_normalizeUrl(url)), headers: {
        ..._defaultHeaders,
        if (extraHeaders != null) ...extraHeaders
      });

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);

        String title = 'Facebook Video';
        final titleElements =
            document.querySelectorAll('meta[property="og:title"]');
        if (titleElements.isNotEmpty) {
          final extractedTitle = titleElements.first.attributes['content'];
          if (extractedTitle != null && extractedTitle.isNotEmpty) {
            title = extractedTitle;
          }
        }

        String thumbnail = '';
        final imageElements =
            document.querySelectorAll('meta[property="og:image"]');
        if (imageElements.isNotEmpty) {
          final extractedImage = imageElements.first.attributes['content'];
          if (extractedImage != null && extractedImage.isNotEmpty) {
            thumbnail = extractedImage;
          }
        }

        return {
          'title': title,
          'thumbnail': thumbnail,
          'isVideo': true,
        };
      }

      return {
        'title': 'Facebook Video',
        'thumbnail': '',
        'isVideo': true,
      };
    } catch (e) {
      print('Error extracting Facebook media info: $e');
      return {
        'title': 'Facebook Video',
        'thumbnail': '',
        'isVideo': true,
      };
    }
  }
}
