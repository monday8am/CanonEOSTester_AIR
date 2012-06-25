package
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.monday8am.photobooth.Camera;
	import com.monday8am.photobooth.CanonEOSLib;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import net.hires.debug.Stats;
	
	
	public class CanonEOSTester_AIR extends Sprite
	{
		
		// camera 
		
		private var canon_lib : CanonEOSLib;
		private var camera 	  : Camera;
		
		// interface
		
		private var label				: Label;
		private var connect_btn 		: PushButton;
		private var disconnect_btn  	: PushButton;	
		private var take_pic_btn 		: PushButton;
		private var press_h_btn 		: PushButton;
		private var press_c_btn 		: PushButton;
		private var press_o_btn 		: PushButton;		
		private var startEFV_btn 		: PushButton;
		private var stopEFV_btn 		: PushButton;	
		private var av_combo			: ComboBox;
		private var tv_combo			: ComboBox;
		private var AeMode_combo		: ComboBox;
		private var iso_combo			: ComboBox;		
		
		
		private var label_events    	: TextArea;
		
		private var bmd					: BitmapData;
		private var bm					: Bitmap;
		private var image_container		: Sprite;
		private var counter				: int = 2;
		
		private var timer 				: Timer;
		private var time 				: int = 50;

		
		
		[SWF( backgroundColor="#ffffff", frameRate="36", width="900", height="600")]
		public function CanonEOSTester_AIR()
		{
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;	
			stage.displayState = StageDisplayState.NORMAL;
			
			// create interface
			
			image_container = new Sprite();
			addChild( image_container );
			
			label 			= new Label		( this, 30, 30, "Connecting... " );
			connect_btn 	= new PushButton( this, 30, 60,  "CONNECT", onPressSaveBtn );
			disconnect_btn  = new PushButton( this, 30, 85,  "DISCONNECT", onPressSaveBtn );
			
			take_pic_btn 	= new PushButton( this, 30, 125,  "TAKE PICTURE", onPressSaveBtn );
			press_h_btn		= new PushButton( this, 30, 150,  "PRESS HALFWAY", onPressSaveBtn );
			press_c_btn 	= new PushButton( this, 30, 175,  "PRESS COMPLETELY", onPressSaveBtn );
			press_o_btn 	= new PushButton( this, 30, 200,  "PRESS OFF", onPressSaveBtn );
			
			startEFV_btn 	= new PushButton( this, 30, 240,  " START EFV  ", onPressSaveBtn );
			stopEFV_btn 	= new PushButton( this, 30, 265,  " STOP EFV   ", onPressSaveBtn );
			
			
			
			av_combo 		= new ComboBox ( this, 150, 125 );
			tv_combo		= new ComboBox ( this, 150, 150 );
			AeMode_combo 	= new ComboBox ( this, 150, 175 );
			iso_combo 		= new ComboBox ( this, 150, 200 );
			
			label_events	= new TextArea( this, 30, 305, "logs... " ); label_events.width = 600; label_events.height = 150;
			
			
			var stats : Stats = new Stats();
			//addChild( stats );
			//stats.x = 30; stats.y = 220;
			
			
			canon_lib = new CanonEOSLib();	
			
			return;
			
			
			if( canon_lib.extensionContextReady == false )
			{
				label.text = "Error loading library : " +  canon_lib;	
				
				connect_btn.enabled = false;
				take_pic_btn.enabled = false;
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
			
			if( e.currentTarget == take_pic_btn )
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