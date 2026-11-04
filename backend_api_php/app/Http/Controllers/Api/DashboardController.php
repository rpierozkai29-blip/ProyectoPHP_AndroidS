<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function getResumen(Request $request)
    {
        $mesActual = Carbon::now()->month;
        $anioActual = Carbon::now()->year;

        // 1. Ingresos reales (Tabla: pagos)
        // Ajusta 'fecha_pago' y 'monto' según los nombres exactos en HeidiSQL
        $ventasMes = DB::table('pagos')
            ->whereMonth('fecha_pago', $mesActual)
            ->whereYear('fecha_pago', $anioActual)
            ->sum('monto'); 

        // 2. Nuevos alumnos (Tabla: clientes)
        $nuevosAlumnos = DB::table('clientes')
            ->whereMonth('fecha_registro', $mesActual)
            ->whereYear('fecha_registro', $anioActual)
            ->count();

        // 3. Cursos activos (Tabla: eventos)
        // Ajusta 'estado' si usas otra columna para saber si el evento está activo
        $cursosActivos = DB::table('eventos')
            ->where('estado', 1) 
            ->count();

        return response()->json([
            'ventas_mes' => $ventasMes ?? 0,
            'nuevos_alumnos' => $nuevosAlumnos,
            'cursos_activos' => $cursosActivos
        ], 200);
    }
}
