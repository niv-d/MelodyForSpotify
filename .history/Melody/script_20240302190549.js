var sheets = document.styleSheets;
for (var i = 0; i < sheets.length; i++) {
  var rules = sheets[i].cssRules;
  if (rules) {
    for (var j = 0; j < rules.length; j++) {
      var rule = rules[j];
      if (rule.type === 1) {
        rule.style.setProperty("--background-base", "#000", "important");
      }
    }
  }
}
