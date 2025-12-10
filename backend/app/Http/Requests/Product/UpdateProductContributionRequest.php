<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProductContributionRequest extends FormRequest
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
            'contributed_kg' => ['sometimes', 'numeric', 'min:0.1'],
            'remaining_kg' => ['sometimes', 'numeric', 'min:0'],
            'entry_date' => ['sometimes', 'date'],
            'harvest_date' => ['sometimes', 'date', 'after_or_equal:entry_date'],
            'product_id' => ['sometimes', 'exists:products,id'],
            'petani_id' => ['sometimes', 'exists:petani_data,id'],
        ];
    }
}
