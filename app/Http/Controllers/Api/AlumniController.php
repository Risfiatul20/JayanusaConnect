<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Alumni;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AlumniController extends Controller
{
    /**
     * GET /api/alumni
     * Semua user bisa lihat. Filter by angkatan, available_for_mentoring, search.
     */
    public function index(Request $request)
    {
        $query = Alumni::query();

        if ($request->filled('angkatan')) {
            $query->where('angkatan', $request->angkatan);
        }

        if ($request->filled('mentoring') && $request->mentoring == 1) {
            $query->where('available_for_mentoring', true);
        }

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', '%' . $request->search . '%')
                  ->orWhere('profession', 'like', '%' . $request->search . '%')
                  ->orWhere('company', 'like', '%' . $request->search . '%');
            });
        }

        $alumni = $query->latest()->paginate(10);

        return response()->json([
            'success' => true,
            'message' => 'Daftar alumni berhasil diambil.',
            'data'    => $alumni,
        ]);
    }

    /**
     * POST /api/alumni
     * Hanya admin. Support upload foto.
     */
    public function store(Request $request)
    {
        $request->validate([
            'name'                    => 'required|string|max:255',
            'nim'                     => 'nullable|string|max:20',
            'angkatan'                => 'required|string|max:4',
            'prodi'                   => 'nullable|string|max:255',
            'profession'              => 'nullable|string|max:255',
            'company'                 => 'nullable|string|max:255',
            'position'                => 'nullable|string|max:255',
            'email'                   => 'nullable|email|max:255',
            'phone'                   => 'nullable|string|max:20',
            'linkedin'                => 'nullable|url|max:255',
            'bio'                     => 'nullable|string',
            'available_for_mentoring' => 'nullable|boolean',
            'photo'                   => 'nullable|file|mimes:jpg,jpeg,png|max:2048',
        ]);

        $photoUrl = null;
        if ($request->hasFile('photo')) {
            $path     = $request->file('photo')->store('alumni/photos', 'public');
            $photoUrl = Storage::url($path);
        }

        $alumni = Alumni::create([
            'name'                    => $request->name,
            'nim'                     => $request->nim,
            'angkatan'                => $request->angkatan,
            'prodi'                   => $request->prodi,
            'profession'              => $request->profession,
            'company'                 => $request->company,
            'position'                => $request->position,
            'email'                   => $request->email,
            'phone'                   => $request->phone,
            'linkedin'                => $request->linkedin,
            'bio'                     => $request->bio,
            'available_for_mentoring' => $request->available_for_mentoring ?? false,
            'photo_url'               => $photoUrl,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Data alumni berhasil ditambahkan.',
            'data'    => $alumni,
        ], 201);
    }

    /**
     * GET /api/alumni/{alumnus}
     */
    public function show(Alumni $alumnus)
    {
        return response()->json([
            'success' => true,
            'message' => 'Detail alumni berhasil diambil.',
            'data'    => $alumnus,
        ]);
    }

    /**
     * PUT /api/alumni/{alumnus}
     * Hanya admin.
     */
    public function update(Request $request, Alumni $alumnus)
    {
        $request->validate([
            'name'                    => 'sometimes|required|string|max:255',
            'nim'                     => 'nullable|string|max:20',
            'angkatan'                => 'sometimes|required|string|max:4',
            'prodi'                   => 'nullable|string|max:255',
            'profession'              => 'nullable|string|max:255',
            'company'                 => 'nullable|string|max:255',
            'position'                => 'nullable|string|max:255',
            'email'                   => 'nullable|email|max:255',
            'phone'                   => 'nullable|string|max:20',
            'linkedin'                => 'nullable|url|max:255',
            'bio'                     => 'nullable|string',
            'available_for_mentoring' => 'nullable|boolean',
            'photo'                   => 'nullable|file|mimes:jpg,jpeg,png|max:2048',
        ]);

        $data = $request->only([
            'name', 'nim', 'angkatan', 'prodi', 'profession',
            'company', 'position', 'email', 'phone', 'linkedin',
            'bio', 'available_for_mentoring',
        ]);

        if ($request->hasFile('photo')) {
            if ($alumnus->photo_url) {
                Storage::disk('public')->delete(str_replace('/storage/', '', $alumnus->photo_url));
            }
            $path             = $request->file('photo')->store('alumni/photos', 'public');
            $data['photo_url'] = Storage::url($path);
        }

        $alumnus->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Data alumni berhasil diperbarui.',
            'data'    => $alumnus->fresh(),
        ]);
    }

    /**
     * DELETE /api/alumni/{alumnus}
     * Hanya admin.
     */
    public function destroy(Alumni $alumnus)
    {
        if ($alumnus->photo_url) {
            Storage::disk('public')->delete(str_replace('/storage/', '', $alumnus->photo_url));
        }

        $alumnus->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data alumni berhasil dihapus.',
        ]);
    }
}
