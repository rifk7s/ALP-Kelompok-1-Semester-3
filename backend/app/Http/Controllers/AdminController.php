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

        // Filter by status if provided, default to pending_payment
        $status = $request->input('status', 'pending_payment');
        
        $orders = Order::with(['buyer', 'orderItems.product'])
                    ->where('status', $status)
                    ->orderBy('created_at', 'desc')
                    ->get();

        return response()->json($orders);
    }

    /**
     * Confirm order payment
     */
    public function confirmPayment(Request $request, Order $order)
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
    public function show(Request $request, Order $order)
    {
        // Check if user is bumdes
        if ($request->user()->role !== 'bumdes') {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $order->load(['orderItems.product', 'payments']);

        return response()->json($order);
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
