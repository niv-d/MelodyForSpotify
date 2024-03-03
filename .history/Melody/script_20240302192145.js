var links = document.querySelectorAll('a[href="/download"]');
links.forEach((link) => (link.style.display = "none"));
document.onload = () => {
  links = document.querySelectorAll('a[href="/download"]');
  links.forEach((link) => (link.style.display = "none"));
  console.log(links);
}

setTimeout(() => {
  links = document.querySelectorAll('a[href="/download"]');
  links.forEach((link) => (link.style.display = "none"));
  console.log(links);
}
, 1000);