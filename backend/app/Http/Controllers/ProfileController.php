<?php

namespace App\Http\Controllers;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    /**
     * Display the specified resource.
     */
    public function userrn(Request $request)
    {
        return response()->json($request->user());
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, User $user)
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'max:255', 'string'],
            'phone' => ['sometimes', 'max:15', 'string', 'unique:users', Rule::unique('users')->ignore($user->id)],
            'address' => 'sometimes|max:500',
        ]);

        $user->update($validated);
        return response()->json(['message' => 'User updated successfully', 'data' => $user]);
    }

    /**
     * Dev tool to delete a user.
     */
    public function destroy(User $user)
    {
        $user->delete();
        return response()->json(null, 204);
    }
}
