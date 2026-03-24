import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:http/http.dart' as http;
import '../util/firebase_options.dart';
import '../util/file_picker.dart';
import '../util/storage_upload.dart';

class PrescriptionsPage extends StatefulComponent {
  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  bool showUploadPopup = false;
  bool _isSaving = false;
  String _prescriptionName = '';
  String? _errorText;
  String? _previewUrl;
  PickedFileData? _selectedFile;
  double _uploadProgress = 0;
  final List<_Prescription> _prescriptions = [];
  StreamSubscription<User?>? _authSub;

  String get _projectId => DefaultFirebaseOptions.currentPlatform.projectId;
  String get _apiKey => DefaultFirebaseOptions.currentPlatform.apiKey;
  static const String _collection = 'Prescription';

  String _resolveStorageBucket() {
    final bucket = DefaultFirebaseOptions.currentPlatform.storageBucket;
    if (bucket == null || bucket.isEmpty) {
      return '$_projectId.appspot.com';
    }
    if (bucket.endsWith('.firebasestorage.app')) {
      return '$_projectId.appspot.com';
    }
    return bucket;
  }

  @override
  void initState() {
    super.initState();
    if (Firebase.apps.isNotEmpty) {
      _primeAuthAndLoad();
    }
  }

  void _primeAuthAndLoad() {
  try {
    if (Firebase.apps.isEmpty) return;
    
    // Check if user is already logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loadPrescriptions();
    }

    // Listen for changes
    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
      if (u != null) {
        _loadPrescriptions();
      }
    }, onError: (e) {
      print("Auth Stream Error: $e");
      setState(() => _errorText = "Authentication connection failed.");
    });
  } catch (e) {
    print("Firebase Auth initialization failed: $e");
    setState(() => _errorText = "Could not connect to Auth Service.");
  }
}

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Component build(BuildContext context) {
    return div(attributes: {
      'style': '''
        min-height: 100vh;
        background: linear-gradient(to bottom, #d6efff 0%, #ffffff 300px);
        display: flex;
        justify-content: center;
        position: relative;
        overflow: hidden;
      '''
    }, [
      // Centered Mobile-Width Container
      div(attributes: {
        'style': 'width: 100%; max-width: 480px; padding: 16px; font-family: sans-serif;'
      }, [
        // Header
        _buildHeader(context),

        // Prescription List
        if (_prescriptions.isEmpty)
          div(attributes: {'style': 'color:#666;margin-bottom:16px;'}, [
            text('No prescriptions yet.')
          ])
        else
          div([
            for (final rx in _prescriptions)
              _rxCard(rx.name, rx.displayId, rx.imageUrl),
          ]),

        // Trigger Button
        button(
          events: {'click': (_) => setState(() => showUploadPopup = true)},
          attributes: {
            'style': '''
              width: 100%; background: #001e3c; color: white; border: none;
              border-radius: 10px; padding: 14px; font-size: 18px; font-weight: 600;
              display: flex; align-items: center; justify-content: center; gap: 10px;
              margin-top: 20px; cursor: pointer;
            '''
          },
          [
            span(classes: 'material-symbols-outlined', [text('add_box')]),
            text('Add Prescription')
          ]
        )
      ]),

      // --- UPLOAD POPUP UI ---
      if (showUploadPopup) _buildUploadPopup(),
    ]);
  }

  Component _buildUploadPopup() {
    return div(attributes: {
      'style': '''
        position: fixed; inset: 0; background: rgba(0,0,0,0.5);
        display: flex; align-items: flex-end; justify-content: center; z-index: 1000;
      '''
    }, [
      div(attributes: {
        'style': '''
          width: 100%; max-width: 480px; background: white;
          border-radius: 30px 30px 0 0; padding: 24px;
          animation: slideUp 0.3s ease-out;
        '''
      }, [
        // Title
        h2(attributes: {
          'style': 'text-align: center; margin: 0 0 20px 0; font-size: 22px; font-weight: 800;'
        }, [text('Upload Prescription')]),

        // Input Field
        input(
          type: InputType.text,
          attributes: {
            'placeholder': 'Prescription Name *',
            'style': '''
              width: 100%; padding: 16px; border: 1.5px solid #333;
              border-radius: 15px; font-size: 16px; margin-bottom: 20px;
              outline: none; box-sizing: border-box;
            '''
          },
          events: {
            'input': (event) =>
                setState(() => _prescriptionName = ((event.target as dynamic).value ?? '').toString())
          },
        ),

        // Grey Selection Box
        div(attributes: {
          'style': '''
            width: 100%; height: 180px; background: #f0f0f0;
            border-radius: 20px; display: flex; align-items: center;
            justify-content: center; color: #666; font-size: 16px;
            margin-bottom: 20px;
          '''
        }, [
          if (_previewUrl == null)
            text('No prescription selected')
          else
            img(src: _previewUrl!, attributes: {
              'style': 'width:100%;height:100%;object-fit:cover;border-radius:18px;'
            })
        ]),

        if (_uploadProgress > 0 && _uploadProgress < 1)
          div(attributes: {
            'style': 'margin-bottom:16px;'
          }, [
            div(attributes: {
              'style': '''
              height:8px;background:#e6e6e6;border-radius:999px;overflow:hidden;
              '''
            }, [
              div(attributes: {
                'style': '''
                height:100%;width:${(_uploadProgress * 100).toStringAsFixed(0)}%;
                background:#120063;border-radius:999px;
                '''
              }, [])
            ]),
            div(attributes: {'style': 'margin-top:6px;font-size:12px;color:#666;'}, [
              text('Uploading ${( _uploadProgress * 100).toStringAsFixed(0)}%')
            ])
          ]),

        if (_errorText != null)
          div(attributes: {'style': 'color:#b91c1c;margin-bottom:12px;'}, [
            text(_errorText!)
          ]),

        // Buttons Row (Gallery & Camera)
        div(attributes: {
          'style': 'display: flex; gap: 12px; margin-bottom: 20px;'
        }, [
          _fileActionButton('Gallery', 'image', accept: 'image/*'),
          _fileActionButton('Camera', 'photo_camera', accept: 'image/*', capture: 'environment'),
        ]),

        // Final Submit Button
        button(
          events: {
            'click': (_) async {
              if (_isSaving) return;
              if (_prescriptionName.trim().isEmpty) {
                setState(() => _errorText = 'Please enter a prescription name.');
                return;
              }
              if (_selectedFile == null) {
                setState(() => _errorText = 'Please select a prescription image.');
                return;
              }
              setState(() {
                _isSaving = true;
                _errorText = null;
                _uploadProgress = 0;
              });
              try {
                final saved = await _createPrescription();
                setState(() {
                  _prescriptions.add(saved);
                  _prescriptionName = '';
                  _selectedFile = null;
                  if (_previewUrl != null) {
                    revokePreviewUrl(_previewUrl!);
                  }
                  _previewUrl = null;
                  _isSaving = false;
                  showUploadPopup = false;
                  _uploadProgress = 0;
                });
              } catch (e) {
                setState(() {
                  _isSaving = false;
                  _errorText = 'Upload failed: ${e.toString()}';
                  _uploadProgress = 0;
                });
              }
            }
          },
          attributes: {
            'style': '''
              width: 100%; background: #120063; color: white; border: none;
              border-radius: 15px; padding: 16px; font-size: 18px;
              font-weight: 700; cursor: pointer;
            '''
          },
          [text(_isSaving ? 'Uploading...' : 'Upload Prescription')]
        )
      ])
    ]);
  }

  Component _buildHeader(BuildContext context) {
    return div(attributes: {'style': 'display: flex; align-items: center; margin-bottom: 30px;'}, [
      button(
        events: {'click': (_) => context.push('/profile')},
        attributes: {'style': 'background: white; border: none; border-radius: 50%; width: 42px; height: 42px; box-shadow: 0 2px 8px rgba(0,0,0,0.12); cursor: pointer;'},
        [span(classes: 'material-symbols-outlined', [text('arrow_back')])]
      ),
      h2(attributes: {'style': 'margin: 0; font-size: 22px; color: #001e3c; flex: 1; margin-left: 20px; font-weight: 600;'}, [text('Manage Prescription')]),
      div(attributes: {'style': 'display: flex; gap: 18px; color: #003366;'}, [
        span(classes: 'material-symbols-outlined', [text('search')]),
        span(classes: 'material-symbols-outlined', [text('shopping_cart')]),
      ])
    ]);
  }

  Component _rxCard(String title, String id, String imageUrl) {
    return div(attributes: {
      'style': 'background: white; border-radius: 20px; padding: 8px; display: flex; align-items: center; gap: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); margin-bottom: 16px;'
    }, [
      img(src: imageUrl, attributes: {'style': 'width: 100px; height: 75px; border-radius: 14px; object-fit: cover;'}),
      div([
        h3(attributes: {'style': 'margin: 0; font-size: 18px; color: #1a1a1a;'}, [text(title)]),
        p(attributes: {'style': 'margin: 2px 0 0 0; color: #999; font-size: 14px;'}, [text(id)]),
      ])
    ]);
  }

  Component _fileActionButton(
    String textLabel,
    String icon, {
    required String accept,
    String? capture,
  }) {
    return label(attributes: {
      'style': '''
        flex: 1; background: white; border: 1.5px solid #120063;
        border-radius: 25px; padding: 12px; display: flex;
        align-items: center; justify-content: center; gap: 8px;
        font-weight: 600; color: #120063; cursor: pointer;
      '''
    }, [
      span(classes: 'material-symbols-outlined', [text(icon)]),
      text(textLabel),
      input(
        type: InputType.file,
        attributes: {
          'accept': accept,
          if (capture != null) 'capture': capture,
          'style': 'display:none;',
        },
        events: {
          'change': (event) async {
            final picked = await pickFileFromEvent(event);
            if (picked == null) return;
            setState(() {
              if (_previewUrl != null) revokePreviewUrl(_previewUrl!);
              _selectedFile = picked;
              _previewUrl = picked.previewUrl;
              _errorText = null;
            });
          }
        },
      ),
    ]);
  }

  Future<void> _loadPrescriptions() async {
    if (Firebase.apps.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.getIdToken(true);
    final token = await user.getIdToken();
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents:runQuery?key=$_apiKey',
    );
    final body = jsonEncode({
      'structuredQuery': {
        'from': [
          {'collectionId': _collection}
        ],
        'where': {
          'fieldFilter': {
            'field': {'fieldPath': 'uid'},
            'op': 'EQUAL',
            'value': {'stringValue': user.uid}
          }
        }
      }
    });
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return;
    final data = jsonDecode(res.body) as List<dynamic>;
    final loaded = <_Prescription>[];
    for (final item in data) {
      final map = item as Map<String, dynamic>;
      final doc = map['document'] as Map<String, dynamic>?;
      if (doc == null) continue;
      loaded.add(_Prescription.fromFirestoreDoc(doc));
    }
    loaded.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (mounted) {
      setState(() {
        _prescriptions
          ..clear()
          ..addAll(loaded);
      });
    }
  }

  Future<_Prescription> _createPrescription() async {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase not initialized');
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user');
    }
    if (_selectedFile == null) {
      throw Exception('No file selected');
    }
    final token = await user.getIdToken();
    final bucket = _resolveStorageBucket();
    if (bucket.isEmpty) {
      throw Exception('Missing storage bucket');
    }
    final objectPath =
        'prescriptions/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.name}';
    final imageUrl = await uploadToFirebaseStorage(
      bucket: bucket,
      objectPath: objectPath,
      file: _selectedFile!,
      idToken: token,
      onProgress: (value) {
        if (!mounted) return;
        setState(() => _uploadProgress = value.clamp(0, 1));
      },
    );
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$_collection?key=$_apiKey',
    );
    final now = DateTime.now();
    final body = jsonEncode({
      'fields': {
        'name': {'stringValue': _prescriptionName.trim()},
        'uid': {'stringValue': user.uid},
        'phone': {'stringValue': user.phoneNumber ?? ''},
        'imageUrl': {'stringValue': imageUrl},
        'storagePath': {'stringValue': objectPath},
        'createdAt': {'timestampValue': now.toUtc().toIso8601String()},
      }
    });
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Firestore create failed: ${res.statusCode}');
    }
    final doc = jsonDecode(res.body) as Map<String, dynamic>;
    return _Prescription.fromFirestoreDoc(doc);
  }
}

class _Prescription {
  final String id;
  final String name;
  final String imageUrl;
  final int createdAt;

  const _Prescription({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
  });

  String get displayId => createdAt > 0 ? createdAt.toString() : id;

  factory _Prescription.fromFirestoreDoc(Map<String, dynamic> doc) {
    final namePath = (doc['name'] ?? '').toString();
    final id = namePath.split('/').isNotEmpty ? namePath.split('/').last : '';
    final fields = doc['fields'] as Map<String, dynamic>? ?? {};
    String _str(String key) =>
        (fields[key]?['stringValue'] ?? '').toString();
    int _ts(String key) {
      final raw = fields[key]?['timestampValue'] as String?;
      if (raw == null || raw.isEmpty) return 0;
      return DateTime.tryParse(raw)?.millisecondsSinceEpoch ?? 0;
    }
    return _Prescription(
      id: id,
      name: _str('name'),
      imageUrl: _str('imageUrl').isEmpty
          ? 'https://via.placeholder.com/100x70/8FA382/FFFFFF'
          : _str('imageUrl'),
      createdAt: _ts('createdAt'),
    );
  }
}
