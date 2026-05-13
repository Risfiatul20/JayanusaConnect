<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BemProgram extends Model
{
    protected $fillable = [
        'title',
        'description',
        'budget',
        'realization',
        'progress',
        'start_date',
        'end_date',
        'category',
        'document_url',
        'created_by'
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'budget' => 'decimal:2',
        'realization' => 'decimal:2'
    ];

    // Relationships
    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
