const API_URL = 'http://localhost:5000';

// ===== Authentication Logic =====
const loginForm = document.getElementById('loginForm');
const registerForm = document.getElementById('registerForm');

if (loginForm) {
    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        const msgDiv = document.getElementById('authMessage');

        try {
            const res = await fetch(`${API_URL}/auth/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password })
            });
            const data = await res.json();

            if (res.ok) {
                localStorage.setItem('token', data.token);
                localStorage.setItem('userEmail', data.email);
                localStorage.setItem('role', data.role);

                if (data.role === 'owner') {
                    window.location.href = 'owner-dashboard.html';
                } else {
                    window.location.href = 'index.html';
                }
            } else {
                msgDiv.className = 'message error';
                msgDiv.textContent = data.message || 'Login failed';
            }
        } catch (err) {
            msgDiv.className = 'message error';
            msgDiv.textContent = 'Server error. Try again.';
        }
    });
}


function logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('userEmail');
    localStorage.removeItem('role');
    window.location.href = 'login.html';
}

const getAuthHeaders = () => {
    return {
        'Authorization': `Bearer ${localStorage.getItem('token')}`,
        'Content-Type': 'application/json'
    };
}


// ===== Dashboard Logic =====
function initDashboard() {
    const userEmailSpan = document.getElementById('userEmail');
    if (userEmailSpan) {
        userEmailSpan.textContent = localStorage.getItem('userEmail') || 'User';
    }

    // Auto-calculate total in form
    const litresInput = document.getElementById('litres');
    const priceInput = document.getElementById('pricePerLitre');
    const totalDisplay = document.getElementById('totalAmountDisplay');

    const updateTotal = () => {
        const l = parseFloat(litresInput.value) || 0;
        const p = parseFloat(priceInput.value) || 0;
        totalDisplay.value = `$${(l * p).toFixed(2)}`;
    };

    if (litresInput && priceInput) {
        litresInput.addEventListener('input', updateTotal);
        priceInput.addEventListener('input', updateTotal);
    }

    const addFuelForm = document.getElementById('addFuelForm');
    if (addFuelForm) {
        // Pre-fill date with today
        document.getElementById('date').valueAsDate = new Date();

        addFuelForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const msgDiv = document.getElementById('formMessage');
            msgDiv.textContent = 'Saving...';
            msgDiv.className = 'message';

            const payload = {
                date: document.getElementById('date').value,
                vehicleNumber: document.getElementById('vehicleNumber').value,
                litres: parseFloat(document.getElementById('litres').value),
                pricePerLitre: parseFloat(document.getElementById('pricePerLitre').value),
                instructorName: document.getElementById('instructorName').value
            };

            try {
                const res = await fetch(`${API_URL}/fuel/add`, {
                    method: 'POST',
                    headers: getAuthHeaders(),
                    body: JSON.stringify(payload)
                });

                const data = await res.json();

                if (res.ok) {
                    msgDiv.className = 'message success';
                    msgDiv.textContent = 'Transaction saved! Generating bill...';
                    addFuelForm.reset();
                    document.getElementById('date').valueAsDate = new Date();
                    updateTotal();
                    fetchRecords();

                    // Generate and Download PDF
                    window.open(`${API_URL}/fuel/${data._id}/bill?token=${localStorage.getItem('token')}`, '_blank');

                    // Since we open in a new tab but our auth is Bearer token, we can't directly use window.open with headers.
                    // Let's implement programmatic blob download to preserve headers.
                    downloadBill(data._id);
                } else {
                    msgDiv.className = 'message error';
                    msgDiv.textContent = data.message || 'Error saving record';
                }
            } catch (err) {
                console.error(err);
                msgDiv.className = 'message error';
                msgDiv.textContent = 'Server error';
            }
        });
    }

    fetchRecords();
}

async function fetchRecords() {
    const tbody = document.getElementById('recordsBody');
    const loader = document.getElementById('tableLoading');
    if (!tbody || !loader) return;

    loader.classList.remove('hidden');
    tbody.innerHTML = '';

    try {
        const res = await fetch(`${API_URL}/fuel/all`, {
            headers: getAuthHeaders()
        });

        if (!res.ok) {
            if (res.status === 401) logout();
            throw new Error('Failed to fetch');
        }

        const data = await res.json();

        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;">No records found.</td></tr>';
        } else {
            data.forEach(record => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${new Date(record.date).toLocaleDateString()}</td>
                    <td><strong>${record.vehicleNumber}</strong></td>
                    <td>${record.instructorName}</td>
                    <td>${record.litres.toFixed(2)} L</td>
                    <td>$${record.pricePerLitre.toFixed(2)}</td>
                    <td>$${record.totalAmount.toFixed(2)}</td>
                    <td>
                        <button class="btn btn-success" onclick="downloadBill('${record._id}')">Download Bill</button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }
    } catch (error) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;color:red;">Error loading records.</td></tr>';
    } finally {
        loader.classList.add('hidden');
    }
}

async function downloadBill(id) {
    try {
        const res = await fetch(`${API_URL}/fuel/${id}/bill`, {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('token')}`
            }
        });

        if (!res.ok) {
            alert('Failed to generate bill');
            return;
        }

        const blob = await res.blob();

        // Extract filename from header if present
        let filename = `Bill-${id}.pdf`;
        const disposition = res.headers.get('Content-Disposition');
        if (disposition && disposition.indexOf('filename=') !== -1) {
            const filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/;
            const matches = filenameRegex.exec(disposition);
            if (matches != null && matches[1]) {
                filename = matches[1].replace(/['"]/g, '');
            }
        }

        // Create a download link and click it
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.style.display = 'none';
        a.href = url;
        a.download = decodeURIComponent(filename);
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);

    } catch (e) {
        console.error(e);
        alert('Error downloading bill.');
    }
}

// ===== Owner Dashboard Logic =====
function initOwnerDashboard() {
    const userEmailSpan = document.getElementById('userEmail');
    if (userEmailSpan) {
        userEmailSpan.textContent = localStorage.getItem('userEmail') || 'Owner';
    }
    fetchGlobalRecords();
}

async function fetchGlobalRecords() {
    const tbody = document.getElementById('ownerRecordsBody');
    const loader = document.getElementById('tableLoading');
    if (!tbody || !loader) return;

    loader.classList.remove('hidden');
    tbody.innerHTML = '';

    try {
        const res = await fetch(`${API_URL}/fuel/global`, {
            headers: getAuthHeaders()
        });

        if (!res.ok) {
            if (res.status === 401 || res.status === 403) logout();
            throw new Error('Failed to fetch global records');
        }

        const data = await res.json();

        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;">No global records found in the system.</td></tr>';
        } else {
            data.forEach(record => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${new Date(record.date).toLocaleDateString()}</td>
                    <td><strong>${record.vehicleNumber}</strong></td>
                    <td>${record.litres.toFixed(2)} L</td>
                    <td>$${record.pricePerLitre.toFixed(2)}</td>
                    <td>$${record.totalAmount.toFixed(2)}</td>
                    <td>
                        <button class="btn btn-primary" onclick="downloadBill('${record._id}')">Download Bill</button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }
    } catch (error) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:red;">Error loading global records.</td></tr>';
    } finally {
        loader.classList.add('hidden');
    }
}
