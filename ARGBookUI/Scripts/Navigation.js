
function getHorizontalOffsetForElementID(elementID) {
    var elem = document.getElementById(elementID);
    var rect = elem.getBoundingClientRect();

    return rect.height > window.innerHeight ? 0.0 : window.scrollX + rect.left;
}

function scrollByVerticalToElementID(elementID) {
    var elem = document.getElementById(elementID);
    var elemRect = elem.getBoundingClientRect();
    var offsetY = elemRect.height > window.innerHeight ? 0.0 : elemRect.top;
    
    window.scrollTo(0, offsetY);

    return offsetY;
}

function scrollByHorizontalToElementID(elementID) {
    var elem = document.getElementById(elementID);
    var elemRect = elem.getBoundingClientRect();
    var offsetX = elemRect.width > window.innerWidth ? 0.0 : elemRect.left;
    
    window.scrollTo(0, offsetX);

    return offsetX;
}

function setHorizontalOffset(offsetX) {
    window.scrollTo(offsetX, 0);

    var spans = document.getElementsByClassName("arg_word_span");

    for (var i = 0; i < spans.length ; i++) {
        var span = spans[i];

        if (span.getBoundingClientRect().left >= 0) {
            return {"id": span.id, "word": span.textContent, "offset" : window.scrollX};
        };
    };

    return {"offset" : window.scrollX};
}

function firstVisibleSpanElement() {
    var spans = document.getElementsByClassName("arg_word_span");

    for (var i = 0; i < spans.length ; i++) {
        var span = spans[i];

        if (span.getBoundingClientRect().left >= 0 && span.getBoundingClientRect().top >= 0) {
            return {"id": span.id, "word": span.textContent, "rect" : span.getBoundingClientRect().toJSON()};
        };
    };

    return {};
}
