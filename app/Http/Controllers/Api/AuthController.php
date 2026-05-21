<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register new user (Admin BEM)
     */
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'nim' => 'nullable|string|max:20|unique:users',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'phone' => 'nullable|string|max:20',
            'angkatan' => 'nullable|string|max:4',
            'prodi' => 'nullable|string|max:255',
        ]);

        $user = User::create([
            'name' => $request->name,
            'nim' => $request->nim,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'mahasiswa', // Default role
            'phone' => $request->phone,
            'angkatan' => $request->angkatan,
            'prodi' => $request->prodi,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil',
            'data' => [
                'user' => $user,
                'token' => $token,
                'token_type' => 'Bearer'
            ]
        ], 201);
    }

    /**
     * Register Alumni — buat akun user + data alumni sekaligus
     */
    public function registerAlumni(Request $request)
    {
        $request->validate([
            'name'       => 'required|string|max:255',
            'email'      => 'required|string|email|max:255|unique:users',
            'password'   => 'required|string|min:8|confirmed',
            'nim'        => 'nullable|string|max:20',
            'angkatan'   => 'required|string|max:4',
            'prodi'      => 'nullable|string|max:255',
            'phone'      => 'nullable|string|max:20',
            'profession' => 'nullable|string|max:255',
            'company'    => 'nullable|string|max:255',
            'position'   => 'nullable|string|max:255',
            'linkedin'   => 'nullable|url|max:255',
            'bio'        => 'nullable|string',
        ]);

        // Buat akun user dengan role alumni
        $user = User::create([
            'name'     => $request->name,
            'nim'      => $request->nim,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
            'role'     => 'alumni',
            'phone'    => $request->phone,
            'angkatan' => $request->angkatan,
            'prodi'    => $request->prodi,
        ]);

        // Buat entry di tabel alumni dan link ke user
        $alumni = \App\Models\Alumni::create([
            'name'       => $request->name,
            'nim'        => $request->nim,
            'angkatan'   => $request->angkatan,
            'prodi'      => $request->prodi,
            'email'      => $request->email,
            'phone'      => $request->phone,
            'profession' => $request->profession,
            'company'    => $request->company,
            'position'   => $request->position,
            'linkedin'   => $request->linkedin,
            'bio'        => $request->bio,
            'user_id'    => $user->id,
            'available_for_mentoring' => false,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registrasi alumni berhasil. Selamat bergabung!',
            'data' => [
                'user'   => $user,
                'alumni' => $alumni,
                'token'  => $token,
                'token_type' => 'Bearer',
            ]
        ], 201);
    }

    /**
     * Login user
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah.'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'user' => $user,
                'token' => $token,
                'token_type' => 'Bearer'
            ]
        ]);
    }

    /**
     * Logout user
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil'
        ]);
    }

    /**
     * Get authenticated user
     */
    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => $request->user()
        ]);
    }
}
