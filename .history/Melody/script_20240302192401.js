setTimeout(() => {
  links = document.querySelectorAll('a[href="/download"]');
  links.forEach((link) => (link.style.display = "none"));
  console.log(links);
  var styleElements = document.querySelectorAll('style');
                styleElements.forEach(function(style) {
                    var cssText = style.innerHTML;
                    var updatedCssText = cssText.replace(/--background-color:\s*(.*?);/g, '--background-color: rgba(0, 0, 0, 0);');
                    style.innerHTML = updatedCssText;
                });
}, 1000);