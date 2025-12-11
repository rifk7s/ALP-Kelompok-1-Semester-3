@extends('layouts.app')

@section('content')
    <h1 class="mb-4">Selamat datang, pihak Bumdes</h1>
    <h2>Pilih pekerjaan yang anda ingin lakukan</h2>

    <ul>
        <li>
            <a href="/admin/payments">Konfirmasi Pembayaran</a>
        </li>
        <li>
            <a href="/admin/hpp">Pengaturan HPP</a>
        </li>
    </ul>
@endsection