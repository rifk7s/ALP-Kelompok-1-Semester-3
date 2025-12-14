<?php

namespace App\Http\Controllers;

use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\Request;
use App\Models\HppPrice;
use Illuminate\Validation\Rule;

#[Group('HPP Prices', 'Harga HPP per kategori/varietas', weight: 35)]
class HppPriceController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = HppPrice::with('category');
        
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }
        
        return response()->json($query->get());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'category_id' => 'required|exists:categories,id',
            'variety' => 'nullable|string',
            'price_per_kg' => 'required|numeric|min:0',
        ]);

        $hppPrice = HppPrice::create([
            'category_id' => $validated['category_id'],
            'variety' => $validated['variety'] ?? 'Standard',
            'price_per_kg' => $validated['price_per_kg'],
            'source' => 'Badan Pangan Nasional (Bulog)',
            'effective_date' => now()->toDateString(),
        ]);

        return response()->json(['message' => 'HPP Price created successfully', 'hppPrice' => $hppPrice], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(HppPrice $hppPrice)
    {
        return response()->json($hppPrice->load('category'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $hppPrice = HppPrice::findOrFail($id);

        $validated = $request->validate([
            'variety' => 'sometimes|string',
            'price_per_kg' => 'sometimes|numeric|min:0',
        ]);

        $hppPrice->update([
            'variety' => $validated['variety'] ?? $hppPrice->variety,
            'price_per_kg' => $validated['price_per_kg'],
            'effective_date' => now()->toDateString(),
        ]);

        return response()->json($hppPrice);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        HppPrice::findOrFail($id)->delete();

        return response()->json(['message' => 'Variety deleted successfully'], 204);
    }
}
