

var searchResultCount = 0;

var console = "\n";
var results = "";
var searching = 0;

var neighSize = 20;

// the main entry point to start the search
function highlightAllOccurencesOfString(keyword) {
    removeAllHighlights();
    highlightAllOccurencesOfStringForElement(document.body, keyword.toLowerCase());
}

// the main entry point to remove the highlights
function removeAllHighlights() {
    window.getSelection().removeAllRanges();
    document.getSelection().removeAllRanges();
    
    if (window.getSelection) {window.getSelection().removeAllRanges();}
    else if (document.selection) {document.selection.empty();}
    
    searchResultCount = 0;
    removeAllHighlightsForElement(document.body);
}

function checkForHref(element) {
    if (element == null) {
        return false;
    }
    
    if (element.tagName.toLowerCase() == "a" && element.hasAttribute("href")) {
        return true;
    } else {
        return checkForHref(element.parentElement);
    }
}

// get word at point (in html with span-wrapped words)
function wordAtPoint(x,y) {
    var span = document.elementFromPoint(x,y);
    
    if (span && span.childNodes.length > 0) {
        var textNode = span.childNodes[0];
        var text = textNode.nodeValue;

        if (text) {
            let surroundings = surroundingsForSpan(span);
            removeAllHighlights();
            highlightAllOccurencesOfStringForElement(textNode, text);
            var rect = span.getBoundingClientRect();

            return {"word" : text,
                    "rect" : "{{" + rect.left + "," + rect.top + "},{" + rect.width + "," + rect.height + "}}",
                    "context" : surroundings.text,
                    "first": surroundings.firstSpanID,
                    "last": surroundings.lastSpanID,
                    "link": checkForHref(span.parentElement)};
        };
    }

    return {"word" : ""};
}

function surroundingsForSpan(span) {
    let parentElement = span.parentElement;
    let spans = Array.from(parentElement.children);
    let spanIndex = spans.indexOf(span);
    let leftFragment = [];
    let rightFragment = [];
    const maxSurroundingsWordsCount = 15;
    let regex = /[.?!]/
    let firstSpanID = "";
    let lastSpanID = "";

    if (spanIndex > 0) {
        for (let index = spanIndex - 1, wordsCount = 0; index >= 0 && wordsCount < maxSurroundingsWordsCount; index--, wordsCount++) {
            const element = spans[index];
            
            if (!regex.test(element.innerText)) {
                leftFragment.unshift(element.innerText);
                firstSpanID = element.id;
            } else {
                break;
            }
        }
    } else {
        firstSpanID = span.id;
    }

    for (let index = spanIndex, wordsCount = 0; index < spans.length && wordsCount < maxSurroundingsWordsCount; index++, wordsCount++) {
        const element = spans[index];
        
        rightFragment.push(element.innerText);
        lastSpanID = element.id;

        if (regex.test(element.innerText)) {
            break;
        }
    }

    let resultWordsList = leftFragment.concat(rightFragment);
    let result = {
        text: resultWordsList.join(' '),
        firstSpanID: firstSpanID,
        lastSpanID: lastSpanID
    }

    return result;

}

// get selected text
function getSelectedText() {
    sel = window.getSelection();
    
    if (sel.rangeCount) {
        range = sel.getRangeAt(0).cloneRange();
        
        if (range.getBoundingClientRect) {
            var rect = range.getBoundingClientRect();
            let anchorNode = sel.anchorNode;
            let span = anchorNode.parentElement;
            let surroundings = null;

            if (span.tagName.toLowerCase() == "span") {
                surroundings = surroundingsForSpan(span)
            }

            return {"word" : sel.toString(), 
                    "rect" : "{{" + rect.left + "," + rect.top + "},{" + rect.width + "," + rect.height + "}}",
                    "context" : surroundings.text,
                    "first": surroundings.firstSpanID,
                    "last": surroundings.lastSpanID
                };
        }
    }
    
    return {"word" : ""};
}

// helper function, recursively searches in elements and their child nodes
function highlightAllOccurencesOfStringForElement(element,keyword) {
    if (element) {
        if (element.nodeType == 3) {// Text node
            while (true) {
                var value = element.nodeValue;  // Search for keyword in text node
                var idx = value.toLowerCase().indexOf(keyword.toLowerCase());
                                                
                if (idx < 0) break;             // not found, abort
                
                var span = document.createElement("highlight");
                span.className = "ARGHighlight";
                var text = document.createTextNode(value.substr(idx,keyword.length));
                span.appendChild(text);
                
                var rightText = document.createTextNode(value.substr(idx+keyword.length));
                element.deleteData(idx, value.length - idx);
                                
                var next = element.nextSibling;
                element.parentNode.insertBefore(rightText, next);
                element.parentNode.insertBefore(span, rightText);
                
                var leftNeighText = element.nodeValue.substr(element.length - neighSize, neighSize);
                var rightNeighText = rightText.nodeValue.substr(0, neighSize);

                element = rightText;
                searchResultCount++;	// update the counter
                
                console += "Span className: " + span.className + "\n";
                console += "Span position: (" + getPos(span).x + ", " + getPos(span).y + ")\n";
                
                results += getPos(span).x + "," + getPos(span).y + "," + escape(text.nodeValue) + "," + escape(leftNeighText + text.nodeValue + rightNeighText) + ";";
                
                results;
            }
        } else if (element.nodeType == 1) { // Element node
            if (element.style.display != "none" && element.nodeName.toLowerCase() != 'select') {
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    highlightAllOccurencesOfStringForElement(element.childNodes[i],keyword);
                }
            }
        }
    }
}


function getPos(el) {
    // yay readability
    for (var lx=0, ly=0; el != null; lx += el.offsetLeft, ly += el.offsetTop, el = el.offsetParent);
    return {x: lx,y: ly};
}

// helper function, recursively removes the highlights in elements and their childs
function removeAllHighlightsForElement(element) {
    if (element) {
        if (element.nodeType == 1) {
            if (element.getAttribute("class") == "ARGHighlight") {
                var text = element.removeChild(element.firstChild);
                element.parentNode.insertBefore(text,element);
                element.parentNode.removeChild(element);
                return true;
            } else {
                var normalize = false;
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    if (removeAllHighlightsForElement(element.childNodes[i])) {
                        normalize = true;
                    }
                }
                if (normalize) {
                    element.normalize();
                }
            }
        }
    }
    return false;
}


