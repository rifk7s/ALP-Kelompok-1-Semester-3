<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PaymentController extends Controller
{
    /**
     * Upload payment proof for an order
     */
    public function uploadProof(Request $request, $orderId)
    {
        $request->validate([
            'proof_image' => 'required|image|mimes:jpeg,png,jpg|max:5120', // 5MB max
        ]);

        // Find the order and verify it belongs to the user
        $order = Order::where('id', $orderId)
            ->where('buyer_id', auth()->id())
            ->firstOrFail();

        // Find the payment record for this order
        $payment = Payment::where('order_id', $order->id)->firstOrFail();

        // Delete old image if exists
        if ($payment->proof_image && Storage::disk('public')->exists($payment->proof_image)) {
            Storage::disk('public')->delete($payment->proof_image);
        }

        // Store the new image
        $imagePath = $request->file('proof_image')->store('payment_proofs', 'public');

        // Update payment record
        $payment->update([
            'proof_image' => $imagePath,
            'status' => 'pending', // Keep as pending until admin confirms
        ]);

        return response()->json([
            'message' => 'Payment proof uploaded successfully',
            'payment' => $payment,
        ], 200);
    }
}
