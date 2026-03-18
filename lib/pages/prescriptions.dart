import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class PrescriptionsPage extends StatefulComponent {
  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  bool showUploadPopup = false;

  @override
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
        div([
          _rxCard('dfgh', '1770710703657', 'https://via.placeholder.com/100x70/8FA382/FFFFFF'),
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
          }
        ),

        // Grey Selection Box
        div(attributes: {
          'style': '''
            width: 100%; height: 180px; background: #f0f0f0;
            border-radius: 20px; display: flex; align-items: center;
            justify-content: center; color: #666; font-size: 16px;
            margin-bottom: 20px;
          '''
        }, [text('No prescription selected')]),

        // Buttons Row (Gallery & Camera)
        div(attributes: {
          'style': 'display: flex; gap: 12px; margin-bottom: 20px;'
        }, [
          _actionButton('Gallery', 'image'),
          _actionButton('Camera', 'photo_camera'),
        ]),

        // Final Submit Button
        button(
          events: {'click': (_) => setState(() => showUploadPopup = false)},
          attributes: {
            'style': '''
              width: 100%; background: #120063; color: white; border: none;
              border-radius: 15px; padding: 16px; font-size: 18px;
              font-weight: 700; cursor: pointer;
            '''
          },
          [text('Upload Prescription')]
        )
      ])
    ]);
  }

  Component _actionButton(String label, String icon) {
    return button(attributes: {
      'style': '''
        flex: 1; background: white; border: 1.5px solid #120063;
        border-radius: 25px; padding: 12px; display: flex;
        align-items: center; justify-content: center; gap: 8px;
        font-weight: 600; color: #120063; cursor: pointer;
      '''
    }, [
      span(classes: 'material-symbols-outlined', [text(icon)]),
      text(label)
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
}