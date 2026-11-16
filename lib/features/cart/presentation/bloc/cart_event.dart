import 'package:equatable/equatable.dart';
import '../../products/domain/entities/product.dart';
import '../domain/entities/cart_item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddProductToCartEvent extends CartEvent {
  final Product product;
  const AddProductToCartEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveProductFromCartEvent extends CartEvent {
  final int productId;
  const RemoveProductFromCartEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateQuantityEvent extends CartEvent {
  final int productId;
  final int delta; // +1 or -1
  const UpdateQuantityEvent(this.productId, this.delta);

  @override
  List<Object?> get props => [productId, delta];
}

class ClearCartEvent extends CartEvent {}
