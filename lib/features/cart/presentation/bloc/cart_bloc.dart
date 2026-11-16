import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddProductToCartEvent>(_onAddToCart);
    on<RemoveProductFromCartEvent>(_onRemoveFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
  }

  void _onAddToCart(AddProductToCartEvent event, Emitter<CartState> emit) {
    final existingIndex =
        state.items.indexWhere((item) => item.product.id == event.product.id);

    List<CartItem> updatedItems = List.from(state.items);
    if (existingIndex >= 0) {
      final currentItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = currentItem.copyWith(quantity: currentItem.quantity + 1);
    } else {
      updatedItems.add(CartItem(product: event.product, quantity: 1));
    }

    emit(state.copyWith(items: updatedItems));
  }

  void _onRemoveFromCart(RemoveProductFromCartEvent event, Emitter<CartState> emit) {
    final updatedItems =
        state.items.where((item) => item.product.id != event.productId).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _onUpdateQuantity(UpdateQuantityEvent event, Emitter<CartState> emit) {
    final existingIndex =
        state.items.indexWhere((item) => item.product.id == event.productId);

    if (existingIndex >= 0) {
      final currentItem = state.items[existingIndex];
      final newQuantity = currentItem.quantity + event.delta;

      List<CartItem> updatedItems = List.from(state.items);
      if (newQuantity <= 0) {
        updatedItems.removeAt(existingIndex);
      } else {
        updatedItems[existingIndex] = currentItem.copyWith(quantity: newQuantity);
      }
      emit(state.copyWith(items: updatedItems));
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) {
    emit(const CartState(items: []));
  }
}
