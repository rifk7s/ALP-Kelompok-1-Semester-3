<?php

namespace App\Http\Controllers;

use Dedoc\Scramble\Attributes\Group;
use App\Models\Category;
use App\Http\Requests\Product\CreateCategoryRequest;
use App\Http\Requests\Product\UpdateCategoryRequest;
// use Illuminate\Http\Request;

#[Group('Products', 'Manajemen kategori produk', weight: 31)]
class CategoryController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return response()->json(Category::all());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(CreateCategoryRequest $request)
    {
        $category = Category::create([
            'name' => $request->name,
            'slug' => $request->slug,
            'icon' => $request->icon,
        ]);

        return response()->json([
            'message' => 'Category created successfully!',
            'category' => $category
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Category $category)
    {
        return response()->json($category);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateCategoryRequest $request, Category $category)
    {
        $category->update([
            'name' => $request->name ?? $category->name,
            'slug' => $request->slug ?? $category->slug,
            'icon' => $request->icon ?? $category->icon,
        ]);

        return response()->json([
            'message' => 'Category updated successfully!',
            'category' => $category
        ]);
    }
    

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Category $category)
    {
        $category->delete();

        return response()->json([
            'message' => 'Category deleted successfully!'
        ], 204);
    }
}
