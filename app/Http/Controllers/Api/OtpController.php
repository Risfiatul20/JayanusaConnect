<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OtpVerification;
use App\Models\User;
use Illuminate\Http\Request;

class OtpController extends Controller
{
    /**
     * GET /api/otp/pending
     * Admin lihat semua alumni yang menunggu verifikasi OTP
     */
    public function pending(Request $request)
    {
        $pending = OtpVerification::with('user:id,name,email,phone,angkatan,prodi')
            ->where('is_verified', false)
            ->where('expires_at', '>', now())
            ->latest()
            ->get()
            ->map(function ($otp) {
                return [
                    'id'         => $otp->id,
                    'user_id'    => $otp->user_id,
                    'user'       => $otp->user,
                    'phone'      => $otp->phone,
                    'otp_code'   => $otp->otp_code,
                    'expires_at' => $otp->expires_at,
                    'created_at' => $otp->created_at,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Daftar OTP pending berhasil diambil.',
            'data'    => $pending,
            'count'   => $pending->count(),
        ]);
    }

    /**
     * POST /api/otp/verify
     * Admin verifikasi OTP alumni — masukkan kode yang diterima via WA
     * Body: { "user_id": 5, "otp_code": "847291" }
     */
    public function verify(Request $request)
    {
        $request->validate([
            'user_id'  => 'required|exists:users,id',
            'otp_code' => 'required|string|size:6',
        ]);

        $otp = OtpVerification::where('user_id', $request->user_id)
            ->where('otp_code', $request->otp_code)
            ->where('is_verified', false)
            ->first();

        if (!$otp) {
            return response()->json([
                'success' => false,
                'message' => 'Kode OTP tidak valid atau tidak ditemukan.',
            ], 422);
        }

        if ($otp->isExpired()) {
            return response()->json([
                'success' => false,
                'message' => 'Kode OTP sudah expired. Minta alumni kirim ulang.',
            ], 422);
        }

        // Tandai OTP sebagai verified
        $otp->update([
            'is_verified' => true,
            'verified_at' => now(),
            'verified_by' => $request->user()->id,
        ]);

        // Aktifkan akun user alumni
        User::where('id', $request->user_id)->update(['is_verified' => true]);

        $alumni = User::find($request->user_id);

        return response()->json([
            'success' => true,
            'message' => "Akun alumni {$alumni->name} berhasil diverifikasi.",
            'data'    => $alumni,
        ]);
    }

    /**
     * DELETE /api/otp/{id}/reject
     * Admin tolak / hapus OTP (alumni tidak disetujui)
     */
    public function reject(Request $request, OtpVerification $otp)
    {
        $userName = $otp->user->name ?? 'Alumni';
        $otp->delete();

        // Set user tidak terverifikasi (bisa daftar ulang)
        User::where('id', $otp->user_id)->update(['is_verified' => false]);

        return response()->json([
            'success' => true,
            'message' => "Pendaftaran {$userName} ditolak.",
        ]);
    }
}
