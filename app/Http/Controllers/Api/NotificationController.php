<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * GET /api/notifications
     * Ambil semua notifikasi milik user yang login.
     * Filter: is_read=0 untuk yang belum dibaca.
     */
    public function index(Request $request)
    {
        $query = Notification::where('user_id', $request->user()->id);

        if ($request->filled('is_read')) {
            $query->where('is_read', (bool) $request->is_read);
        }

        $notifications = $query->latest()->paginate(15);

        $unreadCount = Notification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success'      => true,
            'message'      => 'Notifikasi berhasil diambil.',
            'unread_count' => $unreadCount,
            'data'         => $notifications,
        ]);
    }

    /**
     * PUT /api/notifications/{notification}/read
     * Tandai satu notifikasi sebagai sudah dibaca.
     */
    public function markRead(Request $request, Notification $notification)
    {
        if ($notification->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak.',
            ], 403);
        }

        $notification->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi ditandai sudah dibaca.',
            'data'    => $notification->fresh(),
        ]);
    }

    /**
     * PUT /api/notifications/read-all
     * Tandai SEMUA notifikasi user sebagai sudah dibaca.
     */
    public function markAllRead(Request $request)
    {
        Notification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Semua notifikasi ditandai sudah dibaca.',
        ]);
    }

    /**
     * DELETE /api/notifications/{notification}
     * Hapus satu notifikasi.
     */
    public function destroy(Request $request, Notification $notification)
    {
        if ($notification->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak.',
            ], 403);
        }

        $notification->delete();

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi berhasil dihapus.',
        ]);
    }
}
