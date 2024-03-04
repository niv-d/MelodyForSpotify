setTimeout(() => {
  links = document.querySelectorAll('a[href="/download"]');
  links.forEach((link) => (link.style.display = "none"));

  var elements = document.querySelectorAll("*:not([data-testid])");
  elements.forEach(function (element) {
    element.style.backgroundColor = "#0000";
  });

  document.addEventListener('contextmenu', event => {
    event.preventDefault();
});
}, 400);
