
function getHorizontalOffsetForElementID(elementID) {
    var elem = document.getElementById(elementID);
    var rect = elem.getBoundingClientRect();

    return window.scrollX + rect.left;
}

function getVerticalOffsetForElementID(elementID) {
    var elem = document.getElementById(elementID);
    var rect = elem.getBoundingClientRect();

    return window.scrollY + rect.top;
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
