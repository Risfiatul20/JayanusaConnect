<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Alumni extends Model
{
    protected $fillable = [
        'name',
        'nim',
        'angkatan',
        'prodi',
        'profession',
        'company',
        'position',
        'email',
        'phone',
        'linkedin',
        'photo_url',
        'bio',
        'available_for_mentoring',
        'user_id'
    ];

    protected $casts = [
        'available_for_mentoring' => 'boolean'
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function mentoringRegistrations()
    {
        return $this->hasMany(Registration::class);
    }
}
