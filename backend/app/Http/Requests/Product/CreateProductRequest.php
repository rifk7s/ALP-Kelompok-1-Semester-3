<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class CreateProductRequest extends FormRequest
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
            'name' => ['required', 'string', 'max:255'],
            'variety' => ['required', 'string', 'max:255'],
            'harvest_date' => ['required', 'date'],
            'storage_days' => ['required', 'integer', 'min:0'],
            'price_per_kg' => ['required', 'numeric', 'min:0'],
            'stock_kg' => ['required', 'numeric', 'min:0'],
            'sold_kg' => ['nullable', 'numeric', 'min:0'],
            'description' => ['nullable', 'string'],
            'status' => ['nullable', 'in:active,sold_out'],
            'category_id' => ['required', 'exists:categories,id'],
            'petani_id' => ['nullable', 'exists:petani_data,id'],
            'images' => ['nullable', 'array'],
            'images.*' => ['image', 'mimes:jpeg,png,jpg,gif', 'max:2048'],
        ];
    }
}
