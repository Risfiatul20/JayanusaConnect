<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Job extends Model
{
    protected $fillable = [
        'title',
        'company',
        'type',
        'location',
        'description',
        'requirements',
        'salary_range',
        'deadline',
        'contact_email',
        'contact_phone',
        'apply_url',
        'logo_url',
        'status',
        'posted_by'
    ];

    protected $casts = [
        'deadline' => 'date'
    ];

    // Relationships
    public function poster()
    {
        return $this->belongsTo(User::class, 'posted_by');
    }
}
