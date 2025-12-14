<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Payment;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    /**
     * Upload payment proof for an order
     */
    public function uploadProof(Request $request, $orderId)
    {
        return response()->json([
            'message' => 'Payment proof upload is disabled',
        ], 410);
    }
}
