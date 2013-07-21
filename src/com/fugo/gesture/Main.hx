package com.fugo.gesture;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.Lib;
import com.roxstudio.haxe.gesture.RoxGestureAgent;
import com.roxstudio.haxe.gesture.RoxGestureEvent;
import flash.text.TextField;
import motion.Actuate;
import motion.easing.Bounce;
import openfl.Assets;
/**
 * ...
 * @author Fugo
 */

class Main extends Sprite 
{
	var inited:Bool;

	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;

		// (your code here)
		
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
		
		//var test = new TestGesture();
		//addChild(test);
		var text:TextField = new TextField();
		var rotationText:TextField = new TextField();
		text.text = "[tap=scale up]  [Long press:scale down] [pinch: zoom] [swipe/pan:move]";
		text.x = 10;
		text.y = 10;
		text.width = 800;
		text.selectable = false;
		rotationText.text = "to rotate , place 2 fingers and move both in circle";
		rotationText.x = 10;
		rotationText.y = 40;
		rotationText.width = 800;
		rotationText.selectable = false;
		
		
		var image:Sprite = new Sprite();
		image.addChild(new Bitmap(Assets.getBitmapData("img/rock.png")));
		image.x = 300;
		image.y = 200;
		image.scaleX = 2;
		image.scaleY = 2;
		
		var roxAgent = new RoxGestureAgent(image, RoxGestureAgent.GESTURE);
		
		image.addEventListener(RoxGestureEvent.GESTURE_SWIPE, onSwipe);
		image.addEventListener(RoxGestureEvent.GESTURE_PAN, onPan);
		image.addEventListener(RoxGestureEvent.GESTURE_PINCH, onPinch);
		image.addEventListener(RoxGestureEvent.GESTURE_ROTATION, onRotation);
		image.addEventListener(RoxGestureEvent.GESTURE_TAP, onTap);
		image.addEventListener(RoxGestureEvent.GESTURE_LONG_PRESS, onLongPress);
		
		addChild(image);
		addChild(text);
		addChild(rotationText);
	}
	
	//when on tap , upsize the sprite
	private function onTap(e:RoxGestureEvent):Void
	{
		var sp:DisplayObject = cast(e.target, DisplayObject);
		var scX = sp.scaleX;	//current scaleX factor
		var scY = sp.scaleY;	//current scaleY factor 
		Actuate.tween(sp, 0.5, { scaleX: scX + 0.1, scaleY:scY + 0.1 } ).ease(Bounce.easeOut);
	}
	
	//when on long press, downsize the sprite
	private function onLongPress(e:RoxGestureEvent):Void
	{
		
		var sp:DisplayObject = cast(e.target, DisplayObject);
		var scX = sp.scaleX;	//current scaleX factor
		var scY = sp.scaleY;	//current scaleY factor 
		Actuate.tween(sp, 0.5, { scaleX: scX - 0.3, scaleY:scY - 0.3 } ).ease(Bounce.easeOut);
		
	}
	
	//on rotation, rotate the object
	private function onRotation(e:RoxGestureEvent):Void
	{
		var sp = cast(e.target, DisplayObject);
		var angle: Float = e.extra;
		var spt = sp.parent.localToGlobal(new Point(sp.x, sp.y));
		var dx = spt.x - e.stageX, dy = spt.y - e.stageY;
		var nowang = Math.atan2(dy, dx);
		var length = new Point(dx, dy).length;
		var newang = nowang + angle;
        var newpos = Point.polar(length, newang);
        newpos.offset(e.stageX, e.stageY);
        newpos = sp.parent.globalToLocal(newpos);
        sp.rotation +=  angle * 180 / Math.PI;
        sp.x = newpos.x;
        sp.y = newpos.y;
	}
	
	//on pinch,scale according to pinch movement
	private function onPinch(e:RoxGestureEvent):Void
	{
		var sp = cast(e.target, DisplayObject);
		var scale: Float = e.extra;
        var spt = sp.parent.localToGlobal(new Point(sp.x, sp.y));
        var dx = spt.x - e.stageX, dy = spt.y - e.stageY;
        var angle = Math.atan2(dy, dx);
        var nowlen = new Point(dx, dy).length;
        var newlen = nowlen * scale;
        var newpos = Point.polar(newlen, angle);
        newpos.offset(e.stageX, e.stageY);
        newpos = sp.parent.globalToLocal(newpos);
        sp.scaleX *= scale;
        sp.scaleY *= scale;
        sp.x = newpos.x;
        sp.y = newpos.y;
	}
	
	//on swipe, animate the movement between release point and end point
	private function onSwipe(e:RoxGestureEvent):Void
	{
		var sp= cast(e.target, DisplayObject);
		var pt = cast(e.extra, Point);
        Actuate.tween(sp,  0.5, { x:sp.x + pt.x, y:sp.y + pt.y });
	}
	
	//on pan, move object following the pan 
	private function onPan(e:RoxGestureEvent):Void
	{
		var sp = cast(e.target, DisplayObject);
		var pt = cast(e.extra,Point);
        sp.x += pt.x;
        sp.y += pt.y;
	}
	
	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}


