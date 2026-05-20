<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Registration;
use App\Models\Training;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class TrainingController extends Controller
{
    /**
     * GET /api/trainings
     * Semua user bisa lihat. Filter by category & status.
     */
    public function index(Request $request)
    {
        $query = Training::withCount('registrations');

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('search')) {
            $query->where('title', 'like', '%' . $request->search . '%');
        }

        $trainings = $query->latest()->paginate(10);

        return response()->json([
            'success' => true,
            'message' => 'Daftar pelatihan berhasil diambil.',
            'data'    => $trainings,
        ]);
    }

    /**
     * POST /api/trainings
     * Hanya admin. Support upload gambar banner.
     */
    public function store(Request $request)
    {
        $request->validate([
            'title'      => 'required|string|max:255',
            'category'   => 'required|string|max:100',
            'description'=> 'required|string',
            'quota'      => 'required|integer|min:1',
            'date'       => 'required|date|after:now',
            'location'   => 'nullable|string|max:255',
            'instructor' => 'nullable|string|max:255',
            'image'      => 'nullable|file|mimes:jpg,jpeg,png|max:2048', // max 2MB
        ]);

        $imageUrl = null;
        if ($request->hasFile('image')) {
            $path     = $request->file('image')->store('trainings/images', 'public');
            $imageUrl = Storage::url($path);
        }

        $training = Training::create([
            'title'       => $request->title,
            'category'    => $request->category,
            'description' => $request->description,
            'quota'       => $request->quota,
            'registered'  => 0,
            'date'        => $request->date,
            'location'    => $request->location,
            'instructor'  => $request->instructor,
            'image_url'   => $imageUrl,
            'status'      => 'open',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pelatihan berhasil ditambahkan.',
            'data'    => $training,
        ], 201);
    }

    /**
     * GET /api/trainings/{training}
     * Semua user bisa lihat detail.
     */
    public function show(Training $training)
    {
        return response()->json([
            'success' => true,
            'message' => 'Detail pelatihan berhasil diambil.',
            'data'    => $training->loadCount('registrations'),
        ]);
    }

    /**
     * PUT /api/trainings/{training}
     * Hanya admin.
     */
    public function update(Request $request, Training $training)
    {
        $request->validate([
            'title'      => 'sometimes|required|string|max:255',
            'category'   => 'sometimes|required|string|max:100',
            'description'=> 'sometimes|required|string',
            'quota'      => 'sometimes|required|integer|min:1',
            'date'       => 'sometimes|required|date',
            'location'   => 'nullable|string|max:255',
            'instructor' => 'nullable|string|max:255',
            'status'     => 'nullable|in:open,closed,completed',
            'image'      => 'nullable|file|mimes:jpg,jpeg,png|max:2048',
        ]);

        $data = $request->only([
            'title', 'category', 'description', 'quota',
            'date', 'location', 'instructor', 'status',
        ]);

        if ($request->hasFile('image')) {
            if ($training->image_url) {
                $oldPath = str_replace('/storage/', '', $training->image_url);
                Storage::disk('public')->delete($oldPath);
            }
            $path             = $request->file('image')->store('trainings/images', 'public');
            $data['image_url'] = Storage::url($path);
        }

        $training->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Pelatihan berhasil diperbarui.',
            'data'    => $training->fresh(),
        ]);
    }

    /**
     * DELETE /api/trainings/{training}
     * Hanya admin.
     */
    public function destroy(Training $training)
    {
        if ($training->image_url) {
            $oldPath = str_replace('/storage/', '', $training->image_url);
            Storage::disk('public')->delete($oldPath);
        }

        $training->delete();

        return response()->json([
            'success' => true,
            'message' => 'Pelatihan berhasil dihapus.',
        ]);
    }

    /**
     * POST /api/trainings/{training}/register
     * Mahasiswa daftar ke pelatihan. Cek kuota & duplikasi.
     */
    public function register(Request $request, Training $training)
    {
        $user = $request->user();

        // Cek status pelatihan
        if ($training->status !== 'open') {
            return response()->json([
                'success' => false,
                'message' => 'Pendaftaran pelatihan ini sudah ditutup.',
            ], 422);
        }

        // Cek kuota
        if ($training->registered >= $training->quota) {
            return response()->json([
                'success' => false,
                'message' => 'Kuota pelatihan sudah penuh.',
            ], 422);
        }

        // Cek apakah sudah pernah daftar
        $alreadyRegistered = Registration::where('user_id', $user->id)
            ->where('training_id', $training->id)
            ->where('type', 'training')
            ->exists();

        if ($alreadyRegistered) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah terdaftar di pelatihan ini.',
            ], 422);
        }

        // Buat registrasi
        $registration = Registration::create([
            'user_id'     => $user->id,
            'type'        => 'training',
            'training_id' => $training->id,
            'status'      => 'pending',
        ]);

        // Increment jumlah terdaftar
        $training->increment('registered');

        return response()->json([
            'success' => true,
            'message' => 'Berhasil mendaftar pelatihan. Menunggu konfirmasi admin.',
            'data'    => $registration->load('training:id,title,date,location'),
        ], 201);
    }
}
