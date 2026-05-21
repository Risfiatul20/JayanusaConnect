<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Portfolio;
use App\Models\PortfolioComment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PortfolioController extends Controller
{
    /**
     * GET /api/portfolios
     * Semua user bisa lihat. Filter by category, angkatan, search.
     */
    public function index(Request $request)
    {
        $query = Portfolio::with('user:id,name,nim,angkatan,prodi');

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        if ($request->filled('search')) {
            $query->where('title', 'like', '%' . $request->search . '%');
        }

        // Filter by angkatan (join ke users)
        if ($request->filled('angkatan')) {
            $query->whereHas('user', function ($q) use ($request) {
                $q->where('angkatan', $request->angkatan);
            });
        }

        // Filter portfolio milik sendiri
        if ($request->filled('my') && $request->my == 1) {
            $query->where('user_id', $request->user()->id);
        }

        $portfolios = $query->latest()->paginate(10);

        return response()->json([
            'success' => true,
            'message' => 'Daftar portofolio berhasil diambil.',
            'data'    => $portfolios,
        ]);
    }

    /**
     * POST /api/portfolios
     * Mahasiswa upload karya. Support file + thumbnail.
     */
    public function store(Request $request)
    {
        $request->validate([
            'title'       => 'required|string|max:255',
            'category'    => 'required|string|max:100',
            'description' => 'required|string',
            'file'        => 'nullable|file|mimes:pdf,zip,doc,docx|max:10240', // max 10MB
            'thumbnail'   => 'nullable|file|mimes:jpg,jpeg,png|max:2048',
            'demo_url'    => 'nullable|url|max:255',
            'github_url'  => 'nullable|url|max:255',
        ]);

        $fileUrl      = null;
        $thumbnailUrl = null;

        if ($request->hasFile('file')) {
            $path    = $request->file('file')->store('portfolios/files', 'public');
            $fileUrl = Storage::url($path);
        }

        if ($request->hasFile('thumbnail')) {
            $path         = $request->file('thumbnail')->store('portfolios/thumbnails', 'public');
            $thumbnailUrl = Storage::url($path);
        }

        $portfolio = Portfolio::create([
            'user_id'       => $request->user()->id,
            'title'         => $request->title,
            'category'      => $request->category,
            'description'   => $request->description,
            'file_url'      => $fileUrl,
            'thumbnail_url' => $thumbnailUrl,
            'demo_url'      => $request->demo_url,
            'github_url'    => $request->github_url,
            'likes'         => 0,
            'views'         => 0,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Portofolio berhasil dipublikasikan.',
            'data'    => $portfolio->load('user:id,name,nim,angkatan'),
        ], 201);
    }

    /**
     * GET /api/portfolios/{portfolio}
     * Semua user bisa lihat. Increment views setiap kali dibuka.
     */
    public function show(Portfolio $portfolio)
    {
        $portfolio->increment('views');

        return response()->json([
            'success' => true,
            'message' => 'Detail portofolio berhasil diambil.',
            'data'    => $portfolio->load('user:id,name,nim,angkatan,prodi'),
        ]);
    }

    /**
     * PUT /api/portfolios/{portfolio}
     * Hanya pemilik yang bisa edit.
     */
    public function update(Request $request, Portfolio $portfolio)
    {
        if ($portfolio->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Anda hanya bisa mengedit portofolio milik sendiri.',
            ], 403);
        }

        $request->validate([
            'title'       => 'sometimes|required|string|max:255',
            'category'    => 'sometimes|required|string|max:100',
            'description' => 'sometimes|required|string',
            'file'        => 'nullable|file|mimes:pdf,zip,doc,docx|max:10240',
            'thumbnail'   => 'nullable|file|mimes:jpg,jpeg,png|max:2048',
            'demo_url'    => 'nullable|url|max:255',
            'github_url'  => 'nullable|url|max:255',
        ]);

        $data = $request->only(['title', 'category', 'description', 'demo_url', 'github_url']);

        if ($request->hasFile('file')) {
            if ($portfolio->file_url) {
                Storage::disk('public')->delete(str_replace('/storage/', '', $portfolio->file_url));
            }
            $path          = $request->file('file')->store('portfolios/files', 'public');
            $data['file_url'] = Storage::url($path);
        }

        if ($request->hasFile('thumbnail')) {
            if ($portfolio->thumbnail_url) {
                Storage::disk('public')->delete(str_replace('/storage/', '', $portfolio->thumbnail_url));
            }
            $path                 = $request->file('thumbnail')->store('portfolios/thumbnails', 'public');
            $data['thumbnail_url'] = Storage::url($path);
        }

        $portfolio->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Portofolio berhasil diperbarui.',
            'data'    => $portfolio->fresh()->load('user:id,name,nim'),
        ]);
    }

    /**
     * DELETE /api/portfolios/{portfolio}
     * Pemilik atau admin bisa hapus.
     */
    public function destroy(Request $request, Portfolio $portfolio)
    {
        $user = $request->user();

        if (!in_array($user->role, ['admin_bem', 'super_admin'])
            && $portfolio->user_id !== $user->id
        ) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Anda hanya bisa menghapus portofolio milik sendiri.',
            ], 403);
        }

        // Hapus file dari storage
        if ($portfolio->file_url) {
            Storage::disk('public')->delete(str_replace('/storage/', '', $portfolio->file_url));
        }
        if ($portfolio->thumbnail_url) {
            Storage::disk('public')->delete(str_replace('/storage/', '', $portfolio->thumbnail_url));
        }

        $portfolio->delete();

        return response()->json([
            'success' => true,
            'message' => 'Portofolio berhasil dihapus.',
        ]);
    }

    /**
     * POST /api/portfolios/{portfolio}/like
     * Toggle like — like jika belum, unlike jika sudah.
     * Pakai session/cache sederhana berdasarkan user_id + portfolio_id.
     */
    public function like(Request $request, Portfolio $portfolio)
    {
        $user    = $request->user();
        $cacheKey = "portfolio_like_{$portfolio->id}_user_{$user->id}";

        if (cache()->has($cacheKey)) {
            // Sudah like → unlike
            $portfolio->decrement('likes');
            cache()->forget($cacheKey);
            $liked = false;
            $message = 'Like dibatalkan.';
        } else {
            // Belum like → like
            $portfolio->increment('likes');
            cache()->put($cacheKey, true, now()->addYears(1));
            $liked = true;
            $message = 'Portofolio berhasil di-like.';
        }

        return response()->json([
            'success' => true,
            'message' => $message,
            'data'    => [
                'likes' => $portfolio->fresh()->likes,
                'liked' => $liked,
            ],
        ]);
    }

    /**
     * GET /api/portfolios/{portfolio}/comments
     * Ambil semua komentar pada portofolio.
     */
    public function comments(Portfolio $portfolio)
    {
        $comments = PortfolioComment::with('user:id,name,photo')
            ->where('portfolio_id', $portfolio->id)
            ->latest()
            ->paginate(10);

        return response()->json([
            'success' => true,
            'message' => 'Komentar berhasil diambil.',
            'data'    => $comments,
        ]);
    }

    /**
     * POST /api/portfolios/{portfolio}/comments
     * Tambah komentar pada portofolio.
     */
    public function addComment(Request $request, Portfolio $portfolio)
    {
        $request->validate([
            'comment' => 'required|string|max:1000',
        ]);

        $comment = PortfolioComment::create([
            'portfolio_id' => $portfolio->id,
            'user_id'      => $request->user()->id,
            'comment'      => $request->comment,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Komentar berhasil ditambahkan.',
            'data'    => $comment->load('user:id,name,photo'),
        ], 201);
    }

    /**
     * DELETE /api/portfolios/{portfolio}/comments/{comment}
     * Hapus komentar — hanya pemilik komentar atau admin.
     */
    public function deleteComment(Request $request, Portfolio $portfolio, PortfolioComment $comment)
    {
        $user = $request->user();

        if (!in_array($user->role, ['admin_bem', 'super_admin']) && $comment->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak.',
            ], 403);
        }

        $comment->delete();

        return response()->json([
            'success' => true,
            'message' => 'Komentar berhasil dihapus.',
        ]);
    }
}
