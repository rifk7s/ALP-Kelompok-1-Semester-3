<?php

namespace App\Http\Controllers;
use App\Models\User;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

#[Group('Profile', 'Data profil user yang sedang login', weight: 20)]
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
    public function update(Request $request)
    {
        $user = $request->user();
        
        $validated = $request->validate([
            'name' => ['sometimes', 'max:255', 'string'],
            'phone' => ['sometimes', 'max:15', 'string', Rule::unique('users')->ignore($user->id)],
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