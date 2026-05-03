/**
 * NotesSup - Client-side JavaScript utilities
 * Form validation, modals, and UI interactions
 */

// Form validation
function validateForm(form) {
    const requiredFields = form.querySelectorAll('[required]');
    let isValid = true;

    requiredFields.forEach(field => {
        const errorGroup = field.closest('.form-group');
        if (!field.value.trim()) {
            field.classList.add('error');
            errorGroup.classList.add('error');
            isValid = false;
        } else {
            field.classList.remove('error');
            errorGroup.classList.remove('error');
        }
    });

    return isValid;
}

// Modal functions
function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('open');
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('open');
    }
}

// Close modal when clicking outside
document.addEventListener('click', function(event) {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            modal.classList.remove('open');
        }
    });
});

// Close modal when clicking close button
document.addEventListener('click', function(event) {
    if (event.target.classList.contains('modal-close')) {
        const modal = event.target.closest('.modal');
        if (modal) {
            modal.classList.remove('open');
        }
    }
});

// Format currency
function formatCurrency(value) {
    return new Intl.NumberFormat('fr-FR', {
        style: 'currency',
        currency: 'EUR'
    }).format(value);
}

// Format date
function formatDate(date) {
    return new Intl.DateTimeFormat('fr-FR', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    }).format(new Date(date));
}

// Debounce function for search
function debounce(func, delay) {
    let timeoutId;
    return function() {
        const context = this;
        const args = arguments;
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => {
            func.apply(context, args);
        }, delay);
    };
}

// Auto-submit search form on input
const searchInputs = document.querySelectorAll('[data-search="true"]');
searchInputs.forEach(input => {
    input.addEventListener('input', debounce(function() {
        this.closest('form').submit();
    }, 500));
});

// Format numbers with decimal places
function formatNumber(value, decimals = 2) {
    return new Intl.NumberFormat('fr-FR', {
        minimumFractionDigits: decimals,
        maximumFractionDigits: decimals
    }).format(value);
}

// Notification system
function showNotification(message, type = 'info', duration = 5000) {
    const notification = document.createElement('div');
    notification.className = `alert alert-${type}`;
    notification.textContent = message;
    notification.style.position = 'fixed';
    notification.style.top = '20px';
    notification.style.right = '20px';
    notification.style.zIndex = '9999';
    notification.style.maxWidth = '400px';

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.remove();
    }, duration);
}

// Initialize on document ready
document.addEventListener('DOMContentLoaded', function() {
    // Add form submit validation
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            if (!validateForm(this)) {
                e.preventDefault();
                showNotification('Veuillez remplir tous les champs obligatoires', 'warning');
            }
        });

        // Real-time field validation
        const fields = form.querySelectorAll('input[required], select[required], textarea[required]');
        fields.forEach(field => {
            field.addEventListener('blur', function() {
                if (!this.value.trim()) {
                    this.closest('.form-group').classList.add('error');
                } else {
                    this.closest('.form-group').classList.remove('error');
                }
            });
        });
    });

    // Confirm before delete
    const deleteButtons = document.querySelectorAll('[data-action="delete"]');
    deleteButtons.forEach(btn => {
        btn.addEventListener('click', function(e) {
            if (!confirm('Êtes-vous sûr de vouloir supprimer cet élément?')) {
                e.preventDefault();
            }
        });
    });

    // Table row hover effect (already in CSS, but add click event if needed)
    const tableRows = document.querySelectorAll('table tbody tr');
    tableRows.forEach(row => {
        row.addEventListener('click', function(e) {
            if (e.target.tagName !== 'A' && e.target.tagName !== 'BUTTON') {
                // Optional: navigate to edit page on row click
                const editLink = this.querySelector('a[href*="edit"]');
                if (editLink) {
                    window.location.href = editLink.href;
                }
            }
        });
    });
});

// Export utilities
function exportToCSV(tableId, filename = 'export.csv') {
    const table = document.getElementById(tableId);
    if (!table) return;

    let csv = [];
    const rows = table.querySelectorAll('tr');

    rows.forEach(row => {
        const cols = row.querySelectorAll('td, th');
        const csvRow = [];
        cols.forEach(col => {
            csvRow.push('"' + col.innerText.replace(/"/g, '""') + '"');
        });
        csv.push(csvRow.join(','));
    });

    downloadCSV(csv.join('\n'), filename);
}

function downloadCSV(csv, filename) {
    const link = document.createElement('a');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);

    link.setAttribute('href', url);
    link.setAttribute('download', filename);
    link.click();

    window.URL.revokeObjectURL(url);
}

// Print utilities
function printElement(elementId) {
    const element = document.getElementById(elementId);
    if (!element) return;

    const printWindow = window.open('', '', 'width=800,height=600');
    printWindow.document.write(element.outerHTML);
    printWindow.document.close();
    printWindow.print();
}
