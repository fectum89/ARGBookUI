var mySheet;

function onLoadSetup() {
    setCSSRule('body', 'margin', '0px');

    setCSSRule('h1', 'word-wrap', 'break-word');
    setCSSRule('h2', 'word-wrap', 'break-word');
    setCSSRule('a', 'word-wrap', 'break-word');
    setCSSRule('a:link', 'color', 'rgb(33, 150, 243)');
    setCSSRule('a', 'text-decoration', 'none');
    setCSSRule('p', 'line-height', 'normal');
    setCSSRule('li', 'line-height', 'normal');
    
    setCSSRule('body', 'background-color', 'transparent');
}

function setViewportWidth(viewportWidth) {
    var viewport = document.querySelector('meta[name=viewport]');
    if (!viewport) {
        viewport = document.createElement('meta');
        viewport.name = 'viewport';
        viewport.id = 'viewport';
        var head = document.getElementsByTagName('head')[0];
        head.appendChild(viewport);
    }
    
    var value;
    var scale = 1.0;
    value = 'initial-scale=' + scale + ', minimum-scale=' + scale + ', maximum-scale=' + scale + ', user-scalable=no';
    
    if (viewportWidth > 0) {
        value += ', width=' + viewportWidth;
    }
    
    viewport.setAttribute('content', value);
}

function setCSSRule(selector, property, value) {
    if (typeof selector === 'string' || selector instanceof String) {
        selector = getCSSRule(selector);
    }
    
    if (typeof selector !== 'undefined') {
        selector.style.setProperty(property, value, 'important');
    }
}

function getCSSRule(selector) {
    if (document.head == null) {
        return;
    }
    
    if (!mySheet) {
        var style = document.createElement("style");

        style.appendChild(document.createTextNode("")); //webkit hack

        document.head.appendChild(style);
        
        mySheet = style.sheet;
    }
    
    var cssRules = (mySheet && mySheet.cssRules) ? mySheet.cssRules : [];
    for (var i = 0; i < cssRules.length; i++) {
        var cssRule = cssRules[i];
        if (cssRule && cssRule.selectorText && cssRule.selectorText.toLowerCase() == selector) {
            return cssRule;
        }
    }
    
    var newRuleIndex = cssRules.length;
    mySheet.insertRule(selector + '{ }', newRuleIndex);
    return mySheet.cssRules[newRuleIndex];
}

function setPageSettings(pageWidth, pageHeight, topInset, rightInset, bottomInset, leftInset) {
    columnWidth = pageWidth;
    columnGap = (rightInset + leftInset);
    
    setPadding(topInset, rightInset, bottomInset, leftInset);
    
    setMaxMediaContentSize('img', pageWidth, pageHeight);
    setMaxMediaContentSize('svg', pageWidth, pageHeight);
    setMaxMediaContentSize('iframe', pageWidth, pageHeight);
    setMaxMediaContentSize('frame', pageWidth, pageHeight);
    setMaxMediaContentSize('video', pageWidth, pageHeight);
    
    var css = getCSSRule('html');
    setCSSRule(css, 'height', pageHeight + 'px');
    setCSSRule(css, '-webkit-column-width', columnWidth + 'px');
    setCSSRule(css, '-webkit-column-gap', columnGap + 'px');
    setCSSRule(css, '-webkit-column-fill', 'auto');
}

function setPadding(top, right, bottom, left) {
    var padding = top + 'px ' + right + 'px ' + bottom + 'px ' + left + 'px';
    setCSSRule('html', 'padding', padding);
}

function setMaxMediaContentSize(media, pageWidth, pageHeight) {
    var mediaCSS = getCSSRule(media);
    setCSSRule(mediaCSS, 'max-width', 'MIN(100%, ' + pageWidth + 'px)');
    setCSSRule(mediaCSS, 'max-height', 'MIN(100%, ' + pageHeight + 'px)');
    setCSSRule(mediaCSS, 'display', 'block');
    setCSSRule(mediaCSS, 'margin', 'auto');
}

function setFontSize(fontSize) {
    var scale = (fontSize / 100.0) || 1.0;
    var bodyFontSize = Math.round(16.0 * scale);
    setCSSRule('body', 'font-size', bodyFontSize + 'px');
    setCSSRule('div', 'font-size', bodyFontSize + 'px');
    setCSSRule('p', 'font-size', bodyFontSize + 'px');
    //setCSSRule('body', '-webkit-text-size-adjust', fontSize + '%%');
}

function addFontFamily(fontFamily, fontURL) {
    var fontfaceCSS = getCSSRule('@font-face');
    //var srcRule = 'local(\'' + fontFamily + '\'), url(\'' + fontURL + '\') format(\'' + 'opentype' + '\')';

    var srcRule = 'url(\'' + fontURL + '\')';

    setCSSRule(fontfaceCSS, 'font-family', fontFamily);
    setCSSRule(fontfaceCSS, 'src', srcRule);
    //'local(\'CharlotteSansW02-Book\'), url(\'Charlotte Sans Book.otf\') format(\'opentype\')'
}

function setFontFamily(fontFamily) {
    document.body.style.fontFamily = fontFamily;
}

function hyphenate(enabled) {
//    var htmlElement = document.getElementsByTagName('html')[0];
//    htmlElement.setAttribute('lang', language);

    var state;
    
    if (enabled) {
        state = 'auto';
    } else {
        state = 'none';
    }

    setCSSRule('p', '-webkit-hyphens', state);
    setCSSRule('li', '-webkit-hyphens', state);
    setCSSRule('div', '-webkit-hyphens', state);
}

function setTextAlignment(alignment) {
    setCSSRule('p', 'text-align', alignment);
    setCSSRule('div', 'text-align', alignment);
}

function setTextColor(color) {
    setCSSRule('body', 'color', color);
    setCSSRule('p', 'color', color);
    setCSSRule('div', 'color', color);
}

function setIndent(indent) {
    setCSSRule('p', 'text-indent', indent + '%%');
}

function setHighlightColor(color) {
    setCSSRule('highlight', "background-color", color);
}
