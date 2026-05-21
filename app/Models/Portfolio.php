<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Portfolio extends Model
{
    protected $fillable = [
        'user_id',
        'title',
        'category',
        'description',
        'file_url',
        'thumbnail_url',
        'demo_url',
        'github_url',
        'likes',
        'views'
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function comments()
    {
        return $this->hasMany(PortfolioComment::class);
    }
}
