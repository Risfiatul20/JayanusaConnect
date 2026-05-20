<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BemProgram;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class BemProgramController extends Controller
{
    /**
     * GET /api/bem-programs
     * Semua user bisa lihat. Bisa filter by category.
     */
    public function index(Request $request)
    {
        $query = BemProgram::with('creator:id,name');

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        if ($request->filled('search')) {
            $query->where('title', 'like', '%' . $request->search . '%');
        }

        $programs = $query->latest()->paginate(10);

        return response()->json([
            'success' => true,
            'message' => 'Daftar program kerja BEM berhasil diambil.',
            'data'    => $programs,
        ]);
    }

    /**
     * POST /api/bem-programs
     * Hanya admin. Support upload dokumen PDF.
     */
    public function store(Request $request)
    {
        $request->validate([
            'title'        => 'required|string|max:255',
            'description'  => 'required|string',
            'budget'       => 'required|numeric|min:0',
            'realization'  => 'nullable|numeric|min:0',
            'progress'     => 'nullable|integer|min:0|max:100',
            'start_date'   => 'nullable|date',
            'end_date'     => 'nullable|date|after_or_equal:start_date',
            'category'     => 'nullable|string|max:100',
            'document'     => 'nullable|file|mimes:pdf|max:5120', // max 5MB
        ]);

        $documentUrl = null;
        if ($request->hasFile('document')) {
            $path        = $request->file('document')->store('bem-programs/documents', 'public');
            $documentUrl = Storage::url($path);
        }

        $program = BemProgram::create([
            'title'        => $request->title,
            'description'  => $request->description,
            'budget'       => $request->budget,
            'realization'  => $request->realization ?? 0,
            'progress'     => $request->progress ?? 0,
            'start_date'   => $request->start_date,
            'end_date'     => $request->end_date,
            'category'     => $request->category,
            'document_url' => $documentUrl,
            'created_by'   => $request->user()->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Program kerja BEM berhasil ditambahkan.',
            'data'    => $program->load('creator:id,name'),
        ], 201);
    }

    /**
     * GET /api/bem-programs/{bem_program}
     * Semua user bisa lihat detail.
     */
    public function show(BemProgram $bemProgram)
    {
        return response()->json([
            'success' => true,
            'message' => 'Detail program kerja BEM berhasil diambil.',
            'data'    => $bemProgram->load('creator:id,name'),
        ]);
    }

    /**
     * PUT /api/bem-programs/{bem_program}
     * Hanya admin. Support upload ulang dokumen PDF.
     */
    public function update(Request $request, BemProgram $bemProgram)
    {
        $request->validate([
            'title'        => 'sometimes|required|string|max:255',
            'description'  => 'sometimes|required|string',
            'budget'       => 'sometimes|required|numeric|min:0',
            'realization'  => 'nullable|numeric|min:0',
            'progress'     => 'nullable|integer|min:0|max:100',
            'start_date'   => 'nullable|date',
            'end_date'     => 'nullable|date|after_or_equal:start_date',
            'category'     => 'nullable|string|max:100',
            'document'     => 'nullable|file|mimes:pdf|max:5120',
        ]);

        $data = $request->only([
            'title', 'description', 'budget', 'realization',
            'progress', 'start_date', 'end_date', 'category',
        ]);

        // Upload dokumen baru, hapus yang lama
        if ($request->hasFile('document')) {
            if ($bemProgram->document_url) {
                $oldPath = str_replace('/storage/', '', $bemProgram->document_url);
                Storage::disk('public')->delete($oldPath);
            }
            $path              = $request->file('document')->store('bem-programs/documents', 'public');
            $data['document_url'] = Storage::url($path);
        }

        $bemProgram->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Program kerja BEM berhasil diperbarui.',
            'data'    => $bemProgram->fresh()->load('creator:id,name'),
        ]);
    }

    /**
     * DELETE /api/bem-programs/{bem_program}
     * Hanya admin. Hapus juga file dokumen jika ada.
     */
    public function destroy(BemProgram $bemProgram)
    {
        if ($bemProgram->document_url) {
            $oldPath = str_replace('/storage/', '', $bemProgram->document_url);
            Storage::disk('public')->delete($oldPath);
        }

        $bemProgram->delete();

        return response()->json([
            'success' => true,
            'message' => 'Program kerja BEM berhasil dihapus.',
        ]);
    }
}
