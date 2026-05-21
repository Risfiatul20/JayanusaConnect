<?php

use App\Http\Controllers\Api\AlumniController;
use App\Http\Controllers\Api\AspirationController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BemProgramController;
use App\Http\Controllers\Api\JobController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\OtpController;
use App\Http\Controllers\Api\PortfolioController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\RegistrationController;
use App\Http\Controllers\Api\TrainingController;
use Illuminate\Support\Facades\Route;

// ─── PUBLIC ROUTES ────────────────────────────────────────────────────────────
Route::post('/auth/register',        [AuthController::class, 'register']);
Route::post('/auth/register-alumni', [AuthController::class, 'registerAlumni']);
Route::post('/auth/login',           [AuthController::class, 'login']);

// ─── PROTECTED ROUTES (semua butuh token Sanctum) ─────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/auth/logout',             [AuthController::class, 'logout']);
    Route::get('/auth/me',                  [AuthController::class, 'me']);
    Route::get('/auth/check-verification',  [AuthController::class, 'checkVerification']);
    Route::post('/auth/resend-otp',         [AuthController::class, 'resendOtp']);

    // ── OTP (Admin only) ──────────────────────────────────────────────────────
    Route::middleware('role:admin_bem,super_admin')->group(function () {
        Route::get('otp/pending',          [OtpController::class, 'pending']);
        Route::post('otp/verify',          [OtpController::class, 'verify']);
        Route::delete('otp/{otp}/reject',  [OtpController::class, 'reject']);
    });

    // ── PROFILE ───────────────────────────────────────────────────────────────
    Route::get('profile',                  [ProfileController::class, 'show']);
    Route::post('profile',                 [ProfileController::class, 'update']);
    Route::put('profile/password',         [ProfileController::class, 'updatePassword']);

    // ── ASPIRASI ──────────────────────────────────────────────────────────────
    // Mahasiswa: index (milik sendiri), store, show, update, destroy
    // Admin    : index (semua), show, destroy, updateStatus
    Route::apiResource('aspirations', AspirationController::class);
    Route::put('aspirations/{aspiration}/status',
        [AspirationController::class, 'updateStatus']
    )->middleware('role:admin_bem,super_admin');

    // ── BEM PROGRAMS ──────────────────────────────────────────────────────────
    // Mahasiswa: index, show, rate, ratings (read only + evaluasi)
    // Admin    : store, update, destroy
    Route::get('bem-programs',               [BemProgramController::class, 'index']);
    Route::get('bem-programs/{bem_program}', [BemProgramController::class, 'show']);
    Route::get('bem-programs/{bem_program}/ratings', [BemProgramController::class, 'ratings']);
    Route::post('bem-programs/{bem_program}/rate',   [BemProgramController::class, 'rate']);
    Route::middleware('role:admin_bem,super_admin')->group(function () {
        Route::post('bem-programs',                 [BemProgramController::class, 'store']);
        Route::put('bem-programs/{bem_program}',    [BemProgramController::class, 'update']);
        Route::patch('bem-programs/{bem_program}',  [BemProgramController::class, 'update']);
        Route::delete('bem-programs/{bem_program}', [BemProgramController::class, 'destroy']);
    });

    // ── TRAININGS ─────────────────────────────────────────────────────────────
    // Mahasiswa: index, show, register (daftar pelatihan)
    // Admin    : store, update, destroy
    Route::get('trainings',              [TrainingController::class, 'index']);
    Route::get('trainings/{training}',   [TrainingController::class, 'show']);
    Route::post('trainings/{training}/register', [TrainingController::class, 'register']);
    Route::middleware('role:admin_bem,super_admin')->group(function () {
        Route::post('trainings',                 [TrainingController::class, 'store']);
        Route::put('trainings/{training}',       [TrainingController::class, 'update']);
        Route::patch('trainings/{training}',     [TrainingController::class, 'update']);
        Route::delete('trainings/{training}',    [TrainingController::class, 'destroy']);
    });

    // ── PORTFOLIOS ────────────────────────────────────────────────────────────
    // Semua user: index, show, like, comments
    // Pemilik  : store, update, destroy (dicek di controller)
    Route::apiResource('portfolios', PortfolioController::class);
    Route::post('portfolios/{portfolio}/like',                    [PortfolioController::class, 'like']);
    Route::get('portfolios/{portfolio}/comments',                 [PortfolioController::class, 'comments']);
    Route::post('portfolios/{portfolio}/comments',                [PortfolioController::class, 'addComment']);
    Route::delete('portfolios/{portfolio}/comments/{comment}',    [PortfolioController::class, 'deleteComment']);

    // ── JOBS ──────────────────────────────────────────────────────────────────
    // Mahasiswa: index, show (read only)
    // Admin    : store, update, destroy
    Route::get('jobs',        [JobController::class, 'index']);
    Route::get('jobs/{job}',  [JobController::class, 'show']);
    Route::middleware('role:admin_bem,super_admin')->group(function () {
        Route::post('jobs',           [JobController::class, 'store']);
        Route::put('jobs/{job}',      [JobController::class, 'update']);
        Route::patch('jobs/{job}',    [JobController::class, 'update']);
        Route::delete('jobs/{job}',   [JobController::class, 'destroy']);
    });

    // ── ALUMNI ────────────────────────────────────────────────────────────────
    // Mahasiswa: index, show (read only)
    // Admin    : store, update, destroy
    Route::get('alumni',           [AlumniController::class, 'index']);
    Route::get('alumni/{alumnus}', [AlumniController::class, 'show']);
    Route::middleware('role:admin_bem,super_admin')->group(function () {
        Route::post('alumni',              [AlumniController::class, 'store']);
        Route::put('alumni/{alumnus}',     [AlumniController::class, 'update']);
        Route::patch('alumni/{alumnus}',   [AlumniController::class, 'update']);
        Route::delete('alumni/{alumnus}',  [AlumniController::class, 'destroy']);
    });

    // ── REGISTRATIONS ─────────────────────────────────────────────────────────
    // Mahasiswa: index (milik sendiri), store, show
    // Admin    : index (semua), updateStatus
    Route::apiResource('registrations', RegistrationController::class);
    Route::put('registrations/{registration}/status',
        [RegistrationController::class, 'updateStatus']
    )->middleware('role:admin_bem,super_admin');

    // ── NOTIFICATIONS ─────────────────────────────────────────────────────────
    Route::get('notifications',                          [NotificationController::class, 'index']);
    Route::put('notifications/read-all',                 [NotificationController::class, 'markAllRead']);
    Route::put('notifications/{notification}/read',      [NotificationController::class, 'markRead']);
    Route::delete('notifications/{notification}',        [NotificationController::class, 'destroy']);
});
