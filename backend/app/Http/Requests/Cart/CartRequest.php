<?php

namespace App\Http\Requests\Cart;

use Illuminate\Foundation\Http\FormRequest;

class CartRequest extends FormRequest
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
        // For update requests, product_id is not required
        $isUpdate = $this->route('cart') !== null;
        
        return [
            'product_id' => $isUpdate ? ['sometimes', 'exists:products,id'] : ['required', 'exists:products,id'],
            'quantity_kg' => ['required', 'numeric', 'min:0.1'],
        ];
    }
}
