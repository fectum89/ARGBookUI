function prepareDocument() {
    if (document.head == null) {
        return;
    }
    splitWords(document.body);
    return document.documentElement.outerHTML;
}

//prepareDocument();

function splitWords(top) {
    var node = top.firstChild, words, newNode, idCntr = 1, skipChild;
    var re = /\S/;
    while(node && node != top) {
        skipChild = false;
        // if text node, check for our text
        if (node.nodeType == 3) {
            if (re.test(node.nodeValue)) {
                newNode = null;
                words = node.nodeValue.split(/[ \n]/);
                for (var i = 0; i < words.length; i++) {
                    if (words[i] === "") {
                        newNode = document.createTextNode(" ");
                        node.parentNode.insertBefore(newNode, node);
                    } else {
                        newNode = document.createElement("span");
                        newNode.id = "word" + idCntr++;
                        newNode.className = "arg_word_span";

                        if (words[i] == "&") {
                            newNode.innerHTML = "&amp;";
                        } else {
                            try {
                                newNode.innerHTML = words[i];
                            } catch (err) {

                            }
                        }
                        
                        node.parentNode.insertBefore(newNode, node);
                        if (i < words.length - 1) {
                            newNode = document.createTextNode(" ");
                            node.parentNode.insertBefore(newNode, node);
                        }
                    }
                }
                if (newNode) {
                    node.parentNode.removeChild(node);
                    node = newNode;
                    // don't go into the children of this node
                    skipChild = true;
                }
            }
        } else if (node.nodeType == 1) {
            if (node.tagName == "SCRIPT") {
                skipChild = true;
            }
        }        
        
        if (!skipChild && node.firstChild) {
            // if it has a child node, traverse down into children
            node = node.firstChild;
        } else if (node.nextSibling) {
            // if it has a sibling, go to the next sibling
            node = node.nextSibling;
        } else {
            // go up the parent chain until we find a parent that has a nextSibling
            // so we can keep going
            while ((node = node.parentNode) != top) {
                if (node.nextSibling) {
                    node = node.nextSibling;
                    break;
                }
            }
        }
    }
}
