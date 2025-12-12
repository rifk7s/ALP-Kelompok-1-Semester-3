<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Order;
use App\Helpers\NotificationHelper;

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
        
        $query = Order::with(['buyer', 'orderItems.product.productImages', 'payments'])
                    ->orderBy('created_at', 'desc');
        
        if ($status) {
            $query->where('status', $status);
        }
        
        $orders = $query->get();

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
            'paid_at' => now(),
        ]);

        // Update payment status to verified
        $payment = $order->payments;
        if ($payment) {
            $payment->update([
                'status' => 'verified',
            ]);
        }

        // Create notification for the buyer to know his or her payment has been confirmed by admin
        NotificationHelper::sendNotification(
            $order->buyer_id,
            'Payment Confirmed',
            'Your payment for Order #' . $order->id . ' has been confirmed.',
            'payment',
            $order->id
        );

        $order->load(['buyer', 'orderItems.product', 'payments']);

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
        NotificationHelper::sendNotification(
            $order->buyer_id,
            'Order Processing',
            'Your Order #' . $order->id . ' is now being processed.',
            'order',
            $order->id
        );

        $order->load(['buyer', 'orderItems.product']);

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
        NotificationHelper::sendNotification(
            $order->buyer_id,
            'Order Shipped',
            'Your Order #' . $order->id . ' has been shipped.',
            'order',
            $order->id
        );

        $order->load(['buyer', 'orderItems.product']);

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

        // Notify buyer that order is completed
        NotificationHelper::sendNotification(
            $order->buyer_id,
            'Order Completed',
            'Your Order #' . $order->id . ' has been completed. Thank you for shopping!',
            'order',
            $order->id
        );

        $order->load(['buyer', 'orderItems.product']);

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

        // Notify buyer that payment was rejected
        NotificationHelper::sendNotification(
            $order->buyer_id,
            'Payment Rejected',
            'Your payment for Order #' . $order->id . ' has been rejected. Please contact support.',
            'payment',
            $order->id
        );

        $order->load(['buyer', 'orderItems.product', 'payments']);

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
