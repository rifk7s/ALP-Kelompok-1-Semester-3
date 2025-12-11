@extends('layouts.app')

@section('content')
<div class="container mt-4">

    <h3 class="mb-4">Price List</h3>

    <table class="table table-bordered" id="priceTable">
        <thead>
            <tr>
                <th>Category (ID)</th>
                <th>Variety</th>
                <th>Price</th>
                <th>Source</th>
                <th>Effective Date</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <!-- Filled by AJAX -->
        </tbody>
    </table>
</div>
<!-- EDIT MODAL -->
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog">
        <form id="editForm">
            @csrf
            @method('PUT')
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit Price</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <input type="hidden" id="edit_id">

                    <div class="mb-3">
                        <label>Variety</label>
                        <input type="text" id="edit_variety" class="form-control">
                    </div>

                    <div class="mb-3">
                        <label>Price</label>
                        <input type="number" id="edit_price" class="form-control">
                    </div>

                </div>

                <div class="modal-footer">
                    <button class="btn btn-primary" type="submit">Update</button>
                    <button class="btn btn-secondary" type="button" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </form>
    </div>
</div>
<!-- DELETE MODAL -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog">
        <form id="deleteForm">
            @csrf
            @method('DELETE')

            <input type="hidden" id="delete_id">

            <div class="modal-content">
                <div class="modal-body text-center">
                    <h5>Are you sure you want to delete this price?</h5>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-danger" type="submit">Delete</button>
                    <button class="btn btn-secondary" type="button" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>

        </form>
    </div>
</div>
<!-- ADD MODAL -->
<div class="modal fade" id="addModal" tabindex="-1">
    <div class="modal-dialog">
        <form id="addForm">
            @csrf

            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add Data</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Add Mode</label><br>

                        <input type="radio" name="add_mode" id="mode_category" value="category" checked>
                        <label for="mode_category">New Category</label>

                        <input type="radio" name="add_mode" id="mode_variety" value="variety" class="ms-3">
                        <label for="mode_variety">Add Variety to Category</label>
                    </div>

                    <!-- New category name -->
                    <div class="mb-3" id="category_name_group">
                        <label>Category Name</label>
                        <input type="text" id="add_category_name" class="form-control">
                    </div>

                    <!-- Selecting existing category -->
                    <div class="mb-3" id="category_select_group" style="display:none;">
                        <label>Select Category</label>
                        <select id="add_category" class="form-select"></select>
                    </div>

                    <!-- Variety -->
                    <div class="mb-3" id="variety_group" style="display:none;">
                        <label>Variety</label>
                        <input type="text" id="add_variety" class="form-control">
                    </div>

                    <!-- Price -->
                    <div class="mb-3" id="price_group" style="display:none;">
                        <label>Price</label>
                        <input type="number" id="add_price" class="form-control">
                    </div>

                </div>

                <div class="modal-footer">
                    <button class="btn btn-success" type="submit">Create</button>
                    <button class="btn btn-secondary" type="button" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </form>
    </div>
</div>

@endsection

@section('scripts')
<script>
document.addEventListener('DOMContentLoaded', function () {
    loadPrices();

    function loadPrices() {
    fetch('/api/prices')
        .then(res => res.json())
        .then(data => {
            // ========================
            // SORT by category name ASC
            // ========================
            data.sort((a, b) => a.category.name.localeCompare(b.category_id));

            // ========================
            // GROUP by category_id
            // ========================
            let grouped = {};
            data.forEach(item => {
                if (!grouped[item.category_id]) {
                    grouped[item.category_id] = {
                        category: item.category,
                        rows: []
                    };
                }
                grouped[item.category_id].rows.push(item);
            });

            let html = '';

            // ========================
            // BUILD table with row merging
            // ========================
            Object.values(grouped).forEach(group => {
                let rowspan = group.rows.length;

                group.rows.forEach((item, index) => {
                    html += `<tr>`;

                    // Only output category cell for the *first* row in the group
                    if (index === 0) {
                        html += `
                            <td rowspan="${rowspan}">
                                ${item.category.name} (#${item.category_id})
                            </td>
                        `;
                    }

                    html += `
                        <td>${item.variety ?? '-'}</td>
                        <td>${item.price_per_kg}</td>
                        <td>${item.source}</td>
                        <td>${item.effective_date}</td>
                        <td>
                            <button class="btn btn-sm btn-warning"
                                onclick="openEdit(${item.id}, '${item.variety ?? ''}', ${item.price_per_kg})">
                                Edit
                            </button>

                            <button class="btn btn-sm btn-danger"
                                onclick="openDelete(${item.id})">
                                Delete
                            </button>
                        </td>
                    </tr>`;
                });
            });

            // ========================
            // ADD EMPTY ROW FOR CREATION
            // ========================
            html += `
                <tr class="table-light">
                    <td colspan="5" class="text-center text-muted">
                        Add a new variety and price
                    </td>
                    <td>
                        <button class="btn btn-sm btn-success" onclick="openAdd()">
                            Add
                        </button>
                    </td>
                </tr>
            `;

            document.querySelector('#priceTable tbody').innerHTML = html;
        });
    }

    function loadCategories() {
        fetch('/api/products/categories')
            .then(res => res.json())
            .then(data => {
                let select = document.getElementById('add_category');
                select.innerHTML = '';

                data.forEach(cat => {
                    select.innerHTML += `<option value="${cat.id}">${cat.name}</option>`;
                });
            });
    }

    // OPEN EDIT POPUP
    window.openEdit = function(id, variety, price_per_kg) {
        document.getElementById('edit_id').value = id;
        document.getElementById('edit_variety').value = variety;
        document.getElementById('edit_price').value = price_per_kg;

        new bootstrap.Modal(document.getElementById('editModal')).show();
    };

    // SUBMIT EDIT
    document.getElementById('editForm').addEventListener('submit', function(e){
        e.preventDefault();

        let id = document.getElementById('edit_id').value;

        fetch(`/api/prices/${id}`, {
            method: 'PUT',
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                variety: document.getElementById('edit_variety').value,
                price_per_kg: document.getElementById('edit_price').value
            })
        })
        .then(() => {
            loadPrices();
            bootstrap.Modal.getInstance(document.getElementById('editModal')).hide();
        });
    });

    // OPEN DELETE POPUP
    window.openDelete = function(id) {
        document.getElementById('delete_id').value = id;
        new bootstrap.Modal(document.getElementById('deleteModal')).show();
    };

    // SUBMIT DELETE
    document.getElementById('deleteForm').addEventListener('submit', function(e){
        e.preventDefault();

        let id = document.getElementById('delete_id').value;

        fetch(`/api/prices/${id}`, {
            method: 'DELETE'
        })
        .then(() => {
            loadPrices();
            bootstrap.Modal.getInstance(document.getElementById('deleteModal')).hide();
        });
    });
    function updateAddMode() {
        const mode = document.querySelector('input[name="add_mode"]:checked').value;

        if (mode === 'category') {
            // Show category name input
            document.getElementById('category_name_group').style.display = 'block';

            // Hide variety mode inputs
            document.getElementById('category_select_group').style.display = 'none';
            document.getElementById('variety_group').style.display = 'none';
            document.getElementById('price_group').style.display = 'none';
        } else {
            // Show variety mode inputs
            document.getElementById('category_name_group').style.display = 'none';
            document.getElementById('category_select_group').style.display = 'block';
            document.getElementById('variety_group').style.display = 'block';
            document.getElementById('price_group').style.display = 'block';

            loadCategories();
        }
    }

    // OPEN ADD POPUP
    window.openAdd = function() {
        updateAddMode();
        document.querySelectorAll('input[name="add_mode"]').forEach(r =>
            r.addEventListener('change', updateAddMode)
        );

        new bootstrap.Modal(document.getElementById('addModal')).show();
    };

    // SUBMIT ADD
    document.getElementById('addForm').addEventListener('submit', function(e){
        e.preventDefault();

        const mode = document.querySelector('input[name="add_mode"]:checked').value;
        const modal = bootstrap.Modal.getInstance(document.getElementById('addModal'));

        if (mode === 'category') {
            fetch('/api/products/categories', {
                method: 'POST',
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    name: document.getElementById('add_category_name').value,
                    slug: document.getElementById('add_category_name').value.toLowerCase().replace(/\s+/g, '-')
                })
            })
            .then(() => {
                loadPrices();
                modal.hide();
            });
        } else {
            fetch('/api/prices', {
                method: 'POST',
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    category_id: document.getElementById('add_category').value,
                    variety: document.getElementById('add_variety').value,
                    price_per_kg: document.getElementById('add_price').value
                })
            })
            .then(() => {
                loadPrices();
                modal.hide();
            });
        }
    });

});
</script>
@endsection
