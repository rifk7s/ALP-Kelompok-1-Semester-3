<?php

namespace App\Http\Controllers;
// use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
// use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Dedoc\Scramble\Attributes\Group;
use Kreait\Firebase\Auth as FirebaseAuth;
use Kreait\Firebase\Factory;

#[Group('Authentication', 'Registrasi, login, dan token akses', weight: 10)]
class AuthController extends Controller
{
    // REGISTER
    /**
     * @unauthenticated
     */
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
    /**
     * @unauthenticated
     */
    public function login(LoginRequest $request)
    {       
        $user = User::where('phone', $request->phone)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        $factory = (new Factory)
            ->withServiceAccount(base_path(env('FIREBASE_CREDENTIALS')))
            ->withProjectId(env('FIREBASE_PROJECT_ID'));

        $firebaseAuth = $factory->createAuth();

        $firebaseCustomToken = $firebaseAuth->createCustomToken((string) $user->id);

        return response()->json([
            'message'     => 'Login success!',
            'access_token'=> $token,
            'token_type'  => 'Bearer',
            'user'        => $user,
            'firebase_custom_token' => $firebaseCustomToken->toString(),
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
