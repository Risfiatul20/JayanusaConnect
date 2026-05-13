<?php

use App\Http\Controllers\Api\AlumniController;
use App\Http\Controllers\Api\AspirationController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BemProgramController;
use App\Http\Controllers\Api\JobController;
use App\Http\Controllers\Api\PortfolioController;
use App\Http\Controllers\Api\RegistrationController;
use App\Http\Controllers\Api\TrainingController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);
    
    // Aspirations
    Route::apiResource('aspirations', AspirationController::class);
    Route::put('aspirations/{aspiration}/status', [AspirationController::class, 'updateStatus']);
    
    // BEM Programs
    Route::apiResource('bem-programs', BemProgramController::class);
    
    // Trainings
    Route::apiResource('trainings', TrainingController::class);
    Route::post('trainings/{training}/register', [TrainingController::class, 'register']);
    
    // Portfolios
    Route::apiResource('portfolios', PortfolioController::class);
    Route::post('portfolios/{portfolio}/like', [PortfolioController::class, 'like']);
    
    // Jobs
    Route::apiResource('jobs', JobController::class);
    
    // Alumni
    Route::apiResource('alumni', AlumniController::class);
    
    // Registrations
    Route::apiResource('registrations', RegistrationController::class);
    Route::put('registrations/{registration}/status', [RegistrationController::class, 'updateStatus']);
});
