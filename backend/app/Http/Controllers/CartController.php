<?php

namespace App\Http\Controllers;

use App\Http\Requests\Cart\CartRequest;
use App\Models\Cart;
use App\Models\Product;
use Illuminate\Http\Request;

class CartController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $cart = Cart::where('user_id', $request->user()->id)
                    ->with('product')
                    ->get();

        $subtotal = $cart->sum(function ($item) {
            return $item->quantity_kg * $item->product->price_per_kg;
        });

        $shipping_cost = 10000; // Fixed shipping
        $total = $subtotal + $shipping_cost;

        return response()->json([
            'items' => $cart,
            'subtotal' => $subtotal,
            'shipping_cost' => $shipping_cost,
            'total' => $total,
            'item_count' => $cart->count(),
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(CartRequest $request)
    {
        $user_id = $request->user()->id;
        $product_id = $request->product_id;
        $quantity_kg = $request->quantity_kg;

        // Check if product already in cart
        $existingCart = Cart::where('user_id', $user_id)
                            ->where('product_id', $product_id)
                            ->first();

        if ($existingCart) {
            // Update quantity
            $existingCart->update([
                'quantity_kg' => $existingCart->quantity_kg + $quantity_kg,
            ]);
            $cart = $existingCart;
        } else {
            // Create new cart item
            $cart = Cart::create([
                'user_id' => $user_id,
                'product_id' => $product_id,
                'quantity_kg' => $quantity_kg,
            ]);
        }

        $cart->load('product');

        return response()->json([
            'message' => 'Item added to cart successfully!',
            'cart_item' => $cart,
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(CartRequest $request, Cart $cart)
    {
        // Verify cart belongs to logged-in user
        if ($cart->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $cart->update([
            'quantity_kg' => $request->quantity_kg,
        ]);

        $cart->load('product');

        return response()->json([
            'message' => 'Cart item updated successfully!',
            'cart_item' => $cart,
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, Cart $cart)
    {
        // Verify cart belongs to logged-in user
        if ($cart->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $cart->delete();

        return response()->json([
            'message' => 'Item removed from cart successfully!',
        ]);
    }

    /**
     * Clear entire cart
     */
    public function clear(Request $request)
    {
        Cart::where('user_id', $request->user()->id)->delete();

        return response()->json([
            'message' => 'Cart cleared successfully!',
        ]);
    }
}
