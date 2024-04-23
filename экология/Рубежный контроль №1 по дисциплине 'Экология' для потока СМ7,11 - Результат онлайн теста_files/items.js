function closeWindow() {
    window.close();
    top.close();
    var win = window.open("about:blank", "_self");
    win.close();
}
function copyPageUrl(btn) {
    copyToClipboard(document.location.href);
    $(btn).find('.icon-check').fadeIn("200");
    setTimeout(function () {
        $(btn).find('.icon-check').hide();
    }, 750);
}
function copyToClipboard(text) {
    if (window.clipboardData) { // Internet Explorer
        window.clipboardData.setData("Text", text);
    } else {
        navigator.clipboard.writeText(text);
    }
}
function setSpanDate(id) {
    var dt = new Date($(id).attr('utcdate'));
    var format = $(id).attr('formatdate');
    var str = getStringFromDateUtc(dt, format);
    $(id).html(str);
}
function getStringFromDateUtc(dt, format) {
    dt.setMinutes(dt.getMinutes() - new Date().getTimezoneOffset());
    return getStringDate(dt, format);
}
function getStringDate(dt, format) {
    var str = format;
    str = str.replace('dd', dt.getDate().toString().padLeft(2, '0'));
    str = str.replace('MM', (dt.getMonth() + 1).toString().padLeft(2, '0'));
    str = str.replace('yyyy', dt.getFullYear().toString());
    str = str.replace('HH', dt.getHours().toString().padLeft(2, '0'));
    str = str.replace('mm', dt.getMinutes().toString().padLeft(2, '0'));
    str = str.replace('ss', dt.getSeconds().toString().padLeft(2, '0'));
    return str;
}

function OnNavButtonClick(btn) {
    var clicked = $(btn).attr("clicked");
    if (clicked === "1") {
        return false;
    }
    $("#" + $(btn).attr("spinner")).css("display", "inline-block");
    $(btn).attr("clicked", "1");
    disableNavButtons();
    $(btn).prop('disabled', false);
    setTimeout(function() {
        $("#" + $(btn).attr("spinner")).css("display", "none");
        $(btn).attr("clicked", "0");
        enableNavButtons();
    }, 30000);
    return true;
}

function OnConfirmButtonClick(btn) {
    if ($(btn).attr("action") === "true")
        return true;

    var $confModal = $(document.createElement('div'));
    $confModal.addClass('modal modal-fade-in-scale-up item-pass-modal-conf');
    $confModal.html(
'<div class="modal-dialog modal-center modal-sm">' +
    '<div class="modal-content">' +
    '<div class="modal-body">' +
        '<p>' + $(btn).attr('conftext') + '</p>' +
    '</div>' +
        '<div class="modal-footer">' +
            '<button class="btn btn-sm btn-primary">' + $(btn).attr('yestext') + '</button>' +
            '<button class="btn btn-sm btn-link" data-dismiss="modal">' + $(btn).attr('notext') + '</button>' +
        '</div>' +
    '</div>' +
        '</div>');
    $confModal.modal('show');
    $confModal.find(".modal-footer .btn-primary").on("click", function () {
        $confModal.modal('hide');
        setTimeout(function () {
            $(btn).attr("action", "true").click();
            if ($(btn).attr("spinner") !== undefined)
                $("#" + $(btn).attr("spinner")).css("display", "inline-block");
            disableNavButtons();
            setTimeout(function() {
                if ($(btn).attr("spinner") !== undefined)
                    $("#" + $(btn).attr("spinner")).css("display", "none");
                $(btn).attr("action", "false");
                enableNavButtons();
            }, 30000);
        }, 200);
    });
    return false;
}

function disableNavButtons() {
    $('#btnNext, #btnFinish, #btnNextOnTimeLimit, #btnFinishOnTimeLimit').prop('disabled', true);
    $('.otp-t-view-question .popupqlst input').prop('disabled', true);
}
function enableNavButtons() {
    $('#btnNext, #btnFinish, #btnNextOnTimeLimit, #btnFinishOnTimeLimit').prop('disabled', false);
    $('.otp-t-view-question .popupqlst input').prop('disabled', false);
}
function focusInputField(containerClass) {
    var focusInputFieldCtrl = document.querySelector('.' + containerClass + ' input[type=text]');
    if (focusInputFieldCtrl == null)
        focusInputFieldCtrl = document.querySelector('.' + containerClass + ' textarea');
    if (focusInputFieldCtrl != null) {
        focusInputFieldCtrl.focus();
        var focusInputFieldCtrlVal = focusInputFieldCtrl.value;
        if (focusInputFieldCtrlVal && focusInputFieldCtrlVal.length) {
            focusInputFieldCtrl.selectionStart = focusInputFieldCtrlVal.length;
            focusInputFieldCtrl.selectionEnd = focusInputFieldCtrlVal.length;
        }
    }
}
function addEnterButtom() {
    var enterButton = document.createElement('input');
    enterButton.type = 'submit';
    enterButton.name = 'btnNexOnEnter';
    enterButton.style.display = 'none';
    var enterButtonBeforElement = document.getElementById('testform').children[0];
    enterButtonBeforElement.parentNode.insertBefore(enterButton, enterButtonBeforElement);
}

var sendWidgetHeight = function (uid) {
    var target = parent.postMessage ? parent : (parent.document.postMessage ? parent.document : undefined);
    var h = $("body").children("div").height();
    var data = { uid: uid, height: h };
    target.postMessage(data, "*");
    lastSentWidgetHeight = h;
};
var sendWidgetUids = function (uid, uids) {
    var target = parent.postMessage ? parent : (parent.document.postMessage ? parent.document : undefined);
    var data = { uid: uid, uids: uids };
    target.postMessage(data, "*");
};

var sendWidgetCloseWindow = function (uid) {
    var target = parent.postMessage ? parent : (parent.document.postMessage ? parent.document : undefined);
    var data = { uid: uid, closewindow: true };
    target.postMessage(data, "*");
};
var sendWidgetRedirect = function (uid, href) {
    var target = parent.postMessage ? parent : (parent.document.postMessage ? parent.document : undefined);
    var data = { uid: uid, redirect: true, redirhref: href };
    target.postMessage(data, "*");
};
var sendWidgetScroll = function (uid) {
    var target = parent.postMessage ? parent : (parent.document.postMessage ? parent.document : undefined);
    var data = { uid: uid, scroll: true };
    target.postMessage(data, "*");
};


var lastSentHeight = -1;
var lastSentHeightCnt = -1;
var sendHeight = function () {
    var target = parent.postMessage ? parent : (parent.document.postMessage ? parent.document : undefined);
    if (typeof target !== "undefined" && document.body.scrollHeight) {
        var h = $("body").children("div").height();
        if (h !== lastSentHeight || lastSentHeightCnt < 5) {
            target.postMessage(h, "*");
            if (lastSentHeight !== h)
                lastSentHeightCnt = 0;
            lastSentHeight = h;
            lastSentHeightCnt++;
        }
    }
};

function dropLastSentValues() {
    lastSentHeight = -1;
    lastSentHeightCnt = -1;
}

function TimerQuestionCountDown() {
    var secLeft;
    if (localbeginquestiontime == 0) {
        localbeginquestiontime = new Date().getTime();
    }

    var diff = new Date(new Date().getTime() - localbeginquestiontime);
    var secondsPassed = new Date(diff).getMinutes() * 60 + new Date(diff).getSeconds();
    secLeft = timelimitquestionseconds - secondsPassed;

    var minutes = Math.floor(secLeft / 60);
    var seconds = secLeft - minutes * 60;
    if (minutes < 10)
        minutes = '0' + minutes;
    if (seconds < 10)
        seconds = '0' + seconds;

    $("#dqtime").html(minutes + ":" + seconds);
    $("#localbeginquestiontime").val(localbeginquestiontime);

    if (secLeft > 0) {
        setTimeout('TimerQuestionCountDown()', 100);
    }
    else {
        $("#" + $('#btnNextOnTimeLimit').attr("spinner")).css("display", "inline-block")
        $('#btnNextOnTimeLimit').click();
        disableNavButtons();
    }
}

function TimerCountUp() {
    if (passTimeNotBegin) {
        setTimeOnSeconds(0);
        return;
    }

    var timerCountUpInervalCounter = 0;
    var timerCountUpFuction = function () {
        secPassed = Math.floor(totalSecondsPassed + 0.5 * timerCountUpInervalCounter);
        setTimeOnSeconds(secPassed);
        timerCountUpInervalCounter++;
    }
    timerCountUpFuction();
    setInterval(timerCountUpFuction, 500);
    setInterval(function () {
        $.ajax({
            method: 'get',
            url: '/common/passedseconds/' + $('#passbegintime').val()
        }).done(function (data) {
            totalSecondsPassed = parseFloat(data);
            timerCountUpInervalCounter = 0;
        })
    }, 10 * 1000);
}

function TimerCountDown() {
    if (passTimeNotBegin) {
        setTimeOnSeconds(timelimitseconds);
        return;
    }
    var timerCountDownInervalCounter = -1;
    var timerCountDownInerval;
    var timerCountDownCheckInerval;
    var timerCountDownFuction = function () {
        secLeft = Math.floor(timelimitseconds - totalSecondsPassed - 0.5 * timerCountDownInervalCounter);
        if (secLeft > 0) {
            setTimeOnSeconds(secLeft);
        } else {
            if ($('#btnFinishOnTimeLimit').attr("clicked") == "0") {
                $('#btnFinishOnTimeLimit').attr("clicked", "1");
                $('#btnFinishOnTimeLimit').click();
                disableNavButtons();
                clearInterval(timerCountDownInerval);
            }
        }
        timerCountDownInervalCounter++;
    }
    timerCountDownFuction();
    timerCountDownInerval = setInterval(timerCountDownFuction, 500);
    timerCountDownCheckInerval = setInterval(function () {
        var pbt = $('#passbegintime').val();
        if (!pbt || !pbt.length) {
            blockUiOnPassBeginTimeErr();
            clearInterval(timerCountDownCheckInerval);
            clearInterval(timerCountDownInerval);
        }
        $.ajax({
            method: 'get',
            url: '/common/passedseconds/' + pbt
        }).done(function (data) {
            if (data == "-1") {
                blockUiOnPassBeginTimeErr();
                clearInterval(timerCountDownCheckInerval);
                clearInterval(timerCountDownInerval);
            } else {
                totalSecondsPassed = parseFloat(data);
                timerCountDownInervalCounter = 0;
            }
        })
    }, 5 * 1000);
}

function blockUiOnPassBeginTimeErr() {
    $('.otp-item-view-page').find("div").empty();
    $('.otp-item-view-page').find("div").text('passbegintime not found');
}

function setTimeOnSeconds(secLeft) {
    var hours = Math.floor(secLeft / (60 * 60));
    var minutes = Math.floor((secLeft - 60 * 60 * hours) / 60);
    var seconds = secLeft - minutes * 60 - hours * 60 * 60;
    var timeStr = ('0' + minutes).slice(-2) + ":" + ('0' + seconds).slice(-2);
    if (hours > 0)
        timeStr = ('0' + hours).slice(-2) + ':' + timeStr;
    $("#dtime").html(timeStr);
}

function initCodeSnipnet(srcId, dstId) {
    var srcTxt = $('#' + srcId).val().replace(/_1_/gi, ' ').replace(/_2_/gi, '\n');
    var csMode = $('#' + srcId).attr('mode');
    CodeMirror.runMode(srcTxt, csMode, document.querySelector('#' + dstId));
}

function AddAlertSuccess(parent, label) {
    return AddAlertType(parent, label, "success", 2500);
}
function AddAlertSuccessNoClose(parent, label) {
    return AddAlertType(parent, label, "success", 0);
}
function AddAlertInfo(parent, label) {
    return AddAlertType(parent, label, "info", 2500);
}
function AddAlertWarning(parent, label) {
    return AddAlertType(parent, label, "warning", 2500);
}
function AddAlertDanger(parent, label) {
    return AddAlertType(parent, label, "danger", 2500);
}
function AddAlertType(parent, label, type, timeout) {
    var d = document.createElement("div");
    var id = "closealert" + Math.random().toString().replace("0.", "");
    $(d).html('<div class="alert alert-' + type + ' alert-dismissible"><button id="' + id + '" class="close" onclick="CloseElement(\'' + id + '\'); return false;" ><span>×</span></button>' + label + '</div>')
    $("#" + parent).append(d);
    if (timeout > 0)
        setTimeout("CloseElement('" + id + "')", timeout);
}
function CloseElement(el) {
    $("#" + el).parent().fadeOut("200", function () {
        $("#" + el).parent().remove();
    });
}

/* input only digit */
(function ($) {
    "use strict";
    $.fn.onlyNumber = function () {
        return this.each(function () {
            var curValue = $(this).val();
            $(this).on('input', function (e) {
                if ($(this).val() === '') {
                    curValue = $(this).val();
                    return;
                }
                var r = /^[-]{0,1}\d*[\.\,]{0,1}\d*$/g;
                var str = $(this).val().toString();
                if (r.test(str) === false) {
                    var ss = this.selectionStart;
                    $(this).val(curValue);
                    if (ss) {
                        this.selectionStart = ss - 1;
                        this.selectionEnd = ss - 1;
                    }
                    return;
                }
                curValue = $(this).val();
            });
        });
    };
})(window.jQuery);
/* auto width of input */
(function ($) {
    $.fn.autoWidth = function (method) {
        return this.each(function () {
            if (method == 'resize') {
                resize(this);
                return;
            }
            var divBuf = document.createElement('div');
            divBuf.className = 'input-auto-width-container';
            divBuf.style.minWidth = $(this).width() + 'px';
            this.parentNode.insertBefore(divBuf, this.nextSibling);

            if (this.value && this.value.length)
                resize(this);

            $(this).on('input', function (e) {
                resize(this);
            });

            function resize(el) {
                el.nextElementSibling.innerHTML = el.value;
                el.style.width = el.nextElementSibling.clientWidth + 'px';
            }
        });
    };
})(window.jQuery);

function showSolidGaugePercent(ctrlId, smallCoeff) {
    $.each($(ctrlId), function (i, ctrl) {
        var h = parseInt($(ctrl).attr("sgp-height")); if (isNaN(h)) h = 170;
        var w = parseInt($(ctrl).attr("sgp-width")); if (isNaN(w)) w = 260;
        var duration = parseInt($(ctrl).attr("sgp-duration")); if (isNaN(duration)) duration = 2000;

        if (!smallCoeff) smallCoeff = 1;

        h = parseInt(h * smallCoeff);
        w = parseInt(w * smallCoeff);
        var fontSize1 = parseInt(35 * smallCoeff);
        var fontSize2 = parseInt(28 * smallCoeff);

        var clr = $(ctrl).attr("sgp-color");
        $(ctrl).highcharts({
            chart: { type: 'solidgauge', backgroundColor: 'transparent', height: h, width: w },
            title: null,
            pane: {
                center: ['50%', '85%'], size: '160%',
                startAngle: -90, endAngle: 90,
                background: { backgroundColor: '#EEE', innerRadius: '60%', outerRadius: '100%', shape: 'arc' }
            },
            tooltip: { enabled: false },
            // the value axis
            yAxis: {
                stops: [
                    [0.0, clr], [1.0, clr]
                ],
                min: 0, max: 100, lineWidth: 0, minorTickInterval: null, tickPixelInterval: 400,
                tickWidth: 0, title: { y: -100 }, labels: { y: 16 }
            },

            plotOptions: {
                series: { animation: { duration: duration } },
                solidgauge: { dataLabels: { y: 5, borderWidth: 0, useHTML: true } }
            },
            credits: { enabled: false },
            series: [{
                name: 'Speed', data: [JSON.parse($(ctrl).attr("sgp-percent"))],
                dataLabels: { format: '<div style="text-align:center;font-family: Arial, Helvetica, sans-serif; "><span style="font-size:' + fontSize1 + 'px; color: #0275d8">{y}<span style="font-size:' + fontSize1 + 'px;">%</span></span></div>' },
            }],
            navigation: { buttonOptions: { enabled: false } }
        });
    });
}

var showResultReady = true;
function showQuestions(a) {
    if (!showResultReady)
        return;
    showResultReady = false;
    if (a !== undefined) {
        $(a).parent().parent().find('#dResults').fadeOut("200", function () {
            $(a).parent().parent().find('#dQuestions, #dItems').fadeIn("200", function () {
                showResultReady = true; sendHeight();
                autosize.update($('textarea.otp-textbox'));
                $('.fillinblank-input-digit, .fillinblank-input-text').autoWidth('resize');
                sendHeight();
            });
        });
    } else {
        $('#dResults').fadeOut("200", function () {
            $('#dQuestions, #dItems').fadeIn("200", function () {
                showResultReady = true; sendHeight();
                autosize.update($('textarea.otp-textbox'));
                $('.fillinblank-input-digit, .fillinblank-input-text').autoWidth('resize');
                sendHeight();
            });
        });
    }
}
function showResults(a) {
    if (!showResultReady)
        return;
    showResultReady = false;
    if (a !== undefined) {
        $(a).parent().parent().find('#dQuestions, #dItems').fadeOut("200", function () {
            $(a).parent().parent().find('#dResults').fadeIn("200", function () { showResultReady = true; sendHeight(); });
        });
    } else {
        $('#dQuestions, #dItems').fadeOut("200", function () {
            $('#dResults').fadeIn("200", function () { showResultReady = true; sendHeight(); });
        });
    }
}
function showItems() {
    if (!showResultReady)
        return;
    showResultReady = false;
    $('#dResults').fadeOut("200", function () {
        $('#dItems').fadeIn("200", function () { showResultReady = true; sendHeight(); });
    });
}

String.prototype.padLeft = function (n, pad) { var t = ''; if (n > this.length) { for (var i = 0; i < n - this.length; i++) { t += pad; } } return t + this; }
String.prototype.padRight = function (n, pad) { var t = this; if (n > this.length) { for (var i = 0; i < n - this.length; i++) { t += pad; } } return t; }

/*!	autosize 4.0.2	license: MIT	http://www.jacklmoore.com/autosize */
!function (e, t) { if ("function" == typeof define && define.amd) define(["module", "exports"], t); else if ("undefined" != typeof exports) t(module, exports); else { var n = { exports: {} }; t(n, n.exports), e.autosize = n.exports } }(this, function (e, t) { "use strict"; var n, o, p = "function" == typeof Map ? new Map : (n = [], o = [], { has: function (e) { return -1 < n.indexOf(e) }, get: function (e) { return o[n.indexOf(e)] }, set: function (e, t) { -1 === n.indexOf(e) && (n.push(e), o.push(t)) }, delete: function (e) { var t = n.indexOf(e); -1 < t && (n.splice(t, 1), o.splice(t, 1)) } }), c = function (e) { return new Event(e, { bubbles: !0 }) }; try { new Event("test") } catch (e) { c = function (e) { var t = document.createEvent("Event"); return t.initEvent(e, !0, !1), t } } function r(r) { if (r && r.nodeName && "TEXTAREA" === r.nodeName && !p.has(r)) { var e, n = null, o = null, i = null, d = function () { r.clientWidth !== o && a() }, l = function (t) { window.removeEventListener("resize", d, !1), r.removeEventListener("input", a, !1), r.removeEventListener("keyup", a, !1), r.removeEventListener("autosize:destroy", l, !1), r.removeEventListener("autosize:update", a, !1), Object.keys(t).forEach(function (e) { r.style[e] = t[e] }), p.delete(r) }.bind(r, { height: r.style.height, resize: r.style.resize, overflowY: r.style.overflowY, overflowX: r.style.overflowX, wordWrap: r.style.wordWrap }); r.addEventListener("autosize:destroy", l, !1), "onpropertychange" in r && "oninput" in r && r.addEventListener("keyup", a, !1), window.addEventListener("resize", d, !1), r.addEventListener("input", a, !1), r.addEventListener("autosize:update", a, !1), r.style.overflowX = "hidden", r.style.wordWrap = "break-word", p.set(r, { destroy: l, update: a }), "vertical" === (e = window.getComputedStyle(r, null)).resize ? r.style.resize = "none" : "both" === e.resize && (r.style.resize = "horizontal"), n = "content-box" === e.boxSizing ? -(parseFloat(e.paddingTop) + parseFloat(e.paddingBottom)) : parseFloat(e.borderTopWidth) + parseFloat(e.borderBottomWidth), isNaN(n) && (n = 0), a() } function s(e) { var t = r.style.width; r.style.width = "0px", r.offsetWidth, r.style.width = t, r.style.overflowY = e } function u() { if (0 !== r.scrollHeight) { var e = function (e) { for (var t = []; e && e.parentNode && e.parentNode instanceof Element;)e.parentNode.scrollTop && t.push({ node: e.parentNode, scrollTop: e.parentNode.scrollTop }), e = e.parentNode; return t }(r), t = document.documentElement && document.documentElement.scrollTop; r.style.height = "", r.style.height = r.scrollHeight + n + "px", o = r.clientWidth, e.forEach(function (e) { e.node.scrollTop = e.scrollTop }), t && (document.documentElement.scrollTop = t) } } function a() { u(); var e = Math.round(parseFloat(r.style.height)), t = window.getComputedStyle(r, null), n = "content-box" === t.boxSizing ? Math.round(parseFloat(t.height)) : r.offsetHeight; if (n < e ? "hidden" === t.overflowY && (s("scroll"), u(), n = "content-box" === t.boxSizing ? Math.round(parseFloat(window.getComputedStyle(r, null).height)) : r.offsetHeight) : "hidden" !== t.overflowY && (s("hidden"), u(), n = "content-box" === t.boxSizing ? Math.round(parseFloat(window.getComputedStyle(r, null).height)) : r.offsetHeight), i !== n) { i = n; var o = c("autosize:resized"); try { r.dispatchEvent(o) } catch (e) { } } } } function i(e) { var t = p.get(e); t && t.destroy() } function d(e) { var t = p.get(e); t && t.update() } var l = null; "undefined" == typeof window || "function" != typeof window.getComputedStyle ? ((l = function (e) { return e }).destroy = function (e) { return e }, l.update = function (e) { return e }) : ((l = function (e, t) { return e && Array.prototype.forEach.call(e.length ? e : [e], function (e) { return r(e) }), e }).destroy = function (e) { return e && Array.prototype.forEach.call(e.length ? e : [e], i), e }, l.update = function (e) { return e && Array.prototype.forEach.call(e.length ? e : [e], d), e }), t.default = l, e.exports = t.default });