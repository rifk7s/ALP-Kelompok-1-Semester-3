@extends('layouts.app')

@section('content')
    <h1 class="mt-4">Selamat datang, pihak Bumdes</h1>
    <h2>Pilih pekerjaan yang anda ingin lakukan</h2>

    <ul>
        <li>
            <a href="{{ url('/admin/payments') }}">Konfirmasi Pembayaran</a>
        </li>
        <li>
            <a href="{{ url('/admin/hpp') }}">Pengaturan HPP</a>
        </li>
    </ul>

    <button class="btn btn-danger mt-3" onclick="logout()">Logout</button>
@endsection

@section('scripts')
<script>
    function logout() {
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_user');
        window.location.href = '/';
    }
</script>
@endsection