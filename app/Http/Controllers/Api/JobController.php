<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Job;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class JobController extends Controller
{
    /**
     * GET /api/jobs
     * Semua user bisa lihat. Filter by type, status, search.
     */
    public function index(Request $request)
    {
        $query = Job::with('poster:id,name');

        // Default hanya tampilkan yang active
        $query->where('status', $request->filled('status') ? $request->status : 'active');

        if ($request->filled('type')) {
            $query->where('type', $request->type); // kerja / magang
        }

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('title', 'like', '%' . $request->search . '%')
                  ->orWhere('company', 'like', '%' . $request->search . '%');
            });
        }

        $jobs = $query->latest()->paginate(10);

        return response()->json([
            'success' => true,
            'message' => 'Daftar lowongan berhasil diambil.',
            'data'    => $jobs,
        ]);
    }

    /**
     * POST /api/jobs
     * Hanya admin. Support upload logo perusahaan.
     */
    public function store(Request $request)
    {
        $request->validate([
            'title'         => 'required|string|max:255',
            'company'       => 'required|string|max:255',
            'type'          => 'required|in:kerja,magang',
            'location'      => 'required|string|max:255',
            'description'   => 'required|string',
            'requirements'  => 'nullable|string',
            'salary_range'  => 'nullable|string|max:100',
            'deadline'      => 'nullable|date|after:today',
            'contact_email' => 'nullable|email|max:255',
            'contact_phone' => 'nullable|string|max:20',
            'apply_url'     => 'nullable|url|max:255',
            'logo'          => 'nullable|file|mimes:jpg,jpeg,png|max:1024', // max 1MB
        ]);

        $logoUrl = null;
        if ($request->hasFile('logo')) {
            $path    = $request->file('logo')->store('jobs/logos', 'public');
            $logoUrl = Storage::url($path);
        }

        $job = Job::create([
            'title'         => $request->title,
            'company'       => $request->company,
            'type'          => $request->type,
            'location'      => $request->location,
            'description'   => $request->description,
            'requirements'  => $request->requirements,
            'salary_range'  => $request->salary_range,
            'deadline'      => $request->deadline,
            'contact_email' => $request->contact_email,
            'contact_phone' => $request->contact_phone,
            'apply_url'     => $request->apply_url,
            'logo_url'      => $logoUrl,
            'status'        => 'active',
            'posted_by'     => $request->user()->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Lowongan berhasil ditambahkan.',
            'data'    => $job->load('poster:id,name'),
        ], 201);
    }

    /**
     * GET /api/jobs/{job}
     */
    public function show(Job $job)
    {
        return response()->json([
            'success' => true,
            'message' => 'Detail lowongan berhasil diambil.',
            'data'    => $job->load('poster:id,name'),
        ]);
    }

    /**
     * PUT /api/jobs/{job}
     * Hanya admin.
     */
    public function update(Request $request, Job $job)
    {
        $request->validate([
            'title'         => 'sometimes|required|string|max:255',
            'company'       => 'sometimes|required|string|max:255',
            'type'          => 'sometimes|required|in:kerja,magang',
            'location'      => 'sometimes|required|string|max:255',
            'description'   => 'sometimes|required|string',
            'requirements'  => 'nullable|string',
            'salary_range'  => 'nullable|string|max:100',
            'deadline'      => 'nullable|date',
            'contact_email' => 'nullable|email|max:255',
            'contact_phone' => 'nullable|string|max:20',
            'apply_url'     => 'nullable|url|max:255',
            'status'        => 'nullable|in:active,closed',
            'logo'          => 'nullable|file|mimes:jpg,jpeg,png|max:1024',
        ]);

        $data = $request->only([
            'title', 'company', 'type', 'location', 'description',
            'requirements', 'salary_range', 'deadline',
            'contact_email', 'contact_phone', 'apply_url', 'status',
        ]);

        if ($request->hasFile('logo')) {
            if ($job->logo_url) {
                Storage::disk('public')->delete(str_replace('/storage/', '', $job->logo_url));
            }
            $path           = $request->file('logo')->store('jobs/logos', 'public');
            $data['logo_url'] = Storage::url($path);
        }

        $job->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Lowongan berhasil diperbarui.',
            'data'    => $job->fresh()->load('poster:id,name'),
        ]);
    }

    /**
     * DELETE /api/jobs/{job}
     * Hanya admin.
     */
    public function destroy(Job $job)
    {
        if ($job->logo_url) {
            Storage::disk('public')->delete(str_replace('/storage/', '', $job->logo_url));
        }

        $job->delete();

        return response()->json([
            'success' => true,
            'message' => 'Lowongan berhasil dihapus.',
        ]);
    }
}
