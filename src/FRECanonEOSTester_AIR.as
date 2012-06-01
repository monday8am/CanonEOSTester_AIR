package
{
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.monday8am.photobooth.Camera;
	import com.monday8am.photobooth.CanonEOSLib;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.Timer;
	
	import net.hires.debug.Stats;
	
	
	public class FRECanonEOSTester_AIR extends Sprite
	{
		
		// camera 
		
		private var canon_lib : CanonEOSLib;
		private var camera 	  : Camera;
		
		// interface
		
		private var label				: Label;
		private var connect_btn 		: PushButton;
		private var shoot_btn 			: PushButton;
		private var close_session_btn 	: PushButton;
		private var open_session_btn 	: PushButton;
		private var startEFV_btn 		: PushButton;
		private var getEFV_btn 			: PushButton;
		private var stopEFV_btn 		: PushButton;	
		private var disconnect_btn  	: PushButton;
		private var label_events    	: TextArea;
		
		private var bmd					: BitmapData;
		private var bm					: Bitmap;
		private var image_container		: Sprite;
		private var counter				: int = 2;
		
		private var timer 				: Timer;
		private var time 				: int = 50;
		
		
		//[SWF( backgroundColor="#ffffff", frameRate="36", width="900", height="600")]
		[SWF(backgroundColor="#ffffff", frameRate="24", width="1920", height="1080")]
		public function FRECanonEOSTester_AIR()
		{
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;	
			stage.displayState = StageDisplayState.NORMAL;
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;			
			
			
			image_container = new Sprite();
			addChild( image_container );
			
			label 			= new Label		( this, 30, 30, "Connecting... " );
			connect_btn 	= new PushButton( this, 30, 60,  " CONNECT  ", onPressSaveBtn );
			shoot_btn 		= new PushButton( this, 30, 90,  " SHOOT!!  ", onPressSaveBtn );
			startEFV_btn 	= new PushButton( this, 30, 120,  " START EFV  ", onPressSaveBtn );
			//getEFV_btn 		= new PushButton( this, 30, 150,  " GET EFV  ", onPressSaveBtn );
			stopEFV_btn 	= new PushButton( this, 30, 150,  " STOP EFV   ", onPressSaveBtn );
			disconnect_btn  = new PushButton( this, 30, 180,  " DISCONNECT", onPressSaveBtn );
			label_events	= new TextArea( this, 150, 60, "logs... " ); label_events.width = 330; label_events.height = 390;
			
			
			var stats : Stats = new Stats();
			addChild( stats );
			stats.x = 30; stats.y = 220;
			
			// create lib
			//if( Capabilities.isDebugger )
			//{
			
			
			//}
			canon_lib = new CanonEOSLib();	
			
			if( canon_lib.extensionContextReady == false )
			{
				label.text = "Error loading library : " +  canon_lib;	
				
				connect_btn.enabled = false;
				shoot_btn.enabled = false;
				startEFV_btn.enabled = false;
				stopEFV_btn.enabled = false;
				disconnect_btn.enabled = false;
			}
			else
			{
				label.text = "Communicacion ready : " +  canon_lib.isSupported();
			}
			
			
			bmd = new BitmapData( 298, 390, false, 0xffffff );
			bm = new Bitmap( bmd );
			bm.pixelSnapping = PixelSnapping.NEVER;
			//bm.scaleX = bm.scaleY = 2;
			
			
			bm.x = 500; bm.y = 60; 
			image_container.addChild( bm );	
			
			timer = new Timer( time, 0);
			timer.addEventListener( TimerEvent.TIMER, onTimerEvent );
			stage.addEventListener( Event.CLOSE, onClose );
		}
		
		
		private function onPressSaveBtn( e : Event ) : void
		{
			
			if( e.currentTarget == connect_btn )
			{
				// get camera
				camera = canon_lib.getCamera();
				camera.addEventListener( StatusEvent.STATUS, onChangeStatus );
			}
			
			if( e.currentTarget == shoot_btn )
			{
				//canon_lib.executeCommand( "TakePicture" ); 	
				label_events.text += "Execute command TakePicture : " +  camera.takePicture( "c:\\\\test.jpg" ) + "\n";
			}
			
			if( e.currentTarget == disconnect_btn )
			{
				label_events.text += "Release camera : " + camera.release()  + "\n";
			}
			
			if( e.currentTarget == startEFV_btn )
			{
				label_events.text += "Start EVF : " + camera.startEVF() + "\n";
			}	
			
			if( e.currentTarget == stopEFV_btn )
			{
				label_events.text += "End EVF : " + camera.endEVF() + "\n";
			}	
		}
		
		private function onTimerEvent( event:Event):void
		{
			//label_events.text += "Get EVF : " + camera.getEVF( bmd) + "\n";
			camera.getEVF( bmd);
		}		
		
		
		
		private function onChangeStatus(event : StatusEvent ):void
		{
			if( event.code == "downloadEVF"  )
			{
				camera.getEVF( bmd);
			}
			else if(  event.code == "DeviceBusy" )
			{
				
			}
			else
			{
				label_events.text += "status: level " + event.level + ". code = " + event.code + "\n";
			}
		}
		
		private function onClose(event:Event):void
		{
			canon_lib.dispose();
		}	
		
	}
}