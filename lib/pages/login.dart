import 'dart:convert';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_dart/firebase_dart.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:medzsite/util/firebase_options.dart';




class MobileLoginPage extends StatefulComponent {
  const MobileLoginPage({super.key});

  @override
  State<MobileLoginPage> createState() => _MobileLoginPageState();
}

class _MobileLoginPageState extends State<MobileLoginPage> {

  String phone = '';
  String otp = '';

  bool isLoading = false;
  bool showOtpBox = false;

  String reqId = '';
  bool _firebaseReady = false;

  Future<void> _ensureFirebase() async {
    if (_firebaseReady || Firebase.apps.isNotEmpty) {
      _firebaseReady = true;
      return;
    }
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firebaseReady = true;
    } catch (e) {
      // Keep UI responsive even if init fails.
      print('Firebase init error (login): $e');
    }
  }

  //================ SEND OTP ==================

  Future<void> sendOtp() async {

    phone = phone.trim();
    if(phone.isEmpty) return;

    setState(()=> isLoading = true);

    const url =
        "https://us-central1-medz-9eda1.cloudfunctions.net/sendMsg91Otp";

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({'phoneNumber': phone}),
    );

    print('sendOtp status: ${response.statusCode}');
    print('sendOtp body: ${response.body}');

    final data = jsonDecode(response.body);

    if(data['success'] == true){

      setState(() {
        reqId = data['reqId'];
        showOtpBox = true;
      });

    }

    setState(()=> isLoading = false);
  }

  //================ VERIFY OTP ==================

  Future<void> verifyOtp() async {

    phone = phone.trim();
    otp = otp.trim();
    if (phone.isEmpty || otp.isEmpty || reqId.isEmpty) return;

    const url =
        "https://us-central1-medz-9eda1.cloudfunctions.net/verifyMsg91Otp";

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        'phoneNumber': phone,
        'otp': otp,
        'reqId': reqId
      }),
    );

    print('verifyOtp status: ${response.statusCode}');
    print('verifyOtp body: ${response.body}');

    final data = jsonDecode(response.body);

    if(data['success'] == true){

      String token = data['token'];

      await _ensureFirebase();
      final cred = await FirebaseAuth.instance.signInWithCustomToken(token);

      final user = cred.user ?? FirebaseAuth.instance.currentUser;
      if (user != null) {
        final needsProfile = await _needsProfileSetup(user);
        if (needsProfile) {
          context.push('/edit-profile');
          return;
        }
      }

      // redirect home
      context.push('/');

    }
  }

  //================ GUEST LOGIN ==================

  Future<void> guestLogin() async {

    try {
      await _ensureFirebase();
      await FirebaseAuth.instance.signInAnonymously();
    } catch (_) {
      // Even if auth fails, still route the user as requested.
    }

    context.push('/');

  }

  Future<bool> _needsProfileSetup(User user) async {
    const projectId = 'medz-9eda1';
    const apiKey = 'AIzaSyDs7aCWHGL6V6_4B3_PA3NPpMLjhxJehKs';
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/Users/${user.uid}?key=$apiKey',
    );

    try {
      final token = await user.getIdToken();
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 404) return true;
      if (res.statusCode != 200) return false;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final fields = data['fields'] as Map<String, dynamic>? ?? {};
      String? str(String key) => fields[key]?['stringValue']?.toString();

      final name = (str('name') ?? '').trim();
      final email = (str('email') ?? '').trim();
      return name.isEmpty || email.isEmpty;
    } catch (_) {
      return false;
    }
  }

  //================ UI ==================

  @override
  Component build(BuildContext context) {

    return div(classes:'login-page', [

      div(classes:'login-card', [

        div(classes:'login-hero', [
          img(
            src: '/images/108medz%20logo.png',
            alt: '108 Medz',
            classes: 'login-logo',
          ),

          h1(classes:'login-title', [text("108 Medz")]),

          p(classes:'login-subtitle', [text("Save Upto 70% on Medicines")]),
        ]),

        div(classes:'login-section', [
          h2(classes:'login-section-title', [text("Get Started")]),
          p(classes:'login-section-sub', [text("Enter your WhatsApp number")]),

          div(classes:'login-input-group', [
            span(classes:'login-prefix', [text("+91")]),

            input(
              classes:'login-input',
              attributes:{
                'placeholder':'Enter mobile number',
                'type':'tel',
                'inputmode':'numeric'
              },
              events:{
                'input': (e){
                  phone = (e.target as dynamic).value;
                }
              }
            ),
          ]),
        ]),

        button(
          classes:'login-btn login-btn-primary',
          events:{'click':(_)=> sendOtp()},
          [text(isLoading ? "Sending..." : "Get OTP")]
        ),

        button(
          classes:'login-btn login-btn-ghost',
          events:{'click':(_)=> guestLogin()},
          [text("Login as Guest")]
        ),

      ]),

      /// OTP POPUP
      if(showOtpBox)
        div(classes:'otp-popup',[

          div(classes:'otp-card',[

            h3(classes:'otp-title', [text("OTP Verification")]),

            input(
              classes:'otp-input',
              attributes:{
                'placeholder':'Enter OTP',
                'type':'number',
                'inputmode':'numeric'
              },
              events:{
                'input': (e){
                  otp = (e.target as dynamic).value;
                }
              }
            ),

            button(
              classes:'login-btn login-btn-primary',
              events:{'click':(_)=> verifyOtp()},
              [text("Verify & Login")]
            ),

            button(
              classes:'login-btn login-btn-ghost',
              events:{
                'click':(_){
                  setState(()=> showOtpBox = false);
                }
              },
              [text("Cancel")]
            )

          ])

        ])

    ]);
  }
}
