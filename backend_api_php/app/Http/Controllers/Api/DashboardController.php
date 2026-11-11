<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function getFiltrosBase()
    {
        $periodos = DB::table('periodos')->select('id', 'nombre', 'estado')->orderByDesc('id')->get();
        $categorias = DB::table('categorias')->select('id', 'nombre')->get();

        return response()->json([
            'periodos' => $periodos,
            'categorias' => $categorias
        ], 200);
    }

    public function getEventosDinamicos(Request $request)
    {
        $query = DB::table('eventos')
            ->join('cursos', 'eventos.curso_id', '=', 'cursos.id')
            ->select('eventos.id', 'eventos.nombre_evento');

        if ($request->filled('periodo_id')) {
            $query->where('eventos.periodo_id', $request->periodo_id);
        }
        if ($request->filled('categoria_id')) {
            $query->where('cursos.categoria_id', $request->categoria_id);
        }

        return response()->json($query->orderByDesc('eventos.id')->get(), 200);
    }

    public function getResumen(Request $request)
    {
        $periodoId = $request->query('periodo_id');
        $categoriaId = $request->query('categoria_id');
        $eventoId = $request->query('evento_id');

        // --- KPI: VENTAS (Tabla Pagos) ---
        $qPagos = DB::table('pagos')->where('estado', 'PAGADO');

        if ($periodoId) { $qPagos->where('periodo_id', $periodoId); }
        
        // Subconsulta cruzada para no duplicar montos de pago si una venta tiene múltiples cursos
        if ($categoriaId || $eventoId) {
            $qPagos->whereExists(function ($query) use ($categoriaId, $eventoId) {
                $query->select(DB::raw(1))
                      ->from('detalle_ventas')
                      ->join('eventos', 'detalle_ventas.evento_id', '=', 'eventos.id')
                      ->join('cursos', 'eventos.curso_id', '=', 'cursos.id')
                      ->whereColumn('detalle_ventas.venta_id', 'pagos.venta_id');

                if ($categoriaId) { $query->where('cursos.categoria_id', $categoriaId); }
                if ($eventoId) { $query->where('eventos.id', $eventoId); }
            });
        }
        $ventasTotales = $qPagos->sum('monto');

        // --- KPI: NUEVOS ALUMNOS (Tabla Clientes) ---
        $qAlumnos = DB::table('clientes');
        if ($periodoId) {
            $periodo = DB::table('periodos')->where('id', $periodoId)->first();
            if ($periodo) {
                $qAlumnos->whereBetween('fecha_registro', [$periodo->fecha_inicio . ' 00:00:00', $periodo->fecha_fin . ' 23:59:59']);
            }
        }
        // (Los clientes son transversales. Si filtras por categoría, habría que cruzar con sus matrículas)
        if ($categoriaId || $eventoId) {
            $qAlumnos->whereExists(function ($query) use ($categoriaId, $eventoId) {
                $query->select(DB::raw(1))
                      ->from('ventas')
                      ->join('detalle_ventas', 'ventas.id', '=', 'detalle_ventas.venta_id')
                      ->join('eventos', 'detalle_ventas.evento_id', '=', 'eventos.id')
                      ->join('cursos', 'eventos.curso_id', '=', 'cursos.id')
                      ->whereColumn('ventas.cliente_id', 'clientes.id');
                if ($categoriaId) { $query->where('cursos.categoria_id', $categoriaId); }
                if ($eventoId) { $query->where('eventos.id', $eventoId); }
            });
        }
        $nuevosAlumnos = $qAlumnos->count();

        // --- KPI: CURSOS ACTIVOS (Tabla Eventos) ---
        $qEventos = DB::table('eventos')
            ->join('cursos', 'eventos.curso_id', '=', 'cursos.id')
            ->where('eventos.estado', 'ABIERTO');

        if ($periodoId) { $qEventos->where('eventos.periodo_id', $periodoId); }
        if ($categoriaId) { $qEventos->where('cursos.categoria_id', $categoriaId); }
        if ($eventoId) { $qEventos->where('eventos.id', $eventoId); }
        
        $cursosActivos = $qEventos->count();

        // Si no hay filtros activos, forzamos un título de contexto
        $nombreFiltro = $periodoId ? "Periodo Seleccionado" : "Total Histórico";

        return response()->json([
            'ventas_mes' => $ventasTotales ? number_format((float)$ventasTotales, 2, '.', '') : '0.00',
            'nuevos_alumnos' => $nuevosAlumnos,
            'cursos_activos' => $cursosActivos,
            'nombre_periodo' => $nombreFiltro
        ], 200);
    }

    public function ventasTendencia(Request $request)
    {
        $periodoId = $request->query('periodo_id');
        $categoriaId = $request->query('categoria_id');
        $eventoId = $request->query('evento_id');

        $qPagos = DB::table('pagos')
            ->select(
                DB::raw('MONTH(fecha_pago) as mes_num'),
                DB::raw('SUM(monto) as total')
            )
            ->whereYear('fecha_pago', date('Y'))
            ->where('estado', 'PAGADO');

        if ($periodoId) { $qPagos->where('periodo_id', $periodoId); }

        // Cruce dimensional para filtrar la línea de tiempo por Categoría o Evento
        if ($categoriaId || $eventoId) {
            $qPagos->whereExists(function ($query) use ($categoriaId, $eventoId) {
                $query->select(DB::raw(1))
                      ->from('detalle_ventas')
                      ->join('eventos', 'detalle_ventas.evento_id', '=', 'eventos.id')
                      ->join('cursos', 'eventos.curso_id', '=', 'cursos.id')
                      ->whereColumn('detalle_ventas.venta_id', 'pagos.venta_id');

                if ($categoriaId) { $query->where('cursos.categoria_id', $categoriaId); }
                if ($eventoId) { $query->where('eventos.id', $eventoId); }
            });
        }

        $tendencia = $qPagos->groupBy('mes_num')->orderBy('mes_num')->get();

        $formateado = $tendencia->map(function ($item) {
            $nombresMeses = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
            return [
                'mes' => $nombresMeses[$item->mes_num],
                'total' => (float) $item->total
            ];
        });

        return response()->json($formateado, 200);
    }

    // Gráfico Donut: Ingresos por Método de Pago
    public function ventasPorMetodo(Request $request)
    {
        $periodoId = $request->query('periodo_id');
        $categoriaId = $request->query('categoria_id');
        $eventoId = $request->query('evento_id');

        $qPagos = DB::table('pagos')
            ->select('metodo_pago', DB::raw('SUM(monto) as total'))
            ->where('estado', 'PAGADO');

        if ($periodoId) { $qPagos->where('periodo_id', $periodoId); }

        if ($categoriaId || $eventoId) {
            $qPagos->whereExists(function ($query) use ($categoriaId, $eventoId) {
                $query->select(DB::raw(1))
                      ->from('detalle_ventas')
                      ->join('eventos', 'detalle_ventas.evento_id', '=', 'eventos.id')
                      ->join('cursos', 'eventos.curso_id', '=', 'cursos.id')
                      ->whereColumn('detalle_ventas.venta_id', 'pagos.venta_id');
                if ($categoriaId) { $query->where('cursos.categoria_id', $categoriaId); }
                if ($eventoId) { $query->where('eventos.id', $eventoId); }
            });
        }

        return response()->json($qPagos->groupBy('metodo_pago')->orderByDesc('total')->get(), 200);
    }

    // Gráfico de Barras: Ingresos por Origen de Captación
    public function ventasPorOrigen(Request $request)
    {
        $periodoId = $request->query('periodo_id');
        $categoriaId = $request->query('categoria_id');
        $eventoId = $request->query('evento_id');

        $qPagos = DB::table('pagos')
            ->join('ventas', 'pagos.venta_id', '=', 'ventas.id')
            ->join('origenes_venta', 'ventas.origen_id', '=', 'origenes_venta.id')
            ->select('origenes_venta.nombre as origen', DB::raw('SUM(pagos.monto) as total'))
            ->where('pagos.estado', 'PAGADO');

        if ($periodoId) { $qPagos->where('pagos.periodo_id', $periodoId); }

        if ($categoriaId || $eventoId) {
            $qPagos->whereExists(function ($query) use ($categoriaId, $eventoId) {
                $query->select(DB::raw(1))
                      ->from('detalle_ventas')
                      ->join('eventos', 'detalle_ventas.evento_id', '=', 'eventos.id')
                      ->join('cursos', 'eventos.curso_id', '=', 'cursos.id')
                      ->whereColumn('detalle_ventas.venta_id', 'pagos.venta_id');
                if ($categoriaId) { $query->where('cursos.categoria_id', $categoriaId); }
                if ($eventoId) { $query->where('eventos.id', $eventoId); }
            });
        }

        // Limitamos a los 5 orígenes más fuertes para no saturar el gráfico
        return response()->json($qPagos->groupBy('origenes_venta.nombre')->orderByDesc('total')->limit(5)->get(), 200);
    }
}