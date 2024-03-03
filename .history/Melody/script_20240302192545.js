setTimeout(() => {
  links = document.querySelectorAll('a[href="/download"]');
  links.forEach((link) => (link.style.display = "none"));
  
}, 1000);