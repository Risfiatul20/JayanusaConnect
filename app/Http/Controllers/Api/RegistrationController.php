<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Alumni;
use App\Models\Registration;
use App\Models\Training;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class RegistrationController extends Controller
{
    /**
     * GET /api/registrations
     * Mahasiswa → hanya milik sendiri.
     * Admin     → semua, bisa filter by type & status.
     */
    public function index(Request $request)
    {
        $user  = $request->user();
        $query = Registration::with([
            'user:id,name,nim',
            'training:id,title,date,location',
            'alumni:id,name,profession,company',
        ]);

        if (in_array($user->role, ['admin_bem', 'super_admin'])) {
            if ($request->filled('type')) {
                $query->where('type', $request->type);
            }
            if ($request->filled('status')) {
                $query->where('status', $request->status);
            }
        } else {
            $query->where('user_id', $user->id);
            if ($request->filled('type')) {
                $query->where('type', $request->type);
            }
        }

        $registrations = $query->latest()->paginate(10);

        return response()->json([
            'success' => true,
            'message' => 'Daftar registrasi berhasil diambil.',
            'data'    => $registrations,
        ]);
    }

    /**
     * POST /api/registrations
     * Mahasiswa daftar mentoring alumni.
     * (Daftar training pakai POST /trainings/{training}/register)
     */
    public function store(Request $request)
    {
        $request->validate([
            'alumni_id' => 'required|exists:alumni,id',
            'message'   => 'nullable|string|max:1000',
        ]);

        $user   = $request->user();
        $alumni = Alumni::findOrFail($request->alumni_id);

        // Cek alumni tersedia untuk mentoring
        if (!$alumni->available_for_mentoring) {
            return response()->json([
                'success' => false,
                'message' => 'Alumni ini tidak tersedia untuk mentoring saat ini.',
            ], 422);
        }

        // Cek duplikasi pendaftaran mentoring
        $alreadyRegistered = Registration::where('user_id', $user->id)
            ->where('alumni_id', $request->alumni_id)
            ->where('type', 'mentoring')
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        if ($alreadyRegistered) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah memiliki pendaftaran mentoring aktif dengan alumni ini.',
            ], 422);
        }

        $registration = Registration::create([
            'user_id'   => $user->id,
            'type'      => 'mentoring',
            'alumni_id' => $request->alumni_id,
            'status'    => 'pending',
            'message'   => $request->message,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pendaftaran mentoring berhasil dikirim. Menunggu konfirmasi.',
            'data'    => $registration->load([
                'user:id,name,nim',
                'alumni:id,name,profession,company',
            ]),
        ], 201);
    }

    /**
     * GET /api/registrations/{registration}
     * Pemilik atau admin.
     */
    public function show(Request $request, Registration $registration)
    {
        $user = $request->user();

        if (!in_array($user->role, ['admin_bem', 'super_admin'])
            && $registration->user_id !== $user->id
        ) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak.',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail registrasi berhasil diambil.',
            'data'    => $registration->load([
                'user:id,name,nim',
                'training:id,title,date,location,instructor',
                'alumni:id,name,profession,company',
            ]),
        ]);
    }

    /**
     * PUT /api/registrations/{registration}
     * Mahasiswa upload sertifikat setelah training selesai.
     */
    public function update(Request $request, Registration $registration)
    {
        $user = $request->user();

        if ($registration->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak.',
            ], 403);
        }

        $request->validate([
            'certificate' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ]);

        // Hapus sertifikat lama jika ada
        if ($registration->certificate_url) {
            Storage::disk('public')->delete(
                str_replace('/storage/', '', $registration->certificate_url)
            );
        }

        $path = $request->file('certificate')->store('registrations/certificates', 'public');
        $registration->update(['certificate_url' => Storage::url($path)]);

        return response()->json([
            'success' => true,
            'message' => 'Sertifikat berhasil diupload.',
            'data'    => $registration->fresh()->load('training:id,title'),
        ]);
    }

    /**
     * DELETE /api/registrations/{registration}
     * Mahasiswa bisa batalkan jika masih pending.
     * Admin bisa hapus semua.
     */
    public function destroy(Request $request, Registration $registration)
    {
        $user = $request->user();

        if (!in_array($user->role, ['admin_bem', 'super_admin'])) {
            if ($registration->user_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Akses ditolak.',
                ], 403);
            }

            if ($registration->status !== 'pending') {
                return response()->json([
                    'success' => false,
                    'message' => 'Registrasi tidak dapat dibatalkan karena sudah diproses.',
                ], 422);
            }
        }

        // Kurangi counter registered jika training
        if ($registration->type === 'training' && $registration->training_id) {
            Training::where('id', $registration->training_id)->decrement('registered');
        }

        if ($registration->certificate_url) {
            Storage::disk('public')->delete(
                str_replace('/storage/', '', $registration->certificate_url)
            );
        }

        $registration->delete();

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil dibatalkan.',
        ]);
    }

    /**
     * PUT /api/registrations/{registration}/status
     * Hanya admin (via route middleware).
     * Update status + admin_notes. Jika training approved → kirim notif (future).
     */
    public function updateStatus(Request $request, Registration $registration)
    {
        $request->validate([
            'status'      => 'required|in:pending,approved,rejected,completed',
            'admin_notes' => 'nullable|string',
        ]);

        $registration->update([
            'status'      => $request->status,
            'admin_notes' => $request->admin_notes,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Status registrasi berhasil diperbarui.',
            'data'    => $registration->fresh()->load([
                'user:id,name,nim',
                'training:id,title,date',
                'alumni:id,name,profession',
            ]),
        ]);
    }
}
