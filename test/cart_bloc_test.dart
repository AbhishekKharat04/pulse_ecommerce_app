import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:pulse_ecommerce_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:pulse_ecommerce_app/features/cart/presentation/bloc/cart_event.dart';
import 'package:pulse_ecommerce_app/features/cart/presentation/bloc/cart_state.dart';
import 'package:pulse_ecommerce_app/features/products/domain/entities/product.dart';

void main() {
  group('CartBloc Unit Tests', () {
    late CartBloc cartBloc;

    const sampleProduct = Product(
      id: 1,
      title: 'Fjallraven Backpack',
      price: 109.95,
      description: 'Your perfect pack for everyday use and walks in the forest.',
      category: "men's clothing",
      image: 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
      ratingRate: 3.9,
      ratingCount: 120,
    );

    setUp(() {
      cartBloc = CartBloc();
    });

    tearDown(() {
      cartBloc.close();
    });

    test('Initial state should have empty items and zero total', () {
      expect(cartBloc.state, equals(const CartState()));
      expect(cartBloc.state.items.isEmpty, isTrue);
      expect(cartBloc.state.totalQuantity, 0);
      expect(cartBloc.state.subtotal, 0.0);
    });

    test('AddProductToCartEvent adds a new item to cart', () async {
      cartBloc.add(const AddProductToCartEvent(sampleProduct));

      await expectLater(
        cartBloc.stream,
        emits(
          predicate<CartState>((state) {
            return state.items.length == 1 &&
                state.items.first.product.id == 1 &&
                state.items.first.quantity == 1 &&
                state.totalQuantity == 1;
          }),
        ),
      );
    });

    test('Adding same product twice increments quantity instead of adding duplicate', () async {
      cartBloc.add(const AddProductToCartEvent(sampleProduct));
      cartBloc.add(const AddProductToCartEvent(sampleProduct));

      await expectLater(
        cartBloc.stream,
        emitsInOrder([
          predicate<CartState>((s) => s.totalQuantity == 1 && s.items.length == 1),
          predicate<CartState>((s) => s.totalQuantity == 2 && s.items.length == 1),
        ]),
      );
    });

    test('UpdateQuantityEvent decrements and removes when quantity reaches 0', () async {
      cartBloc.add(const AddProductToCartEvent(sampleProduct));
      await Future.delayed(Duration.zero);

      cartBloc.add(const UpdateQuantityEvent(1, -1));

      await expectLater(
        cartBloc.stream,
        emits(
          predicate<CartState>((state) => state.items.isEmpty && state.totalQuantity == 0),
        ),
      );
    });
  });
}
