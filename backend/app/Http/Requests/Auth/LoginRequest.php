<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
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
            // 'email' => ['required', 'string', 'email'], // Email MUST be provided and be valid format
            'phone' => ['required', 'string', 'max:15'], // Phone number MUST be provided and be a string
            'password' => ['required', 'string'], // Password MUST be provided and be a string
        ];
    }

    // Custom validation for user to fill email or phone. Uncomment the code if needed.

    // public function withValidator($validator)
    // {
    //     $validator->after(function ($validator) {
    //         if (!$this->filled('email') && !$this->filled('phone')) {
    //             $validator->errors()->add('credential', 'Either email or phone number must be provided.');
    //         }
    //     });
    // }
}
