<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class ProductContributionRequest extends FormRequest
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
            'contributed_kg' => ['required', 'numeric', 'min:0.1'],
            'remaining_kg' => ['required', 'numeric', 'min:0'],
            'entry_date' => ['required', 'date', 'after_or_equal:harvest_date'],
            'harvest_date' => ['required', 'date'],
            'product_id' => ['required', 'exists:products,id'],
            'petani_id' => ['required', 'exists:petani_data,id'],
        ];
    }
}
