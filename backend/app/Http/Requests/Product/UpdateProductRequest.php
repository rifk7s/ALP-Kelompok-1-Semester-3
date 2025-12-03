<?php

namespace App\Http\Requests\Product;
use Illuminate\Validation\Rule;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProductRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'variety' => ['sometimes', 'string', 'max:255'],
            'harvest_date' => ['sometimes', 'date', Rule::unique('products')->ignore($this->product->id)],
            'storage_days' => ['sometimes', 'integer', 'min:0'],
            'price_per_kg' => ['sometimes', 'numeric', 'min:0'],
            'stock_kg' => ['sometimes', 'numeric', 'min:0'],
            'sold_kg' => ['sometimes', 'numeric', 'min:0'],
            'description' => ['sometimes', 'string'],
            'status' => ['sometimes', 'in:active,sold_out'],
            'category_id' => ['sometimes', 'exists:categories,id'],
        ];
    }
}
