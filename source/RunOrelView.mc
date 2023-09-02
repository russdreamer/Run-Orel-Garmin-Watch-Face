import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class RunOrelView extends WatchUi.WatchFace {
    var logoToDraw;
    var screenHeight;
    var screenWidth;
    var minSize;
    var accentColor;
    var isSleepMode;
    var orangeColor;
    var blueColor;
    var previousLogoNum;
    var timeFont;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        screenHeight = dc.getHeight();
        screenWidth = dc.getWidth();
        minSize = screenWidth < screenHeight ? screenWidth : screenHeight;
        isSleepMode = false;
        blueColor = WatchUi.loadResource(Rez.Strings.BlueColor).toNumberWithBase(16);
        orangeColor = WatchUi.loadResource(Rez.Strings.OrangeColor).toNumberWithBase(16);
        previousLogoNum = 1; 
        logoToDraw = WatchUi.loadResource(Rez.Drawables.RunOrelBlueLogo);
        timeFont = WatchUi.loadResource(Rez.Fonts.time_font);
        accentColor = blueColor;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var now = Time.now();
        var currentTime = Gregorian.info(now, Time.FORMAT_MEDIUM);
        var accentColorNum;
        var isDinamicCircle;
        var additionalDataField;
        if (Toybox has :Application && Application has :Properties) {
            accentColorNum = Application.Properties.getValue("AccentColor");
            isDinamicCircle = Application.Properties.getValue("IsDinamicCircle");
            additionalDataField = Application.Properties.getValue("AdditionalData");
        } else {
            accentColorNum = Application.getApp().getProperty("AccentColor");
            isDinamicCircle = Application.getApp().getProperty("IsDinamicCircle");
            additionalDataField = Application.getApp().getProperty("AdditionalData");
        }
        if (previousLogoNum != accentColorNum) {
            logoToDraw = null;
            logoToDraw = accentColorNum == 1 ? WatchUi.loadResource(Rez.Drawables.RunOrelBlueLogo) : WatchUi.loadResource(Rez.Drawables.RunOrelOrangeLogo);
            accentColor = accentColorNum == 1 ? blueColor : orangeColor; 
            previousLogoNum = accentColorNum;
        } 
        
        View.onUpdate(dc);
        if (Dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_WHITE);
        dc.clear();

        dc.drawBitmap(0, 0, logoToDraw);
        if (isSleepMode || !isDinamicCircle) {
            drawSeconds(dc, 60);
        } else {
            drawSeconds(dc, currentTime.sec);
        }

        drawTime(dc, getTime(currentTime));
        if (additionalDataField == 1) {
            drawDate(dc, currentTime);
        } else {
            drawSteps(dc, getSteps());
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        isSleepMode = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        isSleepMode = true;
    }

    function drawSeconds(dc, seconds as Number) {
        var START_ARC_DEGREE = 90;
        var MAX_DEGREES = 360;
        var MAX_SECONDS = 60;
        var endDegree = (((60 - seconds) * MAX_DEGREES) / MAX_SECONDS + START_ARC_DEGREE) % MAX_DEGREES;
        var penWidth = screenWidth / 30;
        var cx = screenWidth / 2 - 1;
        var cy = screenHeight / 2 - 1;
        var radius = minSize / 2 - (penWidth / 2) + 1;

        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        if (seconds > 0) {
            dc.setPenWidth(penWidth);
            dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, START_ARC_DEGREE, endDegree);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            if (seconds != 60) {
                var whitePenWidth = penWidth / 4;
                dc.setPenWidth(whitePenWidth);
                radius = minSize / 2 - penWidth + whitePenWidth / 2;
                dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, START_ARC_DEGREE, endDegree);
            }
        }
    }

    function drawDate(dc as Dc, currentTime) {
        var date = Lang.format("$1$ $2$ $3$", [currentTime.day_of_week, currentTime.day, currentTime.month]);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var diff = screenHeight - minSize; 
        var y = minSize * 0.8 + diff / 2;
        dc.drawText(screenWidth * 0.40, y, Graphics.FONT_XTINY, date, Graphics.TEXT_JUSTIFY_LEFT);
    }
    
    function drawSteps(dc as Dc, stepsNumber) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var diff = screenHeight - minSize; 
        var y = minSize * 0.8 + diff / 2;
        dc.drawText(screenWidth * 0.40, y, Graphics.FONT_XTINY, stepsNumber, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawTime(dc as Dc, time as String) {
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        var diff = screenHeight - minSize; 
        var y = minSize * 0.03 + diff / 2;
        dc.drawText(screenWidth * 0.5, y, timeFont, time, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function getSteps() {
        return Lang.format("$1$", [ActivityMonitor.getInfo().steps]);
    }

    function getTime(currentTime) {
        var hours = currentTime.hour;
        var format = "$1$:$2$";

        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        return Lang.format(format, [hours.format("%02d"), currentTime.min.format("%02d")]);
    }
}
