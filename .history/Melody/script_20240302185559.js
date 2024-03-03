var elements = document.querySelectorAll('[style*="background-color: rgb(56, 56, 56)"]');
for (var i = 0; i < elements.length; i++) {
    elements[i].style.backgroundColor = '#000';
}