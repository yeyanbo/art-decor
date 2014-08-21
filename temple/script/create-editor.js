/*
*    Author: this file written by Marc de Graauw, largely copied from example by Marijn Haverbeke (codemirror.net)
*
*    This program is free software; you can redistribute it and/or modify it under the terms 
*    of the GNU General Public License as published by the Free Software Foundation; 
*    either version 3 of the License, or (at your option) any later version.
*    
*    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
*    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
*    See the GNU General Public License for more details.
*    
*    See http://www.gnu.org/licenses/gpl.html
*/
function completeAfter(cm, pred) {
    var cur = cm.getCursor();
    if (!pred || pred()) setTimeout(function () {
        if (!cm.state.completionActive)
            CodeMirror.showHint(cm, CodeMirror.hint.xml, { schemaInfo: tags, completeSingle: false });
    }, 100);
    return CodeMirror.Pass;
}

function completeIfAfterLt(cm) {
    return completeAfter(cm, function () {
        var cur = cm.getCursor();
        return cm.getRange(CodeMirror.Pos(cur.line, cur.ch - 1), cur) == "<";
    });
}

function completeIfInTag(cm) {
    return completeAfter(cm, function () {
        var tok = cm.getTokenAt(cm.getCursor());
        if (tok.type == "string" && (!/['"]/.test(tok.string.charAt(tok.string.length - 1)) || tok.string.length == 1)) return false;
        var inner = CodeMirror.innerMode(cm.getMode(), tok.state).state;
        return inner.tagName;
    });
}

function createEditor(id) {
    var editor = CodeMirror.fromTextArea(document.getElementById(id), {
        mode: "xml",
        lineNumbers: true,
        autoCloseTags: true,
        foldGutter: true,
        gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"],
        extraKeys: {
            "'<'": completeAfter,
            "'/'": completeIfAfterLt,
            "' '": completeIfInTag,
            "'='": completeIfInTag,
            "Ctrl-Space": function (cm) {
                CodeMirror.showHint(cm, CodeMirror.hint.xml, { schemaInfo: tags });
            }
        }
    });
    for (var i = 0, e = editor.lineCount(); i < e; ++i) editor.indentLine(i);
};