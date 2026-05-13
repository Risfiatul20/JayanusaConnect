<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Registration extends Model
{
    protected $fillable = [
        'user_id',
        'type',
        'training_id',
        'alumni_id',
        'status',
        'message',
        'admin_notes',
        'certificate_url'
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function training()
    {
        return $this->belongsTo(Training::class);
    }

    public function alumni()
    {
        return $this->belongsTo(Alumni::class);
    }
}
