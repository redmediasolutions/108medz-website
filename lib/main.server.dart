import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'app.dart';
import 'main.server.options.dart';
import 'pages/config.dart';
import 'server/woocommerce_secrets.dart';

bool _loggedFallback = false;

Middleware _wooProxyMiddleware() {
  return (inner) {
    return (Request request) async {
      final segments = request.url.pathSegments;
        if (segments.length >= 2 && segments[0] == 'api' && segments[1] == 'woo') {
          print('[PROXY] ${request.method} /${segments.skip(2).join('/')}?${request.requestedUri.query}');
          if (request.method.toUpperCase() == 'OPTIONS') {
            return Response.ok('', headers: _corsHeaders());
          }

        if (request.method.toUpperCase() != 'GET') {
          return Response(405, body: 'Method Not Allowed', headers: _corsHeaders());
        }

        if (!_loggedFallback && WCServerSecrets.usingFallback) {
          print('[PROXY] Warning: using fallback WooCommerce credentials. Set WC_CONSUMER_KEY and WC_CONSUMER_SECRET.');
          _loggedFallback = true;
        }

        final targetPath = segments.skip(2).join('/');
        final allowed = {
          'products',
          'products/categories',
        };

        if (!allowed.contains(targetPath)) {
          return Response(404, body: 'Not Found', headers: _corsHeaders());
        }

        final base = Uri.parse('${WCConfig.baseUrl}/wp-json/wc/v3/$targetPath');
        final query = <String, String>{};
        query.addAll(request.url.queryParameters);
        query['consumer_key'] = WCServerSecrets.consumerKey;
        query['consumer_secret'] = WCServerSecrets.consumerSecret;

        final uri = base.replace(queryParameters: query);
        final authToken = base64Encode(utf8.encode(
          '${WCServerSecrets.consumerKey}:${WCServerSecrets.consumerSecret}',
        ));

        final proxied = await http.get(uri, headers: {
          'Authorization': 'Basic $authToken',
        });
        print('[PROXY] -> ${proxied.statusCode} $uri');

        final headers = <String, String>{
          ..._corsHeaders(),
          if (proxied.headers['content-type'] != null) 'content-type': proxied.headers['content-type']!,
        };

        return Response(
          proxied.statusCode,
          body: proxied.body,
          headers: headers,
        );
      }

      return await inner(request);
    };
  };
}

Map<String, String> _corsHeaders() => {
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'GET, OPTIONS',
      'access-control-allow-headers': 'content-type, authorization',
    };

void main() {
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  ServerApp.addMiddleware(_wooProxyMiddleware());

  runApp(
    Document(
      title: '108 MEDZ',
      meta: {
        'viewport': 'width=device-width, initial-scale=1.0',
        'description': 'Affordable medicines and skincare delivered to your doorstep.',
      },
      head: [
        link(href: 'styles.css', rel: 'stylesheet'),
        // This is critical: It loads the compiled JS that runs your logic
        script(src: 'main.client.dart.js', defer: true),
        link(
            href: "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap",
            rel: "stylesheet"),
        link(
            href: "https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0",
            rel: "stylesheet"),
      ],
      // Use the body component from your app.dart
      body: App(),
    ),
  );
}
