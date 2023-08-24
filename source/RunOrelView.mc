import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class RunOrelView extends WatchUi.WatchFace {
    var runOrelBlueLogo;
    var runOrelOrangeLogo;
    var screenHeight;
    var screenWidth;
    var accentColor;
    var isSleepMode;
    var orangeColor;
    var blueColor;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        runOrelBlueLogo = WatchUi.loadResource(Rez.Drawables.RunOrelBlueLogo);
        runOrelOrangeLogo = WatchUi.loadResource(Rez.Drawables.RunOrelOrangeLogo);
        screenHeight = dc.getHeight();
        screenWidth = dc.getWidth();
        isSleepMode = false;
        blueColor = WatchUi.loadResource(Rez.Strings.BlueColor).toNumberWithBase(16);
        orangeColor = WatchUi.loadResource(Rez.Strings.OrangeColor).toNumberWithBase(16);
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
        var accentColorNum = Application.Properties.getValue("AccentColor");
        var isDinamicCircle = Application.Properties.getValue("IsDinamicCircle");
        accentColor = accentColorNum == 1 ? blueColor : orangeColor; 
        var logoToDraw = accentColorNum == 1 ? runOrelBlueLogo : runOrelOrangeLogo; 
        
        View.onUpdate(dc);
        dc.setAntiAlias(true);
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_WHITE);
        dc.clear();

        dc.drawBitmap(0, 0, logoToDraw);
        if (isSleepMode || !isDinamicCircle) {
            drawSeconds(dc, 60);
        } else {
            drawSeconds(dc, currentTime.sec);
        }
        drawDate(dc, currentTime);
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
        var penWidth = screenWidth / 32;
        var cx = screenWidth / 2 - 1;
        var cy = screenHeight / 2 - 1;
        var radius = screenWidth / 2 - (penWidth / 2) + 1;

        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        if (seconds > 0) {
            dc.setPenWidth(penWidth);
            dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, START_ARC_DEGREE, endDegree);
        }
    }

    function drawDate(dc as Dc, currentTime) {
        var date = Lang.format("$1$ $2$ $3$", [currentTime.day_of_week, currentTime.day, currentTime.month]);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(screenWidth * 0.40, screenHeight * 0.80, Graphics.FONT_XTINY, date, Graphics.TEXT_JUSTIFY_LEFT);
    }
}
