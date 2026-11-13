<?php
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;

Route::post('/login', [AuthController::class, 'login']);
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/dashboard/resumen', [DashboardController::class, 'getResumen']);
    Route::get('/dashboard/ventas-tendencia', [DashboardController::class, 'ventasTendencia']);
    Route::get('/dashboard/filtros/base', [DashboardController::class, 'getFiltrosBase']);
    Route::get('/dashboard/filtros/eventos', [DashboardController::class, 'getEventosDinamicos']);
    Route::get('/dashboard/ventas-metodos', [DashboardController::class, 'ventasPorMetodo']);
    Route::get('/dashboard/ventas-origenes', [DashboardController::class, 'ventasPorOrigen']);
    Route::get('/dashboard/cursos-top', [DashboardController::class, 'cursosTop']);
    Route::get('/dashboard/cursos-ocupacion', [DashboardController::class, 'cursosOcupacion']);
    Route::get('/dashboard/clientes-distritos', [DashboardController::class, 'clientesPorDistrito']);
    Route::get('/dashboard/clientes-evolucion', [DashboardController::class, 'clientesEvolucion']);
});