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
        // Check if user is bumdes
        if ($request->user()->role !== 'bumdes') {
            return response()->json([
                'message' => 'Unauthorized. Admin access required.',
            ], 403);
        }

        $orders = Order::with(['buyer', 'orderItems.product'])
                    ->where('status', 'pending_payment')
                    ->orderBy('created_at', 'desc')
                    ->get();

        return response()->json($orders);
    }

    /**
     * Confirm order payment
     */
    public function confirmOrderPayment(Request $request, Order $order)
    {
        // Check if user is bumdes
        if ($request->user()->role !== 'bumdes') {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        if ($order->status !== 'pending_payment') {
            return response()->json([
                'message' => 'Order is not pending payment',
            ], 400);
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
