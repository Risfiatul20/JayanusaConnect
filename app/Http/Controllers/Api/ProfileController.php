<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules\Password;

class ProfileController extends Controller
{
    /**
     * GET /api/profile
     * Ambil data profil user yang sedang login.
     */
    public function show(Request $request)
    {
        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diambil.',
            'data'    => $request->user(),
        ]);
    }

    /**
     * PUT /api/profile
     * Update data profil: name, phone, address, angkatan, prodi.
     * Support upload foto profil.
     */
    public function update(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name'    => 'sometimes|required|string|max:255',
            'phone'   => 'nullable|string|max:20',
            'address' => 'nullable|string',
            'angkatan'=> 'nullable|string|max:4',
            'prodi'   => 'nullable|string|max:255',
            'photo'   => 'nullable|file|mimes:jpg,jpeg,png|max:2048',
        ]);

        $data = $request->only(['name', 'phone', 'address', 'angkatan', 'prodi']);

        // Upload foto baru, hapus yang lama
        if ($request->hasFile('photo')) {
            if ($user->photo) {
                $oldPath = str_replace('/storage/', '', $user->photo);
                Storage::disk('public')->delete($oldPath);
            }
            $path         = $request->file('photo')->store('users/photos', 'public');
            $data['photo'] = Storage::url($path);
        }

        $user->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui.',
            'data'    => $user->fresh(),
        ]);
    }

    /**
     * PUT /api/profile/password
     * Ganti password — wajib verifikasi password lama.
     */
    public function updatePassword(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'current_password' => 'required|string',
            'password'         => ['required', 'confirmed', Password::min(8)],
        ]);

        // Verifikasi password lama
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password lama tidak sesuai.',
                'errors'  => ['current_password' => ['Password lama tidak sesuai.']],
            ], 422);
        }

        $user->update([
            'password' => Hash::make($request->password),
        ]);

        // Hapus semua token lain — paksa login ulang di semua device
        $user->tokens()->where('id', '!=', $request->user()->currentAccessToken()->id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diubah. Silakan login ulang di perangkat lain.',
        ]);
    }
}
