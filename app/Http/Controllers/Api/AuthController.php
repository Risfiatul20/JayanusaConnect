<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Alumni;
use App\Models\OtpVerification;
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
            'name'     => 'required|string|max:255',
            'nim'      => 'nullable|string|max:20|unique:users',
            'email'    => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'phone'    => 'nullable|string|max:20',
            'angkatan' => 'nullable|string|max:4',
            'prodi'    => 'nullable|string|max:255',
        ]);

        $user = User::create([
            'name'     => $request->name,
            'nim'      => $request->nim,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
            'role'     => 'mahasiswa',
            'phone'    => $request->phone,
            'angkatan' => $request->angkatan,
            'prodi'    => $request->prodi,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil',
            'data'    => [
                'user'       => $user,
                'token'      => $token,
                'token_type' => 'Bearer',
            ],
        ], 201);
    }

    /**
     * Register Alumni
     * - No HP wajib
     * - Generate OTP 6 digit
     * - Akun dibuat tapi is_verified = false
     * - Alumni harus kirim OTP ke admin via WA untuk aktivasi
     */
    public function registerAlumni(Request $request)
    {
        $request->validate([
            'name'       => 'required|string|max:255',
            'email'      => 'required|string|email|max:255|unique:users',
            'password'   => 'required|string|min:8|confirmed',
            'phone'      => 'required|string|max:20',   // WAJIB untuk OTP WA
            'nim'        => 'nullable|string|max:20',
            'angkatan'   => 'required|string|max:4',
            'prodi'      => 'nullable|string|max:255',
            'profession' => 'nullable|string|max:255',
            'company'    => 'nullable|string|max:255',
            'position'   => 'nullable|string|max:255',
            'linkedin'   => 'nullable|url|max:255',
            'bio'        => 'nullable|string',
        ]);

        // Buat akun user dengan role alumni, is_verified = false
        $user = User::create([
            'name'        => $request->name,
            'nim'         => $request->nim,
            'email'       => $request->email,
            'password'    => Hash::make($request->password),
            'role'        => 'alumni',
            'phone'       => $request->phone,
            'angkatan'    => $request->angkatan,
            'prodi'       => $request->prodi,
            'is_verified' => false, // belum terverifikasi
        ]);

        // Buat entry di tabel alumni
        Alumni::create([
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

        // Generate OTP 6 digit
        $otpCode = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        // Hapus OTP lama jika ada, simpan yang baru
        OtpVerification::where('user_id', $user->id)->delete();
        OtpVerification::create([
            'user_id'    => $user->id,
            'phone'      => $request->phone,
            'otp_code'   => $otpCode,
            'is_verified'=> false,
            'expires_at' => now()->addMinutes(30),
        ]);

        // Format nomor WA (hilangkan 0 di depan, ganti dengan 62)
        $waNumber = $this->formatWaNumber($request->phone);

        // Pesan WA yang akan dikirim alumni ke admin
        $adminWaNumber = config('app.admin_wa_number', '6281234567890');
        $waMessage = urlencode(
            "Halo Admin JAYANUSA Connect,\n\n" .
            "Saya *{$request->name}* baru saja mendaftar sebagai Alumni.\n" .
            "Kode OTP verifikasi saya: *{$otpCode}*\n\n" .
            "Mohon verifikasi akun saya. Terima kasih."
        );
        $waLink = "https://wa.me/{$adminWaNumber}?text={$waMessage}";

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil! Kirim kode OTP ke Admin via WhatsApp untuk aktivasi akun.',
            'data'    => [
                'user'        => $user,
                'token'       => $token,
                'token_type'  => 'Bearer',
                'otp_code'    => $otpCode,       // tampilkan di app
                'wa_link'     => $waLink,         // link buka WA ke admin
                'wa_number'   => $waNumber,       // nomor alumni (untuk info)
                'expires_at'  => now()->addMinutes(30)->toISOString(),
                'is_verified' => false,
            ],
        ], 201);
    }

    /**
     * Cek status verifikasi OTP alumni
     * Alumni polling endpoint ini setelah kirim WA ke admin
     */
    public function checkVerification(Request $request)
    {
        $user = $request->user();

        if ($user->is_verified) {
            return response()->json([
                'success'     => true,
                'is_verified' => true,
                'message'     => 'Akun Anda sudah terverifikasi.',
            ]);
        }

        $otp = OtpVerification::where('user_id', $user->id)
            ->where('is_verified', false)
            ->latest()
            ->first();

        return response()->json([
            'success'     => true,
            'is_verified' => false,
            'message'     => 'Akun belum terverifikasi. Kirim OTP ke Admin via WhatsApp.',
            'expires_at'  => $otp?->expires_at?->toISOString(),
        ]);
    }

    /**
     * Resend OTP — generate ulang kode baru
     */
    public function resendOtp(Request $request)
    {
        $user = $request->user();

        if ($user->is_verified) {
            return response()->json([
                'success' => false,
                'message' => 'Akun sudah terverifikasi.',
            ], 422);
        }

        $otpCode = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        OtpVerification::where('user_id', $user->id)->delete();
        OtpVerification::create([
            'user_id'    => $user->id,
            'phone'      => $user->phone,
            'otp_code'   => $otpCode,
            'is_verified'=> false,
            'expires_at' => now()->addMinutes(30),
        ]);

        $adminWaNumber = config('app.admin_wa_number', '6281234567890');
        $waMessage = urlencode(
            "Halo Admin JAYANUSA Connect,\n\n" .
            "Saya *{$user->name}* meminta OTP baru.\n" .
            "Kode OTP verifikasi saya: *{$otpCode}*\n\n" .
            "Mohon verifikasi akun saya. Terima kasih."
        );
        $waLink = "https://wa.me/{$adminWaNumber}?text={$waMessage}";

        return response()->json([
            'success'    => true,
            'message'    => 'OTP baru berhasil dibuat.',
            'data'       => [
                'otp_code'   => $otpCode,
                'wa_link'    => $waLink,
                'expires_at' => now()->addMinutes(30)->toISOString(),
            ],
        ]);
    }

    /**
     * Login user
     */
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
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
            'data'    => [
                'user'        => $user,
                'token'       => $token,
                'token_type'  => 'Bearer',
                'is_verified' => $user->is_verified,
            ],
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
            'message' => 'Logout berhasil',
        ]);
    }

    /**
     * Get authenticated user
     */
    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'data'    => $request->user(),
        ]);
    }

    /**
     * Format nomor WA: 08xxx → 628xxx
     */
    private function formatWaNumber(string $phone): string
    {
        $phone = preg_replace('/\D/', '', $phone); // hapus non-digit
        if (str_starts_with($phone, '0')) {
            $phone = '62' . substr($phone, 1);
        } elseif (!str_starts_with($phone, '62')) {
            $phone = '62' . $phone;
        }
        return $phone;
    }
}
