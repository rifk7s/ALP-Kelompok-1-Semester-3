<?php

namespace App\Http\Controllers;

use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\Request;
use App\Models\Order;
use App\Services\NotificationService;

#[Group('Admin', 'Operasi admin (BUMDes) untuk pesanan', weight: 90)]
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

        // Filter by status if provided, otherwise return all orders
        $status = $request->input('status');
        
        $query = Order::with(['buyer', 'orderItems.product.productImages', 'payments']);
        
        if ($status) {
            $query->where('status', $status);
        }
        
        $orders = $query->get();

        // Separate orders by status groups
        $completedOrRejected = $orders->filter(function ($order) {
            return in_array($order->status, ['completed', 'rejected']);
        })->sortByDesc(function ($order) {
            // Use completed_at for completed orders, rejected_at for rejected orders
            if ($order->status === 'completed') {
                return strtotime($order->completed_at ?? $order->created_at);
            } elseif ($order->status === 'rejected') {
                return strtotime($order->rejected_at ?? $order->created_at);
            }
            return strtotime($order->created_at);
        })->values();

        $otherOrders = $orders->filter(function ($order) {
            return !in_array($order->status, ['completed', 'rejected']);
        })->sortByDesc(function ($order) {
            return strtotime($order->created_at);
        })->values();

        // Merge: other orders first, then completed/rejected
        $sortedOrders = $otherOrders->concat($completedOrRejected);

        return response()->json($sortedOrders);
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
            'paid_at' => now(),
        ]);

        // Update payment status to verified
        $payment = $order->payments;
        if ($payment) {
            $payment->update([
                'status' => 'verified',
            ]);
        }

        // Notify buyer about payment confirmation
        NotificationService::notifyOrderStatusChange($order, 'pending_payment', 'paid');

        $order->load(['buyer', 'orderItems.product.productImages', 'payments']);

        return response()->json([
            'message' => 'Order payment confirmed successfully',
            'order' => $order,
        ]);
    }

    /**
     * Mark order as processing
     */
    public function markProcessing(Request $request, Order $order)
    {
        if ($request->user()->role !== 'bumdes') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($order->status !== 'paid') {
            return response()->json(['message' => 'Order must be paid first'], 400);
        }

        $order->update([
            'status' => 'processing',
            'processing_at' => now(),
        ]);

        // Notify buyer that order is being processed
        NotificationService::notifyOrderStatusChange($order, 'paid', 'processing');

        $order->load(['buyer', 'orderItems.product.productImages']);

        return response()->json([
            'message' => 'Order marked as processing',
            'order' => $order,
        ]);
    }

    /**
     * Mark order as shipped
     */
    public function markShipped(Request $request, Order $order)
    {
        if ($request->user()->role !== 'bumdes') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($order->status !== 'processing') {
            return response()->json(['message' => 'Order must be processing first'], 400);
        }

        $order->update([
            'status' => 'shipped',
            'shipped_at' => now(),
        ]);

        // Notify buyer that order has been shipped
        NotificationService::notifyOrderStatusChange($order, 'processing', 'shipped');

        $order->load(['buyer', 'orderItems.product.productImages']);

        return response()->json([
            'message' => 'Order marked as shipped',
            'order' => $order,
        ]);
    }

    /**
     * Mark order as completed
     */
    public function markCompleted(Request $request, Order $order)
    {
        if ($request->user()->role !== 'bumdes') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($order->status !== 'shipped') {
            return response()->json(['message' => 'Order must be shipped first'], 400);
        }

        $order->update([
            'status' => 'completed',
            'completed_at' => now(),
        ]);

        $order->load(['buyer', 'orderItems.product.productImages']);

        return response()->json([
            'message' => 'Order marked as completed',
            'order' => $order,
        ]);
    }

    /**
     * Reject order payment
     */
    public function rejectPayment(Request $request, Order $order)
    {
        if ($request->user()->role !== 'bumdes') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($order->status !== 'pending_payment') {
            return response()->json(['message' => 'Only pending payment orders can be rejected'], 400);
        }

        // Update order status to rejected
        $order->update([
            'status' => 'rejected',
            'rejected_at' => now(),
        ]);

        // Update payment status to rejected
        $payment = $order->payments;
        if ($payment) {
            $payment->update([
                'status' => 'rejected',
            ]);
        }

        // Notify buyer about rejection
        NotificationService::notifyOrderStatusChange($order, 'pending_payment', 'rejected');

        $order->load(['buyer', 'orderItems.product.productImages', 'payments']);

        return response()->json([
            'message' => 'Order payment rejected',
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

        $order->load(['orderItems.product.productImages', 'payments']);

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
