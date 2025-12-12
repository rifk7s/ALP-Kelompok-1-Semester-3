<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use App\Models\Cart;
use App\Models\Order;
use App\Models\OrderItems;
use App\Models\Payment;


class OrderController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $orders = Order::where('buyer_id', $request->user()->id)
                      ->with(['orderItems.product'])
                      ->orderBy('created_at', 'desc')
                      ->get();

        return response()->json($orders);
    }

    /**
     * Checkout - Convert cart to order
     */
    public function checkout(Request $request)
    {
        $validated = $request->validate([
            'shipping_address' => 'sometimes|string|max:500',
            'shipping_cost' => 'sometimes|numeric|min:0',
            'service_fee' => 'sometimes|numeric|min:0',
        ]);

        $user = $request->user();

        // Use provided address or fallback to user's address
        $shippingAddress = $validated['shipping_address'] ?? $user->address;

        // Get cart items. Contains them in a list
        $cartItems = Cart::where('user_id', $user->id)
                        ->with('product')
                        ->get();

        if ($cartItems->isEmpty()) {
            return response()->json([
                'message' => 'Cart is empty',
            ], 400);
        }

        // Calculate totals
        $subtotal = $cartItems->sum(function ($item) {
            return $item->quantity_kg * $item->product->price_per_kg;
        });

        // Use shipping cost from frontend or default to 10000
        $shipping_cost = $validated['shipping_cost'] ?? 10000;
        $service_fee = $validated['service_fee'] ?? 0;
        $total = $subtotal + $shipping_cost + $service_fee;

        try {
            // Use database transaction. Used if any part fails, all changes are rolled back
            DB::beginTransaction();

            // Create order
            $order = Order::create([
                'order_number' => 'ORD-' . strtoupper(Str::random(10)), // strtoupper for generating random string for unique order numbers
                'buyer_id' => $user->id,
                'subtotal' => $subtotal,
                'shipping_cost' => $shipping_cost,
                'total' => $total,
                'status' => 'pending_payment',
                'shipping_address' => $shippingAddress,
                'payment_deadline' => now()->addHours(24), // 24 hour payment window
                'estimated_delivery' => now()->addDays(7), // 7 days estimate
            ]);

            // Create order items from cart
            foreach ($cartItems as $cartItem) {
                OrderItems::create([
                    'order_id' => $order->id,
                    'product_id' => $cartItem->product_id,
                    'quantity_kg' => $cartItem->quantity_kg,
                    'price_per_kg' => $cartItem->product->price_per_kg,
                    'subtotal' => $cartItem->quantity_kg * $cartItem->product->price_per_kg,
                ]);
            }

            // Create payment record with pending status
            Payment::create([
                'order_id' => $order->id,
                'amount' => $total,
                'status' => 'pending',
                'proof_image' => '', // Will be uploaded later by user
            ]);

            // Clear the cart after successful order creation
            Cart::where('user_id', $user->id)->delete();

            DB::commit();

            // Load relationships for response
            $order->load(['orderItems.product', 'buyer']);

            return response()->json([
                'message' => 'Order created successfully!',
                'order' => $order,
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'message' => 'Failed to create order',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     */
    // public function store(Request $request)
    // {
    //     //
    // }

    /**
     * Display the specified order.
     */
    public function show(Request $request, Order $order)
    {
        // Verify order belongs to user
        if ($order->buyer_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $order->load(['orderItems.product', 'payments']);

        return response()->json($order);
    }

    /**
     * Check order payment status (for polling)
     */
    public function checkStatus(Request $request, Order $order)
    {
        // Verify order belongs to user
        if ($order->buyer_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        return response()->json([
            'order_id' => $order->id,
            'order_number' => $order->order_number,
            'status' => $order->status,
            'is_paid' => $order->status === 'paid',
            'total' => $order->total,
        ]);
    }

    /**
     * Cancel order (only if pending_payment)
     */
    public function cancel(Request $request, Order $order)
    {
        if ($order->buyer_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        if ($order->status !== 'pending_payment') {
            return response()->json([
                'message' => 'Cannot cancel order with status: ' . $order->status,
            ], 400);
        }

        $order->update(['status' => 'cancelled']);

        return response()->json([
            'message' => 'Order cancelled successfully',
            'order' => $order,
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    // public function update(Request $request, string $id)
    // {
    //     //
    // }

    /**
     * Remove the specified resource from storage.
     */
    // public function destroy(string $id)
    // {
    //     //
    // }
}
