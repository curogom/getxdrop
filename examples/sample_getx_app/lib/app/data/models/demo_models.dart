enum ProductCategory { all, operations, diagnostics, support }

extension ProductCategoryX on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.all:
        return 'All';
      case ProductCategory.operations:
        return 'Operations';
      case ProductCategory.diagnostics:
        return 'Diagnostics';
      case ProductCategory.support:
        return 'Support';
    }
  }
}

enum OrderStage { queued, inReview, approved }

extension OrderStageX on OrderStage {
  String get label {
    switch (this) {
      case OrderStage.queued:
        return 'Queued';
      case OrderStage.inReview:
        return 'In review';
      case OrderStage.approved:
        return 'Approved';
    }
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.scopes,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> scopes;
}

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.description,
    required this.tags,
    required this.requiresApproval,
  });

  final String id;
  final String title;
  final ProductCategory category;
  final double price;
  final String description;
  final List<String> tags;
  final bool requiresApproval;
}

class CartLine {
  const CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  CartLine copyWith({int? quantity}) {
    return CartLine(product: product, quantity: quantity ?? this.quantity);
  }
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.actorEmail,
    required this.lineTitles,
    required this.total,
    required this.stage,
    required this.createdAt,
  });

  final String id;
  final String actorEmail;
  final List<String> lineTitles;
  final double total;
  final OrderStage stage;
  final DateTime createdAt;
}
