<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'usuario' => 'required|string',
            'password' => 'required'
        ]);

        // 1. Busca al usuario en la base de datos
        $user = \App\Models\User::where('usuario', $request->usuario)->first();

        // 2. Compara la contraseña en texto plano
        if (!$user || $user->password !== $request->password) {
            return response()->json(['message' => 'Credenciales incorrectas'], 401);
        }

        // 3. Genera el token si todo es correcto
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login exitoso',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ], 200);
    }
}