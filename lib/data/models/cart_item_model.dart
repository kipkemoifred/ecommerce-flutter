import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  final String? selectedColor;
  final String? selectedSize;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.selectedColor,
    this.selectedSize,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      product: ProductModel.fromMap(map['product'] ?? {}),
      quantity: map['quantity'] ?? 1,
      selectedColor: map['selectedColor'],
      selectedSize: map['selectedSize'],
    );
  }
}
