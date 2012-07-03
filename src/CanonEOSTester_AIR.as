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
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.StatusEvent;
	
	import net.hires.debug.Stats;
	
	[SWF( backgroundColor="#eeeeee", frameRate="36", width="680", height="530")]
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
		private var AFOn_btn	 		: PushButton;
		private var AFOff_btn 			: PushButton;			
		
		private var av_combo			: ComboBox;
		private var tv_combo			: ComboBox;
		private var AeMode_combo		: ComboBox;
		private var iso_combo			: ComboBox;		
		private var expo_combo			: ComboBox;	
		private var img_combo			: ComboBox;		
		private var met_combo			: ComboBox;			
		
		private var label_events    	: TextArea;
		
		private var bmd					: BitmapData;
		private var bm					: Bitmap;
		private var image_container		: Sprite;

		
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
			image_container.y = 85;
			
			
			label 			= new Label		( this, 30, 20,   "Connecting... " );
			connect_btn 	= new PushButton( this, 30, 60,   "Connect", onPressSaveBtn );
			disconnect_btn  = new PushButton( this, 30, 85,   "Disconnect", onPressSaveBtn );
			take_pic_btn 	= new PushButton( this, 30, 125,  "TAKE Picture", onPressSaveBtn );
			press_h_btn		= new PushButton( this, 30, 150,  "PRESS Halfway", onPressSaveBtn );
			press_c_btn 	= new PushButton( this, 30, 175,  "PRESS Completely", onPressSaveBtn );
			press_o_btn 	= new PushButton( this, 30, 200,  "PRESS Off", onPressSaveBtn );
			
			startEFV_btn 	= new PushButton( this, 300, 60,  "START Evf", onPressSaveBtn );
			stopEFV_btn 	= new PushButton( this, 410, 60,  "STOP Evf", onPressSaveBtn );
			AFOn_btn 		= new PushButton( this, 30,  275,  "Evf AF On", onPressSaveBtn );
			AFOff_btn 		= new PushButton( this, 30,  300,  "Evf AF Off", onPressSaveBtn );			

			label_events	= new TextArea( this, 30, 330, "logs... " ); label_events.width = 623; label_events.height = 170;
			
			var label1:Label= new Label	   ( this, 150, 40, "Av ( Camera aperture ) : " );
			av_combo 		= new ComboBox ( this, 150, 60, "",  EDSDKValues.Av ); av_combo.width = 130;
			var label2:Label= new Label	   ( this, 150, 80, "Tv ( Shutter speed ) : " );
			tv_combo		= new ComboBox ( this, 150, 100, "", EDSDKValues.Tv ); tv_combo.width = 130;
			var label3:Label= new Label	   ( this, 150, 120, "Ae ( Shooting mode ) : " );
			AeMode_combo 	= new ComboBox ( this, 150, 140, "", EDSDKValues.AeMode ); AeMode_combo.width = 130;
			var label4:Label= new Label	   ( this, 150, 160, "ISO ( Sensor sensitivity ) : " );
			iso_combo 		= new ComboBox ( this, 150, 180, "", EDSDKValues.Iso ); iso_combo.width = 130;
			var label5:Label= new Label	   ( this, 150, 200, "Exposure Compensation : " );
			expo_combo 		= new ComboBox ( this, 150, 220, "", EDSDKValues.ExposureCompensation ); expo_combo.width = 130;
			var label6:Label= new Label	   ( this, 150, 240, "Metering Mode : " );
			met_combo 		= new ComboBox ( this, 150, 260, "", EDSDKValues.MeteringMode ); met_combo.width = 130;
			var label7:Label= new Label	   ( this, 150, 280, "Image Quality : " );
			img_combo 		= new ComboBox ( this, 150, 300, "", EDSDKValues.ImageQuality ); img_combo.width = 130;
									
	

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
				//label.text = "Communicacion ready : " +  canon_lib.isSupported();
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
				log( "Pressing Off : " + camera.pressingOff() );
			}	
			
			if( e.currentTarget == AFOff_btn )
			{
				log( "Evf AF Off : " + camera.evfAFOff() );
			}			
			
			if( e.currentTarget == AFOn_btn )
			{
				log( "Evf AF On : " + camera.evfAFOn() );
			}			
						
			
		}
		
		/**
		 * 
		 * Event Handlers 
		 * 
		 */
		
		private function onChangeStatus(event : StatusEvent ):void
		{
			
			var propId : uint;
			
			
			if( event.level == Camera.EvfDataChanged  )
			{
				if( bmd == null )
				{
					// get evfWidth and evfHeigh properties
					// and create bitmapData
					
					bmd = new BitmapData( camera.getEvfWidth(), camera.getEvfHeight(), false, 0xffffff );
					bm = new Bitmap( bmd );
					image_container.addChild( bm );	
					
				}
				else
				{
					camera.getEVF( bmd);
				}
			}
			
			
			else if( event.level == Camera.DeviceBusy )
			{
				log( "Device busy" );
			}
			
			
			else if( event.level == Camera.PropertyChanged )
			{

				// get property value
				
				propId = uint( "0x" +  event.code );
				
				if( propId == EDSDKTypes.kEdsPropID_Av ) 		initPropertyCombo( av_combo , camera.getAv() );
				if( propId == EDSDKTypes.kEdsPropID_Tv ) 		initPropertyCombo( tv_combo , camera.getTv() );
				if( propId == EDSDKTypes.kEdsPropID_ISOSpeed )	initPropertyCombo( iso_combo, camera.getIso() );
				if( propId == EDSDKTypes.kEdsPropID_ExposureCompensation ) initPropertyCombo( expo_combo, camera.getExposureComposition() );
				if( propId == EDSDKTypes.kEdsPropID_AEMode ) 	initPropertyCombo( AeMode_combo, camera.getAeMode() );
				if( propId == EDSDKTypes.kEdsPropID_MeteringMode ) 	initPropertyCombo( met_combo, camera.getMeteringMode() );
				if( propId == EDSDKTypes.kEdsPropID_ImageQuality ) 	initPropertyCombo( img_combo, camera.getImageQuality() );

				log( "Device property changed : " + propId );
			}
			
			
			else if( event.level == Camera.PropertyDescChanged )
			{
				
				var propValues : Array = new Array();
				propId = uint( "0x" +  event.code );
				
				if( propId == EDSDKTypes.kEdsPropID_Av )
				{
					camera.getCameraPropertyDesc( EDSDKTypes.kEdsPropID_Av, propValues );
					setComboValues( av_combo, propValues );
				}
				
				if( propId == EDSDKTypes.kEdsPropID_Tv ) 
				{
					camera.getCameraPropertyDesc( EDSDKTypes.kEdsPropID_Tv, propValues );
					setComboValues( tv_combo, propValues );
				}
				
				if( propId == EDSDKTypes.kEdsPropID_ISOSpeed ) 
				{
					camera.getCameraPropertyDesc( EDSDKTypes.kEdsPropID_ISOSpeed, propValues );
					setComboValues( iso_combo, propValues );
				}
				
				if( propId == EDSDKTypes.kEdsPropID_ExposureCompensation ) 
				{
					camera.getCameraPropertyDesc( EDSDKTypes.kEdsPropID_ExposureCompensation, propValues );
					setComboValues( expo_combo, propValues );
				}
				
				if( propId == EDSDKTypes.kEdsPropID_AEMode )  
				{
					camera.getCameraPropertyDesc( EDSDKTypes.kEdsPropID_AEMode, propValues );
					setComboValues( AeMode_combo, propValues );
				}	
				
				if( propId == EDSDKTypes.kEdsPropID_ImageQuality )  
				{
					camera.getCameraPropertyDesc( EDSDKTypes.kEdsPropID_ImageQuality, propValues );
					setComboValues( img_combo, propValues );
				}		
				
				if( propId == EDSDKTypes.kEdsPropID_MeteringMode )  
				{
					camera.getCameraPropertyDesc( EDSDKTypes.kEdsPropID_MeteringMode, propValues );
					setComboValues( met_combo, propValues );
				}					
				
				log( "Property Desc changed : " + propId );
			}
			
			else
			{
				log( "status: level " + event.level + ". code = " + event.code );
			}
		}
		
		
		private function onUserChangeProperty( event : Event ):void
		{		
			
			if( event.currentTarget == iso_combo  )
			{
				log( "set ISO :" + camera.setIso( iso_combo.selectedItem.data ));
			}
			
			if( event.currentTarget == tv_combo  )
			{
				log( "set Tv :" + camera.setTv( uint( tv_combo.selectedItem.data )));
			}
			
			if( event.currentTarget == av_combo  )
			{
				log( "set Av :" + camera.setAv( uint( av_combo.selectedItem.data )));
			}
			
			if( event.currentTarget == AeMode_combo  )
			{
				log( "set AeMode :" + camera.setAeMode( uint( AeMode_combo.selectedItem.data )));
			}
			
			if( event.currentTarget == expo_combo  )
			{
				log( "set Exposure Compensation :" + camera.setExposureCompensation( uint( expo_combo.selectedItem.data )));
			}		
			
			if( event.currentTarget == met_combo  )
			{
				log( "set Metering Mode :" + camera.setMeteringMode( uint( met_combo.selectedItem.data )));
			}			
			
			if( event.currentTarget == img_combo  )
			{
				log( "set Image Quality :" + camera.setImageQuality( uint( img_combo.selectedItem.data )));
			}				
			
		}		
		
		
		private function onClose(event:Event):void
		{
			if( canon_lib != null ) canon_lib.dispose();
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
		

		private function initPropertyCombo( combo : ComboBox, value : Object):void
		{
			var count : int = 0;
			
			combo.removeEventListener( Event.SELECT, onUserChangeProperty );
			
			while( count < combo.items.length )
			{
				if( combo.items[ count].data == value )
				{
					combo.selectedIndex = count;
					count = combo.items.length;
				}
				count++;
			}
			
			combo.addEventListener( Event.SELECT, onUserChangeProperty );
		}
		
		
		private function setComboValues(  combo : ComboBox, newValues : Array ):void
		{
			var count : int = 0;
			
			if( newValues.length == 0 )
			{
				combo.enabled = false;
				return;
			}
			
			var selectedItem = combo.selectedItem;
			
			while( count < combo.items.length ) 
			{
				if( newValues.indexOf( combo.items[ count ].data ) == -1 )
				{
					combo.removeItemAt( count );
				}
				else
				{
					count++;
				}
			}
			
			combo.selectedItem = selectedItem;
			combo.enabled = true;
		}
		
	}
}