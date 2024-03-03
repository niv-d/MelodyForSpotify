setTimeout(() => {
  links = document.querySelectorAll('a[href="/download"]');
  links.forEach((link) => (link.style.display = "none"));

  var elements = document.querySelectorAll("*:not([role])");
  elements.forEach(function (element) {
    element.style.background = "pink";
  });
}, 1000);
