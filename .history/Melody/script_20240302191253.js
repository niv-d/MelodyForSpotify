var styleTags = document.getElementsByTagName('style');
                for (var i = 0; i < styleTags.length; i++) {
                    var style = styleTags[i];
                    style.innerHTML = style.innerHTML.replace(/--background-base: [^;]+;/g, '--background-base: #000;');
                }