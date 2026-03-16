import 'dart:convert';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:medzsite/component.dart';
import 'package:http/http.dart' as http;

class HorizontalPosts extends StatefulComponent {
  @override
  State<HorizontalPosts> createState() => _HorizontalPostsState();
}

class _HorizontalPostsState extends State<HorizontalPosts> {
  List<dynamic> _posts = [];
  bool _isLoading = true;

  @override
  Component build(BuildContext context) {
    return SyncState.aggregate(
      id: 'health-posts',
      create: () => _fetchHealthPosts(), // Connect to your Firestore/API service
      update: (data) {
        _posts = data;
        _isLoading = false;
      },
      builder: (context) {
        return section(
          attributes: {'style': 'padding: 24px 0; background: #f9fafb;'},
          [
            /// Header Section
            div(classes: 'header', attributes: {'style': 'padding: 0 16px; margin-bottom: 16px;'}, [
              div(attributes: {'style': 'display: flex; justify-content: space-between; align-items: center;'}, [
                h2(attributes: {'style': 'font-size: 16px; font-weight: 600; margin: 0;'}, [
                  text("Health Information")
                ]),
                // Desktop Arrows (Optional for web, usually handled by scrollbar/touch)
                div(classes: 'arrows', [
                  _arrowButton('chevron_left', 'left'),
                  span(attributes: {'style': 'width: 8px; display: inline-block;'}, []),
                  _arrowButton('chevron_right', 'right'),
                ]),
              ]),
              p(attributes: {'style': 'font-size: 13px; color: #4b5563; margin: 4px 0 0;'}, [
                text("Learn About Your Health and Generic Medicines")
              ]),
            ]),

            /// Horizontal Scroll List
            div(
              id: 'scroll-container',
              attributes: {
                'style': '''
                  display: flex;
                  overflow-x: auto;
                  gap: 16px;
                  padding: 0 16px 16px;
                  scroll-behavior: smooth;
                  scrollbar-width: none; /* Hide scrollbar for Firefox */
                '''
              },
              [
                if (_isLoading) text("Loading health posts...")
                else if (_posts.isEmpty) text("No health posts available")
                else ...[
                  for (var post in _posts) _PostCard(post: post),
                ]
              ],
            ),
          ],
        );
      },
    );
  }

  Component _arrowButton(String icon, String direction) {
    return button(
      attributes: {
        'onClick': "document.getElementById('scroll-container').scrollBy({left: ${direction == 'left' ? -300 : 300}, behavior: 'smooth'})",
        'style': '''
          background: white; border: none; border-radius: 50%;
          width: 32px; height: 32px; cursor: pointer;
          box-shadow: 0 1px 3px rgba(0,0,0,0.1);
          color: #2B4C7E; align-items: center; justify-content: center;
        '''
      },
      [span(classes: 'material-symbols-outlined', attributes: {'style': 'font-size: 18px;'}, [text(icon)])]
    );
  }

  Future<List<dynamic>> _fetchHealthPosts() async {
    // Firestore REST API (Web app config from Firebase console)
    const projectId = 'medz-9eda1';
    const apiKey = 'AIzaSyDs7aCWHGL6V6_4B3_PA3NPpMLjhxJehKs';
    const collection = 'Posts';

    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collection?key=$apiKey',
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        print('Health posts fetch failed: ${res.statusCode} ${res.body}');
        return [];
      }

      final data = json.decode(res.body) as Map<String, dynamic>;
      final docs = (data['documents'] as List?) ?? [];

      return docs.map((doc) {
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        String? str(String key) => fields[key]?['stringValue']?.toString();
        bool bool(String key) => fields[key]?['booleanValue'] == true;

        return {
          'id': (doc['name'] as String?)?.split('/').last ?? '',
          'title': str('title') ?? 'Health Post',
          'image': str('image') ?? '',
          'tag': str('tag') ?? '',
          'posturl': str('posturl') ?? '',
          'isPublished': bool('isPublished'),
        };
      }).where((p) => p['isPublished'] != false).toList();
    } catch (e) {
      print('Health posts fetch error: $e');
      return [];
    }
  }
}

class _PostCard extends StatelessComponent {
  final dynamic post;
  _PostCard({required this.post});

  @override
  Component build(BuildContext context) { // Changed return type and removed sync*
    return a( // Removed yield
      href: '/webview?url=${Uri.encodeComponent(post['posturl'])}',
      attributes: {
        'style': '''
          flex: 0 0 auto;
          width: 320px;
          aspect-ratio: 16 / 9;
          position: relative;
          border-radius: 16px;
          overflow: hidden;
          text-decoration: none;
          box-shadow: 0 6px 10px rgba(0,0,0,0.15);
        '''
      },
      [
        /// Image
        img(
          src: post['image'],
          attributes: {'style': 'width: 100%; height: 100%; object-fit: cover;'}
        ),

        /// Gradient Overlay
        div(attributes: {
          'style': '''
            position: absolute; inset: 0;
            background: linear-gradient(to top, rgba(0,0,0,0.54), rgba(0,0,0,0.26), transparent);
          '''
        }, []),

        /// Content Overlay
        div(attributes: {
          'style': 'position: absolute; bottom: 16px; left: 16px; right: 16px;'
        }, [
          /// Tag
          span(attributes: {
            'style': '''
              background: #2B4C7E; color: white; padding: 4px 12px;
              border-radius: 20px; font-size: 12px; display: inline-block;
              margin-bottom: 8px;
            '''
          }, [text(post['tag'])]),

          /// Title
          h3(attributes: {
            'style': '''
              color: white; font-size: 18px; font-weight: bold; margin: 0;
              display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
              overflow: hidden;
            '''
          }, [text(post['title'])]),
        ]),
      ],
    );
  }
}
