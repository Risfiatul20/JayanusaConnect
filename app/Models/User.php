<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['name', 'nim', 'email', 'password', 'role', 'photo', 'phone', 'address', 'angkatan', 'prodi'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    // Relationships
    public function aspirations()
    {
        return $this->hasMany(Aspiration::class);
    }

    public function portfolios()
    {
        return $this->hasMany(Portfolio::class);
    }

    public function registrations()
    {
        return $this->hasMany(Registration::class);
    }

    public function bemPrograms()
    {
        return $this->hasMany(BemProgram::class, 'created_by');
    }

    public function handledAspirations()
    {
        return $this->hasMany(Aspiration::class, 'handled_by');
    }
}
