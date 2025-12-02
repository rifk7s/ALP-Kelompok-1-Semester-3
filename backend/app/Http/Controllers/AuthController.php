<?php

namespace App\Http\Controllers;
// use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
// use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    // REGISTER
    public function register(RegisterRequest $request)
    {
        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'phone'    => $request->phone,
            'password' => Hash::make($request->password),
            'role'     => $request->role,
            'address'  => $request->address,
            'is_active' => true,
        ]);

        return response()->json([
            'message' => 'User registered successfully!',
            'user'    => $user
        ], 201);
    }

    // LOGIN
    public function login(LoginRequest $request)
    {       
        $user = User::where('phone', $request->phone)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message'     => 'Login success!',
            'access_token'=> $token,
            'token_type'  => 'Bearer',
            'user'        => $user,
        ]);
    }

    // LOGOUT
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully'
        ]);
    }

    // ME - Get current user
    public function me(Request $request)
    {
        return response()->json($request->user());
    }
}
