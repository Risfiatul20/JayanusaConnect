<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Aspiration;
use App\Models\Notification;
use Illuminate\Http\Request;

class AspirationController extends Controller
{
    /**
     * GET /api/aspirations
     * Mahasiswa  → hanya lihat aspirasi milik sendiri (bisa filter by status)
     * Admin      → lihat semua aspirasi (bisa filter by status & category)
     */
    public function index(Request $request)
    {
        $user  = $request->user();
        $query = Aspiration::with(['user:id,name,nim', 'handler:id,name']);

        if (in_array($user->role, ['admin_bem', 'super_admin'])) {
            // Admin bisa filter by status dan category
            if ($request->filled('status')) {
                $query->where('status', $request->status);
            }
            if ($request->filled('category')) {
                $query->where('category', $request->category);
            }
        } else {
            // Mahasiswa hanya lihat milik sendiri
            $query->where('user_id', $user->id);
            if ($request->filled('status')) {
                $query->where('status', $request->status);
            }
        }

        $aspirations = $query->latest()->paginate(10);

        return response()->json([
            'success' => true,
            'message' => 'Daftar aspirasi berhasil diambil.',
            'data'    => $aspirations,
        ]);
    }

    /**
     * POST /api/aspirations
     * Hanya mahasiswa yang bisa kirim aspirasi baru.
     * Status otomatis 'dikirim'.
     */
    public function store(Request $request)
    {
        $request->validate([
            'title'    => 'required|string|max:255',
            'content'  => 'required|string',
            'category' => 'nullable|string|max:100',
        ]);

        $aspiration = Aspiration::create([
            'user_id'  => $request->user()->id,
            'title'    => $request->title,
            'content'  => $request->content,
            'category' => $request->category,
            'status'   => 'dikirim',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Aspirasi berhasil dikirim.',
            'data'    => $aspiration->load('user:id,name,nim'),
        ], 201);
    }

    /**
     * GET /api/aspirations/{aspiration}
     * Mahasiswa hanya bisa lihat milik sendiri.
     * Admin bisa lihat semua.
     */
    public function show(Request $request, Aspiration $aspiration)
    {
        $user = $request->user();

        if (!in_array($user->role, ['admin_bem', 'super_admin'])
            && $aspiration->user_id !== $user->id
        ) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Ini bukan aspirasi Anda.',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail aspirasi berhasil diambil.',
            'data'    => $aspiration->load(['user:id,name,nim', 'handler:id,name']),
        ]);
    }

    /**
     * PUT /api/aspirations/{aspiration}
     * Hanya pemilik yang bisa edit.
     * Hanya bisa diedit jika status masih 'dikirim'.
     */
    public function update(Request $request, Aspiration $aspiration)
    {
        $user = $request->user();

        // Cek kepemilikan
        if ($aspiration->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Anda hanya bisa mengedit aspirasi milik sendiri.',
            ], 403);
        }

        // Cek status — tidak bisa edit jika sudah diproses
        if ($aspiration->status !== 'dikirim') {
            return response()->json([
                'success' => false,
                'message' => 'Aspirasi tidak dapat diedit karena sudah diproses.',
            ], 422);
        }

        $request->validate([
            'title'    => 'sometimes|required|string|max:255',
            'content'  => 'sometimes|required|string',
            'category' => 'nullable|string|max:100',
        ]);

        $aspiration->update($request->only(['title', 'content', 'category']));

        return response()->json([
            'success' => true,
            'message' => 'Aspirasi berhasil diperbarui.',
            'data'    => $aspiration->fresh()->load('user:id,name,nim'),
        ]);
    }

    /**
     * DELETE /api/aspirations/{aspiration}
     * Pemilik bisa hapus aspirasi milik sendiri.
     * Admin bisa hapus semua.
     */
    public function destroy(Request $request, Aspiration $aspiration)
    {
        $user = $request->user();

        if (!in_array($user->role, ['admin_bem', 'super_admin'])
            && $aspiration->user_id !== $user->id
        ) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Anda hanya bisa menghapus aspirasi milik sendiri.',
            ], 403);
        }

        $aspiration->delete();

        return response()->json([
            'success' => true,
            'message' => 'Aspirasi berhasil dihapus.',
        ]);
    }

    /**
     * PUT /api/aspirations/{aspiration}/status
     * Hanya admin (via route middleware role:admin_bem,super_admin).
     * Update status + admin_notes + handled_by.
     */
    public function updateStatus(Request $request, Aspiration $aspiration)
    {
        $request->validate([
            'status'      => 'required|in:dikirim,diproses,selesai',
            'admin_notes' => 'nullable|string',
        ]);

        $aspiration->update([
            'status'      => $request->status,
            'admin_notes' => $request->admin_notes,
            'handled_by'  => $request->user()->id,
        ]);

        // Kirim notifikasi ke mahasiswa
        $statusLabel = ['dikirim' => 'Dikirim', 'diproses' => 'Sedang Diproses', 'selesai' => 'Selesai'];
        Notification::create([
            'user_id'      => $aspiration->user_id,
            'title'        => 'Status Aspirasi Diperbarui',
            'message'      => "Aspirasi \"{$aspiration->title}\" kini berstatus: {$statusLabel[$request->status]}." . ($request->admin_notes ? " Catatan: {$request->admin_notes}" : ''),
            'type'         => 'info',
            'related_type' => 'aspiration',
            'related_id'   => $aspiration->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Status aspirasi berhasil diperbarui.',
            'data'    => $aspiration->fresh()->load(['user:id,name,nim', 'handler:id,name']),
        ]);
    }
}
