<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BemProgramRating extends Model
{
    protected $fillable = ['bem_program_id', 'user_id', 'rating', 'comment'];

    public function bemProgram()
    {
        return $this->belongsTo(BemProgram::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
