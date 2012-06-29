package
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.monday8am.ane.Camera;
	import com.monday8am.ane.CanonEOSLib;
	import com.monday8am.ane.EDSDKTypes;
	import com.monday8am.ane.EDSDKValues;
	
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
		private var expo_combo			: ComboBox;	
		
		
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
			
			// create library
			
			canon_lib = new CanonEOSLib();
			
			
			// create interface
			
			image_container = new Sprite();
			addChild( image_container );
			image_container.x = 300;
			image_container.y = 60;
			
			
			label 			= new Label		( this, 30, 30, "Connecting... " );
			connect_btn 	= new PushButton( this, 30, 60,  "CONNECT", onPressSaveBtn );
			disconnect_btn  = new PushButton( this, 30, 85,  "DISCONNECT", onPressSaveBtn );
			take_pic_btn 	= new PushButton( this, 30, 125,  "TAKE PICTURE", onPressSaveBtn );
			press_h_btn		= new PushButton( this, 30, 150,  "PRESS HALFWAY", onPressSaveBtn );
			press_c_btn 	= new PushButton( this, 30, 175,  "PRESS COMPLETELY", onPressSaveBtn );
			press_o_btn 	= new PushButton( this, 30, 200,  "PRESS OFF", onPressSaveBtn );
			startEFV_btn 	= new PushButton( this, 30, 240,  " START EFV  ", onPressSaveBtn );
			stopEFV_btn 	= new PushButton( this, 30, 265,  " STOP EFV   ", onPressSaveBtn );

			label_events	= new TextArea( this, 30, 305, "logs... " ); label_events.width = 623; label_events.height = 150;
			
			var label1:Label= new Label	   ( this, 150, 60, "AV Values : " );
			av_combo 		= new ComboBox ( this, 150, 80, "",  EDSDKValues.Av ); av_combo.width = 130;
			var label2:Label= new Label	   ( this, 150, 100, "TV Values : " );
			tv_combo		= new ComboBox ( this, 150, 120, "", EDSDKValues.Tv ); tv_combo.width = 130;
			var label3:Label= new Label	   ( this, 150, 140, "Ae Modes : " );
			AeMode_combo 	= new ComboBox ( this, 150, 160, "", EDSDKValues.AeMode ); AeMode_combo.width = 130;
			var label4:Label= new Label	   ( this, 150, 180, "ISO Values : " );
			iso_combo 		= new ComboBox ( this, 150, 200, "", EDSDKValues.Iso ); iso_combo.width = 130;
			var label5:Label= new Label	   ( this, 150, 245, "Exposure Compensation : " );
			expo_combo 		= new ComboBox ( this, 150, 265, "", EDSDKValues.ExposureCompensation ); expo_combo.width = 130;	
	
			
			var stats : Stats = new Stats();
			//addChild( stats );
			//stats.x = 30; stats.y = 220;
						
			/**/
			if( canon_lib.extensionContextReady == false )
			{
				label.text = "Error loading library : " +  canon_lib;	
				
				connect_btn.enabled = false;
				take_pic_btn.enabled = false;
				startEFV_btn.enabled = false;
				stopEFV_btn.enabled = false;
				disconnect_btn.enabled = false;
				press_h_btn.enabled = false;
				press_c_btn.enabled = false;
				press_o_btn.enabled = false;
				
				log( "Error: " + canon_lib.lastError );
			}
			else
			{
				label.text = "Communicacion ready : " +  canon_lib.isSupported();
			}
			
			
			stage.addEventListener( Event.CLOSE, onClose );
		}
		
		
		private function onPressSaveBtn( e : Event ) : void
		{
			
			if( e.currentTarget == connect_btn )
			{
				// get camera
				
				log( "Try connect camera " );
				camera = canon_lib.getCamera();
				camera.addEventListener( StatusEvent.STATUS, onChangeStatus );
				log( "AEMode: " + camera.getAeMode() );
				log( "Av	: " + camera.getAv() );
				log( "Tv	: " + camera.getTv() );
				log( "Iso	: " + camera.getIso() );
				log( "Exposure: " + camera.getExposureComposition() );

				
			}
			
			if( e.currentTarget == disconnect_btn )
			{
				camera.removeEventListener( StatusEvent.STATUS, onChangeStatus );
				log( "Release camera : " + camera.release());
			}
			
			if( e.currentTarget == take_pic_btn )
			{	
				log( "take picture : " +  camera.takePicture( "c:\\\\test.jpg" ));
			}
			
			if( e.currentTarget == startEFV_btn )
			{
				log( "Start EVF : " + camera.startEVF());
			}	
			
			if( e.currentTarget == stopEFV_btn )
			{
				log( "End EVF : " + camera.endEVF());
			}	
			
			if( e.currentTarget == press_c_btn )
			{
				log( "Pressing Complete : " + camera.pressingCompletely() );
			}	
			
			if( e.currentTarget == press_h_btn )
			{
				log( "Pressing Halfway : " + camera.pressingHalfway() );
			}	
			
			if( e.currentTarget == press_o_btn )
			{
				log( "Pressing Off : " + "0x" + camera.pressingOff() );
				log( "AEMode: " + "0x" + camera.getAeMode().toString(16) );
				log( "Av	: " + "0x" + camera.getAv().toString(16) );
				log( "Tv	: " + "0x" +camera.getTv().toString(10) );
				log( "Iso	: " + "0x" + camera.getIso().toString(16) );
				log( "Exposure: " + "0x" + camera.getExposureComposition().toString(16) );
				
				setComboValue( av_combo, camera.getAv() );
				setComboValue( AeMode_combo, camera.getAeMode() );
				setComboValue( tv_combo, camera.getTv() );
				setComboValue( iso_combo, camera.getIso() );
				setComboValue( expo_combo, camera.getExposureComposition() );
				
				
			}			
			
		}
		
		
		//
		// Catch camera events
		//
		private function onChangeStatus(event : StatusEvent ):void
		{
			if( event.code == "downloadEVF"  )
			{
				if( bmd == null )
				{
					// get evf width and heigh
					// and create bitmapData
					
					bmd = new BitmapData( camera.getEvfWidth(), camera.getEvfHeight(), false, 0xff0000 );
					bm = new Bitmap( bmd );
					image_container.addChild( bm );	
					
				}
				else
				{
					camera.getEVF( bmd);
				}
			}
			else if(  event.code == "DeviceBusy" )
			{
				
			}
			else
			{
				log( "status: level " + event.level + ". code = " + event.code );
			}
		}
		
		
		private function onClose(event:Event):void
		{
			canon_lib.dispose();
		}	
		
		
		/**
		 * 
		 * Utils 
		 * 
		 */
		
		private function log( str : String ):void
		{
			label_events.text += str + "\n";
			label_events.textField.scrollV = label_events.textField.length;
		}
		

		private function setComboValue( combo : ComboBox, value : Object):void
		{
			var count : int = 0;
			
			while( count < combo.items.length )
			{
				if( combo.items[ count].data == value )
				{
					combo.selectedIndex = count;
					count = combo.items.length;
				}
				count++;
			}
		}
		
	}
}