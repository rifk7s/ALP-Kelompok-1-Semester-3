@extends('layouts.app')

@section('content')
<main class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-4">
            <h3 class="text-center mb-4">Admin Login - BUMDes</h3>
            
            <div id="error" class="alert alert-danger d-none"></div>
            
            <form id="loginForm">
                <div class="mb-3">
                    <label>Phone</label>
                    <input type="text" id="phone" class="form-control" required>
                </div>
                
                <div class="mb-3">
                    <label>Password</label>
                    <input type="password" id="password" class="form-control" required>
                </div>
                
                <button type="submit" class="btn btn-primary w-100">Login</button>
            </form>
        </div>
    </div>
</main>
@endsection

@section('scripts')
<script>
    document.getElementById('loginForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        fetch('/api/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                phone: document.getElementById('phone').value,
                password: document.getElementById('password').value
            })
        })
        .then(res => res.json())
        .then(data => {
            if (data.access_token) {
                // Store token in localStorage
                localStorage.setItem('admin_token', data.access_token);
                localStorage.setItem('admin_user', JSON.stringify(data.user));
                
                // Check if user is bumdes
                if (data.user.role !== 'bumdes') {
                    document.getElementById('error').textContent = 'Access denied. Admin only.';
                    document.getElementById('error').classList.remove('d-none');
                    localStorage.clear();
                    return;
                }
                
                // Redirect to dashboard
                window.location.href = '/admin';
            } else {
                document.getElementById('error').textContent = data.message || 'Login failed';
                document.getElementById('error').classList.remove('d-none');
            }
        })
        .catch(err => {
            document.getElementById('error').textContent = 'Login failed';
            document.getElementById('error').classList.remove('d-none');
        });
    });
</script>

@endsection