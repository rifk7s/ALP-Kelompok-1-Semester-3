<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Order;
use App\Models\OrderItems;
use App\Models\Payment;
use App\Models\User;
use App\Models\Product;
use Carbon\Carbon;

class OrderSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get buyer users (role = 'pembeli')
        $buyers = User::where('role', 'pembeli')->get();
        if ($buyers->isEmpty()) {
            echo "No buyers found. Creating a test buyer...\n";
            $buyer = User::create([
                'name' => 'Test Buyer',
                'email' => 'buyer@test.com',
                'password' => bcrypt('password'),
                'role' => 'pembeli',
                'phone_number' => '081234567890',
            ]);
            $buyers = collect([$buyer]);
        }

        // Get all products
        $products = Product::all();
        if ($products->isEmpty()) {
            echo "No products found. Please seed products first.\n";
            return;
        }

        $now = Carbon::now();
        $orderCounter = 1;

        // Create orders with different statuses
        $orderData = [
            // Pending payment orders (recent)
            [
                'status' => 'pending_payment',
                'notes' => 'Mohon transfer sesuai nominal yang tertera',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subHours(2),
                ],
                'payment_status' => 'pending',
            ],
            [
                'status' => 'pending_payment',
                'notes' => 'Segera upload bukti pembayaran setelah transfer',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subHours(5),
                ],
                'payment_status' => 'pending',
            ],
            [
                'status' => 'pending_payment',
                'notes' => null,
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subHours(8),
                ],
                'payment_status' => 'pending',
            ],

            // Paid orders (waiting to be processed)
            [
                'status' => 'paid',
                'notes' => 'Pembayaran sudah dikonfirmasi, menunggu proses pengemasan',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(1)->subHours(2),
                    'paid_at' => $now->copy()->subDays(1),
                ],
                'payment_status' => 'verified',
            ],
            [
                'status' => 'paid',
                'notes' => 'Terima kasih atas pembayaran yang tepat waktu',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(1)->subHours(5),
                    'paid_at' => $now->copy()->subDays(1)->subHours(3),
                ],
                'payment_status' => 'verified',
            ],

            // Processing orders
            [
                'status' => 'processing',
                'notes' => 'Pesanan sedang dikemas dengan hati-hati',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(2)->subHours(4),
                    'paid_at' => $now->copy()->subDays(2),
                    'processing_at' => $now->copy()->subDays(1)->subHours(12),
                ],
                'payment_status' => 'verified',
            ],
            [
                'status' => 'processing',
                'notes' => 'Produk akan segera dikirim',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(2)->subHours(8),
                    'paid_at' => $now->copy()->subDays(2)->subHours(4),
                    'processing_at' => $now->copy()->subDays(2),
                ],
                'payment_status' => 'verified',
            ],
            [
                'status' => 'processing',
                'notes' => null,
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(3),
                    'paid_at' => $now->copy()->subDays(2)->subHours(20),
                    'processing_at' => $now->copy()->subDays(2)->subHours(12),
                ],
                'payment_status' => 'verified',
            ],

            // Shipped orders
            [
                'status' => 'shipped',
                'notes' => 'Pesanan sudah dikirim melalui kurir. Estimasi tiba 2-3 hari.',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(5),
                    'paid_at' => $now->copy()->subDays(4)->subHours(20),
                    'processing_at' => $now->copy()->subDays(4),
                    'shipped_at' => $now->copy()->subDays(3),
                ],
                'payment_status' => 'verified',
            ],
            [
                'status' => 'shipped',
                'notes' => 'Harap pantau nomor resi untuk tracking pengiriman',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(6),
                    'paid_at' => $now->copy()->subDays(5)->subHours(18),
                    'processing_at' => $now->copy()->subDays(5),
                    'shipped_at' => $now->copy()->subDays(4),
                ],
                'payment_status' => 'verified',
            ],
            [
                'status' => 'shipped',
                'notes' => 'Produk dalam perjalanan',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(7),
                    'paid_at' => $now->copy()->subDays(6)->subHours(16),
                    'processing_at' => $now->copy()->subDays(6),
                    'shipped_at' => $now->copy()->subDays(5),
                ],
                'payment_status' => 'verified',
            ],

            // Completed orders (this month)
            [
                'status' => 'completed',
                'notes' => 'Terima kasih atas pesanannya! Semoga puas dengan produk kami.',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(10),
                    'paid_at' => $now->copy()->subDays(9)->subHours(20),
                    'processing_at' => $now->copy()->subDays(9),
                    'shipped_at' => $now->copy()->subDays(8),
                    'completed_at' => $now->copy()->subDays(5),
                ],
                'payment_status' => 'verified',
            ],
            [
                'status' => 'completed',
                'notes' => 'Pesanan telah sampai dengan selamat. Ditunggu order berikutnya!',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(12),
                    'paid_at' => $now->copy()->subDays(11)->subHours(18),
                    'processing_at' => $now->copy()->subDays(11),
                    'shipped_at' => $now->copy()->subDays(10),
                    'completed_at' => $now->copy()->subDays(7),
                ],
                'payment_status' => 'verified',
            ],
            [
                'status' => 'completed',
                'notes' => null,
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(15),
                    'paid_at' => $now->copy()->subDays(14)->subHours(16),
                    'processing_at' => $now->copy()->subDays(14),
                    'shipped_at' => $now->copy()->subDays(13),
                    'completed_at' => $now->copy()->subDays(10),
                ],
                'payment_status' => 'verified',
            ],
            [
                'status' => 'completed',
                'notes' => 'Pesanan sesuai harapan, produk berkualitas',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(8),
                    'paid_at' => $now->copy()->subDays(7)->subHours(22),
                    'processing_at' => $now->copy()->subDays(7)->subHours(12),
                    'shipped_at' => $now->copy()->subDays(6)->subHours(8),
                    'completed_at' => $now->copy()->subDays(3),
                ],
                'payment_status' => 'verified',
            ],
            [
                'status' => 'completed',
                'notes' => 'Pengiriman cepat, produk fresh',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(6),
                    'paid_at' => $now->copy()->subDays(5)->subHours(20),
                    'processing_at' => $now->copy()->subDays(5)->subHours(10),
                    'shipped_at' => $now->copy()->subDays(4)->subHours(12),
                    'completed_at' => $now->copy()->subDays(2),
                ],
                'payment_status' => 'verified',
            ],

            // Rejected orders
            [
                'status' => 'rejected',
                'notes' => 'Pembayaran tidak sesuai dengan jumlah yang tertera',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(3)->subHours(10),
                    'rejected_at' => $now->copy()->subDays(3)->subHours(8),
                ],
                'payment_status' => 'rejected',
            ],
            [
                'status' => 'rejected',
                'notes' => 'Bukti pembayaran tidak valid',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(4)->subHours(6),
                    'rejected_at' => $now->copy()->subDays(4)->subHours(2),
                ],
                'payment_status' => 'rejected',
            ],
            [
                'status' => 'rejected',
                'notes' => 'Melewati batas waktu pembayaran',
                'timestamps' => [
                    'pending_payment_at' => $now->copy()->subDays(8),
                    'rejected_at' => $now->copy()->subDays(7),
                ],
                'payment_status' => 'rejected',
            ],
        ];

        foreach ($orderData as $data) {
            // Select random buyer
            $buyer = $buyers->random();
            
            // Select 1-3 random products
            $selectedProducts = $products->random(rand(1, 3));
            
            // Calculate totals
            $subtotal = 0;
            foreach ($selectedProducts as $product) {
                $quantity = rand(1, 5);
                $price = $product->price_per_kg;
                $subtotal += $price * $quantity;
            }
            
            $shippingCost = rand(10000, 50000);
            $total = $subtotal + $shippingCost;

            // Create unique order number with timestamp
            $orderNumber = 'ORD-' . date('Ymd') . '-' . str_pad($orderCounter, 3, '0', STR_PAD_LEFT) . substr(uniqid(), -3);
            $order = Order::create([
                'order_number' => $orderNumber,
                'buyer_id' => $buyer->id,
                'subtotal' => $subtotal,
                'shipping_cost' => $shippingCost,
                'total' => $total,
                'status' => $data['status'],
                'shipping_address' => 'Jl. Test No. ' . rand(1, 100) . ', Kota Test, Provinsi Test, 12345',
                'notes' => $data['notes'],
                'payment_deadline' => $data['timestamps']['pending_payment_at']->copy()->addDays(1),
                'estimated_delivery' => isset($data['timestamps']['shipped_at']) 
                    ? $data['timestamps']['shipped_at']->copy()->addDays(3) 
                    : null,
                'pending_payment_at' => $data['timestamps']['pending_payment_at'] ?? null,
                'paid_at' => $data['timestamps']['paid_at'] ?? null,
                'processing_at' => $data['timestamps']['processing_at'] ?? null,
                'shipped_at' => $data['timestamps']['shipped_at'] ?? null,
                'completed_at' => $data['timestamps']['completed_at'] ?? null,
                'rejected_at' => $data['timestamps']['rejected_at'] ?? null,
            ]);

            // Create order items
            foreach ($selectedProducts as $product) {
                $quantity = rand(1, 5);
                $price = $product->price_per_kg;
                
                OrderItems::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'quantity_kg' => $quantity,
                    'price_per_kg' => $price,
                    'subtotal' => $price * $quantity,
                ]);
            }

            // Create payment record
            Payment::create([
                'order_id' => $order->id,
                'amount' => $total,
                'status' => $data['payment_status'],
                'proof_image' => $data['payment_status'] !== 'pending' 
                    ? 'https://via.placeholder.com/400x300?text=Payment+Proof' 
                    : '',
            ]);

            $orderCounter++;
        }

        echo "Successfully seeded " . count($orderData) . " orders with various statuses!\n";
    }
}
