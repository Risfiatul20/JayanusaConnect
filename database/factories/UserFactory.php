<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    protected static ?string $password;

    public function definition(): array
    {
        $angkatan = fake()->randomElement(['2020', '2021', '2022', '2023']);
        $nim      = $angkatan . fake()->unique()->numerify('###');

        return [
            'name'               => fake()->name(),
            'nim'                => $nim,
            'email'              => fake()->unique()->safeEmail(),
            'email_verified_at'  => now(),
            'password'           => static::$password ??= Hash::make('password123'),
            'role'               => 'mahasiswa',
            'phone'              => fake()->numerify('08##########'),
            'address'            => fake()->address(),
            'angkatan'           => $angkatan,
            'prodi'              => fake()->randomElement([
                'Sistem Informasi',
                'Teknik Informatika',
                'Manajemen Informatika',
            ]),
            'remember_token'     => Str::random(10),
        ];
    }

    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }

    public function adminBem(): static
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'admin_bem',
            'nim'  => null,
        ]);
    }

    public function superAdmin(): static
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'super_admin',
            'nim'  => null,
        ]);
    }
}
