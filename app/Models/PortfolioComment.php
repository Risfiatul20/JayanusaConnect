<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PortfolioComment extends Model
{
    protected $fillable = ['portfolio_id', 'user_id', 'comment'];

    public function portfolio()
    {
        return $this->belongsTo(Portfolio::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
