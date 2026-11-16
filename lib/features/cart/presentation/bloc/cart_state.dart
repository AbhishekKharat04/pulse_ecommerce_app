import 'package:equatable/equatable.dart';
import '../domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * 0.08; // 8% standard tax

  double get deliveryFee => subtotal > 100 || subtotal == 0 ? 0.0 : 15.0;

  double get grandTotal => subtotal + tax + deliveryFee;

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
