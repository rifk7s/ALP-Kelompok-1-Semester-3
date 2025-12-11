<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Order;

class AdminController extends Controller
{
    /**
     * Display orders with pending status
     */
    public function index(Request $request)
    {
        $query = Order::with(['buyer', 'orderItems.product']);

        // Filter by status if provided, default to pending_payment
        $status = $request->input('status', 'pending_payment');
        $query->where('status', $status);

        return response()->json($query->orderBy('created_at', 'desc')->get());
    }

    /**
     * Confirm order payment
     */
    public function confirmOrderPayment(Request $request, Order $order)
    {
        // Verify cart belongs to logged-in user
        if ($order->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $order->update([
            'status' => 'paid',
        ]);

        $order->load(['buyer', 'orderItems.product']);

        return response()->json([
            'message' => 'Order payment confirmed successfully',
            'order' => $order,
        ]);
    }

    /**
     * Display the specified resource.
     */
    // public function show(string $id)
    // {
    //     //
    // }

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
