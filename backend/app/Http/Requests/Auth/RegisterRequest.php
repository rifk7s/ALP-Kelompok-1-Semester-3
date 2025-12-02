<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
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
            'name' => ['required', 'string', 'max:255'], // User's name MUST be provided, be a string, and have a max length of 255 characters
            'email' => ['nullable', 'string', 'email', 'max:255', 'unique:users'], // User's email MUST be provided, be a valid email format, have's a max length of 255 characters, and be unique in the users table
            'phone' => ['required', 'string', 'max:15', 'unique:users'], // User's phone number MUST be provided, be a string, have a max length of 15 characters, and be unique in the users table
            'password' => ['required', 'string', 'min:8'], // User's password MUST be provided, be a string, have a minimum length of 8 characters, and must be confirmed (i.e., there should be a matching password_confirmation field)
            'address' => ['required', 'string', 'max:500'], // User's address is optional, but if provided, it must be a string with a max length of 500 characters
            'role' => ['required', 'in:pembeli,bumdes'], // User's role MUST be provided and be either 'pembeli' or 'bumdes'

        ];
    }
}
