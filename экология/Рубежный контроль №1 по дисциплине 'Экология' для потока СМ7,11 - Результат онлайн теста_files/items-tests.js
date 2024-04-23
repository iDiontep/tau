function OnClickRadio(rb) {
    var p = $(rb).parent().parent().parent().parent();
    var lastvalue = $(p).attr("lastvalue");
    var curvalue = $(rb).attr("value");
    var arr = $.grep($("input[type=radio]"), function (e) { return $(e).attr("name") == $(rb).attr("name"); });
    $.each(arr, function (i, e) {
        e.checked = false;
        $(e).parent().children(".indicator").removeClass("icon-rb-checked").addClass('icon-rb');
        SetEnabledTextBoxRadioCheck(e, false);
    });
    if (lastvalue != curvalue) {
        rb.checked = true;
        $(rb).parent().children(".indicator").removeClass("icon-rb").addClass('icon-rb-checked');
        SetEnabledTextBoxRadioCheck(rb, true);
    }
    else {
        curvalue = "";
    }

    $(p).attr("lastvalue", curvalue);
}
function SetEnabledTextBoxRadioCheck(e, enabled) {
    if ($(e).parent().find("input[type=text]").length !== 0) {
        var txt = $(e).parent().find("input[type=text]")[0];
        if (enabled) {
            $(txt).removeAttr("disabled").focus();
        }
        else
            $(txt).attr("disabled", "disabled");
    }
}
function OnClickCheck(chk) {
    if (chk.checked) {
        var chkContainer = $(chk).parent().parent().parent();
        if (chkContainer.prop('nodeName').toString().toLocaleLowerCase() == 'td')
            chkContainer = $(chk).parent().parent().parent().parent();
        var chkContainerMaxCnt = parseInt($(chkContainer).attr('maxcnt')) || 0;
        var chkContainerCurCnt = chkContainer.find('input[type=checkbox]:checked').length;
        if (chkContainerCurCnt <= chkContainerMaxCnt || chkContainerMaxCnt === 0) {
            $(chk).parent().children(".indicator").switchClass('icon-chk', 'icon-chk-checked');
            SetEnabledTextBoxRadioCheck(chk, true);
        } else {
            chk.checked = false;
        }
    }
    else {
        $(chk).parent().children(".indicator").switchClass('icon-chk-checked', 'icon-chk');
        SetEnabledTextBoxRadioCheck(chk, false);
    }
}
function preventSelectChanges(ctrlId) {
    $.each($('#' + ctrlId).find('select'), function (i, sel) {
        $(sel).attr('curIndex', $(sel).val());
        $(sel).change(function (ev) {
            $(sel).val($(sel).attr('curIndex'));
        });
    })
}
function SetSequencing(id, callback) {
    $('#' + id).sortable({
        placeholer: "sequencing-ul-placeholder",
        stop: function (event, ui) { SortableChanged(event, ui, callback); }
    });
    $('#' + id).disableSelection();
    var arr = $('#' + id).children('li');
    var arrNew = [];
    for (i = 0; i < arr.length; i++) {
        $.each(arr, function (j, e) {
            var s = $(e).find('select')[0];
            if ($(s).val() == i + 1 || i == 0) {
                arrNew.push(e);
                arr.remove(e);
            }
        });
    }
    $('#' + id).empty();
    $.each(arrNew, function (i, e) { $('#' + id).append(e); });
}

function SortableChanged(event, ui, callback) {
    var ul = $(ui.item).parent();
    $.each($(ul).children("li"), function (i, e) {
        var sel = $(e).find("select");
        $.each($(sel).children("option"), function (j, o) {
            $(o).removeAttr('selected');
            if ($(o).attr("value") == (i + 1))
                $(sel).val(i + 1);
        });
    });
    if (callback)
        callback();
}
function SortableSelectIndexChanged(sel) {
    if ($(sel).val() == 0)
        return;
    var li = $(sel).parent().parent().parent().parent().parent();
    var ul = $(li).parent();
    $(li).remove();
    var selectedIndex = parseInt($(sel).val());
    if (selectedIndex == 1)
        $($(ul).children("li")[0]).before(li);
    else if (selectedIndex == $(ul).children("li").length + 1)
        $(ul).append(li);
    else
        $($(ul).children("li")[selectedIndex - 1]).before(li);
    SortableChanged(null, { item: $(sel).parent().parent().parent().parent().parent() });
}
function ShowTextboxOnMinusOneItemValue(ddl) {
    if ($(ddl).val() == "-1")
        $(ddl).parent().children("input[type=text]").fadeIn("200");
    else
        $(ddl).parent().children("input[type=text]").fadeOut("200");
}

function OnInputDigitTextChanged(txt) {
    var str = $(txt).val();
    $(txt).css("border-color", "");
    if (str == "")
        return;
    if (str.endsWith(".") || str.endsWith(",")) {
        str = str.substr(0, str.length - 1);
        $(txt).val(str);
    }
    if (!str.match(/^-?[0-9]+([.,]{0,1}[0-9]*){0,1}$/)) {
        $(txt).css("border-color", "red");
    }
}
function OnInteractiveDictationItemClick(el) {
    CloseInteractiveDictationItems();
    $(document).off("click");
    var p = $(el).parent().position();
    var d = $(el).parent().children("span.container");
    $(d).css("left", (p.left + $(el).parent().width() / 2 - $(d).width() / 2 - 2) + "px");
    $(d).css("top", (p.top + $(el).parent().height()) + "px");
    $(el).parent().children("span.container").fadeIn(200, function () {
        $(document).one("click",
            function() {
                CloseInteractiveDictationItems();
            });
        if ($(this).attr("dsbld") == "1") {
            $("#" + $(d).attr("id") + " input[type=radio]").on("click",
                function() {
                    return false;
                });
        }
        else {
            $(d).find("label").off("click").on("click",
                function() {
                    $(d).parent().children(".lbl").html($(this).html());
                    $(d).parent().css("background-color", "transparent");
                    $(d).parent().css("border", "");
                });
        }
    });
}
function CloseInteractiveDictationItems() {
    $(".otp-inter-dict span.container").hide();
}

function OnConsistentExceptionItemClick(d) {
    var num = parseInt($(d).parent().attr("lastnum")) + 1;
    $("#h" + $(d).attr("id")).val(num);
    $(d).css("display", "none");
    $(d).parent().attr("lastnum", num);
}

function OnSurveyPollVote(a) {
    setTimeout(function () {
        $('#btnFinish').click();
    }, 50);
}

function SetWordsSequence(ul) {
    var text = "";
    $.each($(ul).find('li'), function (i, e) {
        if ($(e).html() == "") {
            text = text + " ";
        }
        else {
            text = text + $(e).html();
        }
    })
    $("#hWordValue").val(text);
}

function SetPhrasesSequence(callback) {
    ShiftPositionsOnePhrase();
    $.each($('#d-q-ans-container #dBoxes div'), function (i, d) {
        $(d).draggable();
    });
    $.each($('#d-q-ans-container #dPlaces div'), function (i, d) {
        $(d).droppable({
            activate: function (event, ui) { ui.draggable.attr("posnum", ""); },
            accept: function (boxElem) {
                return IsNeedAcceptOnePhrase(boxElem, $(this));
            },
            drop: function (event, ui) {
                $(this).removeClass("highlight");
                ui.draggable.attr("posnum", $(this).attr("posnum"));
                ShiftPositionsOnePhrase(); ShiftPositionsOnePhrase();
                if (callback) callback();
            },
            over: function (event, ui) {
                $(this).addClass("highlight");
            },
            out: function (event, ui) {
                $(this).css("width", "").css("width", "").removeClass("highlight");
                ui.draggable.attr("posnum", "");
                ShiftPositionsOnePhrase(); ShiftPositionsOnePhrase();
                if (callback) callback();
            }
        });
    });
}
function ShiftPositionsOnePhrase() {
    var m = document.querySelector('#d-q-ans-container #dPlaces').getElementsByTagName("div");
    var boxes = document.querySelector('#d-q-ans-container #dBoxes').getElementsByTagName("div");
    var sequence = "";
    for (var i = 0; i < m.length; i++) {
        var b = null;
        for (var j = 0; j < boxes.length; j++) {
            if ($(boxes[j]).attr("posnum") != "" && $(boxes[j]).attr("posnum") == $(m[i]).attr("posnum")) {
                b = $(boxes[j]);
                break;
            }
        }
        if (b == null) {
            sequence = sequence + ";";
            continue;
        }
        SetPositionOnePhrase($(m[i]), b);
        sequence = sequence + $(b).attr("phid") + ";";
    }
    $("#hSequence").val(sequence);
}
function SetPositionOnePhrase(placeElem, boxElem) {
    var pos = $(boxElem).css("left").replace("px", "");
    if (isNaN(parseInt(pos)))
        pos = 0;
    var delta = $(placeElem).position().left - boxElem.position().left;
    var left = (parseInt(pos) + parseInt(delta)) + "px";
    $(boxElem).css("left", left);

    pos = $(boxElem).css("top").replace("px", "");
    if (isNaN(parseInt(pos)))
        pos = 0;
    delta = $(placeElem).position().top - boxElem.position().top;
    var top = (parseInt(pos) + parseInt(delta)) + "px";
    $(boxElem).css("top", top);

    placeElem.css("width", boxElem.css("width"));
}
function IsNeedAcceptOnePhrase(boxElem, posElem) {
    var hasBoxWithPosElemNumber = false;
    var boxes = document.getElementById("dBoxes").getElementsByTagName("div");
    for (var j = 0; j < boxes.length; j++) {
        if ($(boxes[j]).attr("posnum") == $(posElem).attr("posnum") && $(boxElem).attr("posnum") != $(posElem).attr("posnum")) {
            hasBoxWithPosElemNumber = true;
        }
    }
    return !hasBoxWithPosElemNumber;
}
function setupSearchInText(id, callback) {
    $('#sitxt_' + id).find('span.s').on('click', function () {
        if ($(this).attr('sel') == '1') {
            $(this).attr('sel', '0');
            $(this).removeClass('sel');
        }
        else {
            $(this).attr('sel', '1');
            $(this).addClass('sel');
        }
        var arr = [];
        $.each($('#sitxt_' + id).find('span.s[sel=1]'), function (i, e) {
            arr.push($(e).attr("num"));
        })
        $("#hSearchInTextVal_" + id).val(arr.join(','));
        if (callback)
            callback();
    })
}

/* matching module */
(function ($) {
    "use strict";
    $.fn.matching = function (isSavedTest, callback) {

        return this.each(function () {
            var $this = $(this);
            $this.find(".drag-list ul>li").draggable({
                start: function (e, ui) {
                    if (isSavedTest)
                        return;
                    var n = parseInt($(ui.helper).find('div.num').text());
                    var dropElem = findDropElement(n);
                    if (dropElem) {
                        $(ui.helper).removeClass('connected');
                        $(ui.helper).find('div.main').css('height', 'auto');

                        $(dropElem).find('select option').eq(0).prop("selected", true);
                        $(dropElem).removeClass('connected');
                        $(dropElem).find('div.main').css('height', 'auto');

                        adjustHeights(false);
                        adjustHeights(false);

                        if (callback)
                            callback();
                    }
                }
            });
            if (isSavedTest) {
                $this.find(".drag-list ul>li").draggable({ revert: true });
            }
            else {
                $this.find(".drop-list ul>li").droppable({
                    tolerance: "touch",
                    accept: function (ui) {
                        return $(this).find('select option:selected').index() <= 0;
                    },
                    over: function (e, ui) {
                        $(this).addClass("highlight");
                    },
                    out: function (e, ui) {
                        $(this).removeClass("highlight");
                    },
                    drop: function (event, ui) {
                        var n = parseInt($(ui.draggable).find('div.num').text());
                        var dropElem = findDropElement(n);
                        if (dropElem)
                            return;
                        $(this).find('select option').eq(n).prop("selected", true);
                        $(this).removeClass("highlight");

                        $(this).addClass('connected');
                        $(ui.draggable).addClass('connected');

                        adjustHeights(true);
                        adjustHeights(true);
                        if (callback)
                            callback();
                    }
                });

                $this.find(".drop-list select").on('change', function () { adjustHeights(true); })
            }

            function adjustHeights(shiftNotSelectedPositions) {
                if ($(window).width() < 400) {
                    return;
                }
                $.each($this.find(".drop-list ul>li"),
                    function (i, li) {
                        if ($(li).find('select').val() == null || $(li).find('select').val() == '0') {
                            $(li).find('div.main').css('height', 'auto');
                        } else {
                            var dragElem = findDragElement($(li).find('select option:selected').index());

                            $(li).addClass('connected');
                            $(dragElem).addClass('connected');

                            var h = Math.max($(li).find('div.main').height(), $(dragElem).find('div.main').height());
                            $(li).find('div.main').height(h);
                            $(dragElem).find('div.main').height(h);

                            var topDiff = $(li).position().top - $(dragElem).position().top;
                            var top = parseInt($(dragElem).css('top').replace('px', ''));
                            $(dragElem).css('top', (top + topDiff) + 'px');

                            var leftDiff = $(li).position().left + $(li).width() - $(dragElem).position().left - 1;
                            var left = parseInt($(dragElem).css('left').replace('px', ''));
                            $(dragElem).css('left', (left + leftDiff) + 'px');
                        }
                    });
                if (shiftNotSelectedPositions) {
                    var dropEmpty = [];
                    $.each($this.find('.drop-list ul>li'),
                        function (i, li) {
                            if ($(li).find('select option:selected').index() === 0 ||
                                $(li).find('select option:selected').index() === -1) {
                                dropEmpty.push(li);
                            }
                        });
                    var index = 0;
                    $.each($this.find(".drag-list ul>li"),
                        function (i, li) {
                            if ($(li).hasClass('connected') === false) {
                                if (dropEmpty[index]) {
                                    var topDiff = $(dropEmpty[index]).position().top - $(li).position().top;
                                    var top = parseInt($(li).css('top').replace('px', ''));
                                    $(li).css('top', (top + topDiff) + 'px');

                                    $(li).css('left', '0px');
                                }
                                index++;
                            }
                        });
                }

            }

            function findDragElement(number) {
                var el = undefined;
                $.each($this.find('.drag-list ul>li'),
                    function (i, li) {
                        console.log(parseInt($(li).find('div.num').text()));
                        if (parseInt($(li).find('div.num').text()) === number) {
                            el = li;
                        }
                    });
                return el;
            }
            function findDropElement(number) {
                var el = undefined;
                $.each($this.find('.drop-list ul>li'),
                    function (i, li) {
                        if ($(li).find('select option:selected').index() === number) {
                            el = li;
                        }
                    });
                return el;
            }

            if (!isSavedTest) {
                adjustHeights(true);
                adjustHeights(true);
            }
        });
    };
})(window.jQuery);

/* rating vote module */
(function ($) {
    "use strict";
    $.fn.textareaCounting = function () {
        return this.each(function () {
            var $this = $(this)
            var $maxLength = $this.attr('maxlength');
            var $parent = $this.parent();
            var countWords = $(this).attr('countwords').toLowerCase() == 'true';
            var countWordsText = $(this).attr('countwordstext');
            var div = document.createElement('div');
            $(div).addClass('textarea-counting');
            $parent.append(div);
            setCount();
            $this.on('input', function () {
                setCount();
            });

            function setCount() {
                var txt = $this.val().length + ' / ' + $maxLength;

                if (countWords) {
                    txt += '<span>|</span>';
                    var cnt = $this.val().replace(/\n/gi, " ").replace(/(^\s*)|(\s*$)/gi, "").replace(/[ ]{2,}/gi, " ").split(' ').filter(function (str) { return str != "" && str != "-"; }).length;
                    txt += '<span>' + countWordsText + ': ' + cnt + '</span>';
                }

                $(div).html(txt);
            }
        });
    };
})(window.jQuery);

/*
    jQuery Masked Input Plugin
    Copyright (c) 2007 - 2015 Josh Bush (digitalbush.com)
    Licensed under the MIT license (http://digitalbush.com/projects/masked-input-plugin/#license)
    Version: 1.4.1
*/
!function (a) { "function" == typeof define && define.amd ? define(["jquery"], a) : a("object" == typeof exports ? require("jquery") : jQuery) }(function (a) { var b, c = navigator.userAgent, d = /iphone/i.test(c), e = /chrome/i.test(c), f = /android/i.test(c); a.mask = { definitions: { 9: "[0-9]", a: "[A-Za-z]", "*": "[A-Za-z0-9]" }, autoclear: !0, dataName: "rawMaskFn", placeholder: "_" }, a.fn.extend({ caret: function (a, b) { var c; if (0 !== this.length && !this.is(":hidden")) return "number" == typeof a ? (b = "number" == typeof b ? b : a, this.each(function () { this.setSelectionRange ? this.setSelectionRange(a, b) : this.createTextRange && (c = this.createTextRange(), c.collapse(!0), c.moveEnd("character", b), c.moveStart("character", a), c.select()) })) : (this[0].setSelectionRange ? (a = this[0].selectionStart, b = this[0].selectionEnd) : document.selection && document.selection.createRange && (c = document.selection.createRange(), a = 0 - c.duplicate().moveStart("character", -1e5), b = a + c.text.length), { begin: a, end: b }) }, unmask: function () { return this.trigger("unmask") }, mask: function (c, g) { var h, i, j, k, l, m, n, o; if (!c && this.length > 0) { h = a(this[0]); var p = h.data(a.mask.dataName); return p ? p() : void 0 } return g = a.extend({ autoclear: a.mask.autoclear, placeholder: a.mask.placeholder, completed: null }, g), i = a.mask.definitions, j = [], k = n = c.length, l = null, a.each(c.split(""), function (a, b) { "?" == b ? (n-- , k = a) : i[b] ? (j.push(new RegExp(i[b])), null === l && (l = j.length - 1), k > a && (m = j.length - 1)) : j.push(null) }), this.trigger("unmask").each(function () { function h() { if (g.completed) { for (var a = l; m >= a; a++) if (j[a] && C[a] === p(a)) return; g.completed.call(B) } } function p(a) { return g.placeholder.charAt(a < g.placeholder.length ? a : 0) } function q(a) { for (; ++a < n && !j[a];); return a } function r(a) { for (; --a >= 0 && !j[a];); return a } function s(a, b) { var c, d; if (!(0 > a)) { for (c = a, d = q(b); n > c; c++) if (j[c]) { if (!(n > d && j[c].test(C[d]))) break; C[c] = C[d], C[d] = p(d), d = q(d) } z(), B.caret(Math.max(l, a)) } } function t(a) { var b, c, d, e; for (b = a, c = p(a); n > b; b++) if (j[b]) { if (d = q(b), e = C[b], C[b] = c, !(n > d && j[d].test(e))) break; c = e } } function u() { var a = B.val(), b = B.caret(); if (o && o.length && o.length > a.length) { for (A(!0); b.begin > 0 && !j[b.begin - 1];) b.begin--; if (0 === b.begin) for (; b.begin < l && !j[b.begin];) b.begin++; B.caret(b.begin, b.begin) } else { for (A(!0); b.begin < n && !j[b.begin];) b.begin++; B.caret(b.begin, b.begin) } h() } function v() { A(), B.val() != E && B.change() } function w(a) { if (!B.prop("readonly")) { var b, c, e, f = a.which || a.keyCode; o = B.val(), 8 === f || 46 === f || d && 127 === f ? (b = B.caret(), c = b.begin, e = b.end, e - c === 0 && (c = 46 !== f ? r(c) : e = q(c - 1), e = 46 === f ? q(e) : e), y(c, e), s(c, e - 1), a.preventDefault()) : 13 === f ? v.call(this, a) : 27 === f && (B.val(E), B.caret(0, A()), a.preventDefault()) } } function x(b) { if (!B.prop("readonly")) { var c, d, e, g = b.which || b.keyCode, i = B.caret(); if (!(b.ctrlKey || b.altKey || b.metaKey || 32 > g) && g && 13 !== g) { if (i.end - i.begin !== 0 && (y(i.begin, i.end), s(i.begin, i.end - 1)), c = q(i.begin - 1), n > c && (d = String.fromCharCode(g), j[c].test(d))) { if (t(c), C[c] = d, z(), e = q(c), f) { var k = function () { a.proxy(a.fn.caret, B, e)() }; setTimeout(k, 0) } else B.caret(e); i.begin <= m && h() } b.preventDefault() } } } function y(a, b) { var c; for (c = a; b > c && n > c; c++) j[c] && (C[c] = p(c)) } function z() { B.val(C.join("")) } function A(a) { var b, c, d, e = B.val(), f = -1; for (b = 0, d = 0; n > b; b++) if (j[b]) { for (C[b] = p(b); d++ < e.length;) if (c = e.charAt(d - 1), j[b].test(c)) { C[b] = c, f = b; break } if (d > e.length) { y(b + 1, n); break } } else C[b] === e.charAt(d) && d++ , k > b && (f = b); return a ? z() : k > f + 1 ? g.autoclear || C.join("") === D ? (B.val() && B.val(""), y(0, n)) : z() : (z(), B.val(B.val().substring(0, f + 1))), k ? b : l } var B = a(this), C = a.map(c.split(""), function (a, b) { return "?" != a ? i[a] ? p(b) : a : void 0 }), D = C.join(""), E = B.val(); B.data(a.mask.dataName, function () { return a.map(C, function (a, b) { return j[b] && a != p(b) ? a : null }).join("") }), B.one("unmask", function () { B.off(".mask").removeData(a.mask.dataName) }).on("focus.mask", function () { if (!B.prop("readonly")) { clearTimeout(b); var a; E = B.val(), a = A(), b = setTimeout(function () { B.get(0) === document.activeElement && (z(), a == c.replace("?", "").length ? B.caret(0, a) : B.caret(a)) }, 10) } }).on("blur.mask", v).on("keydown.mask", w).on("keypress.mask", x).on("input.mask paste.mask", function () { B.prop("readonly") || setTimeout(function () { var a = A(!0); B.caret(a), h() }, 0) }), e && f && B.off("input.mask").on("input.mask", u), A() }) } }) });

$.mask.definitions['9'] = '[0-9]';
$.mask.definitions['А'] = '[A-Za-zА-Яа-я]';
$.mask.definitions['A'] = '[A-Za-zА-Яа-я]';