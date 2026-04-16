import 'package:get/get.dart';

import '../models/demo_models.dart';
import '../services/session_service.dart';

class DemoApiClient extends GetConnect {
  final List<Product> _products = const [
    Product(
      id: 'ops-001',
      title: 'Migration Backlog Audit',
      category: ProductCategory.operations,
      price: 2400,
      description:
          'Scans route, controller, and DI hotspots to rank migration risk.',
      tags: ['audit', 'report', 'priority'],
      requiresApproval: false,
    ),
    Product(
      id: 'ops-002',
      title: 'Controller Decomposition Sprint',
      category: ProductCategory.operations,
      price: 5200,
      description:
          'Pairs a team lead with a mapper to split large controllers safely.',
      tags: ['controller', 'lifecycle', 'team'],
      requiresApproval: true,
    ),
    Product(
      id: 'diag-001',
      title: 'GetConnect Trace Pack',
      category: ProductCategory.diagnostics,
      price: 1800,
      description:
          'Surfaces auth hooks, decoders, and hidden request modifiers.',
      tags: ['network', 'auth', 'decoder'],
      requiresApproval: false,
    ),
    Product(
      id: 'diag-002',
      title: 'Bindings Lifetime Review',
      category: ProductCategory.diagnostics,
      price: 2100,
      description:
          'Maps route-scoped bindings and warns on leaked global access.',
      tags: ['bindings', 'di', 'routes'],
      requiresApproval: true,
    ),
    Product(
      id: 'sup-001',
      title: 'Manual Cutover Runbook',
      category: ProductCategory.support,
      price: 950,
      description:
          'Produces a human checklist for a staged GetX removal rollout.',
      tags: ['handoff', 'docs', 'ops'],
      requiresApproval: false,
    ),
  ];

  final List<OrderSummary> _orders = [
    OrderSummary(
      id: 'ORD-3102',
      actorEmail: 'lead@getxdrop.dev',
      lineTitles: ['GetConnect Trace Pack'],
      total: 1800,
      stage: OrderStage.approved,
      createdAt: DateTime(2026, 4, 9, 14, 20),
    ),
    OrderSummary(
      id: 'ORD-3119',
      actorEmail: 'lead@getxdrop.dev',
      lineTitles: ['Controller Decomposition Sprint'],
      total: 5200,
      stage: OrderStage.inReview,
      createdAt: DateTime(2026, 4, 13, 9, 15),
    ),
  ];

  int _orderSeed = 3200;

  @override
  void onInit() {
    httpClient.baseUrl = 'https://demo.getxdrop.dev';
    httpClient.timeout = const Duration(seconds: 2);
    httpClient.defaultContentType = 'application/json';
    httpClient.defaultDecoder = (map) => map;
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['x-demo-flow'] = 'sample-getx-app';
      final token = Get.find<SessionService>().accessToken.value;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });
    httpClient.addAuthenticator<dynamic>((request) async {
      final refreshedToken = Get.find<SessionService>().rotateToken();
      request.headers['Authorization'] = 'Bearer $refreshedToken';
      return request;
    });
    super.onInit();
  }

  Future<UserProfile> authenticate(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 420));

    if (password != 'pass1234' || !email.endsWith('@getxdrop.dev')) {
      throw Exception('Invalid credentials');
    }

    final isLead = email.startsWith('lead');
    return UserProfile(
      id: email,
      name: isLead ? 'Migration Lead' : 'Feature Analyst',
      email: email,
      role: isLead ? 'Program Manager' : 'Analyst',
      scopes: isLead
          ? ['audit:write', 'route:approve', 'order:review']
          : ['audit:read', 'order:create'],
    );
  }

  Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    return List<Product>.unmodifiable(_products);
  }

  Future<List<OrderSummary>> fetchOrders(String actorEmail) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    return _orders
        .where((order) => order.actorEmail == actorEmail)
        .toList(growable: false);
  }

  Future<OrderSummary> createOrder({
    required UserProfile actor,
    required List<CartLine> lines,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 460));

    final order = OrderSummary(
      id: 'ORD-${_orderSeed++}',
      actorEmail: actor.email,
      lineTitles: lines
          .map((line) => line.product.title)
          .toList(growable: false),
      total: lines.fold<double>(0, (sum, line) => sum + line.subtotal),
      stage: lines.any((line) => line.product.requiresApproval)
          ? OrderStage.inReview
          : OrderStage.queued,
      createdAt: DateTime.now(),
    );

    _orders.insert(0, order);
    return order;
  }
}
