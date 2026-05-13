<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Training extends Model
{
    protected $fillable = [
        'title',
        'category',
        'description',
        'quota',
        'registered',
        'date',
        'location',
        'instructor',
        'image_url',
        'status'
    ];

    protected $casts = [
        'date' => 'datetime'
    ];

    // Relationships
    public function registrations()
    {
        return $this->hasMany(Registration::class);
    }
}
