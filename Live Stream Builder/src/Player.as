// LIVE
// LIVE
// LIVE
// LIVE
package
{
	
	import flash.display.*;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.utils.setTimeout;
	import mx.controls.Image;
	import mx.controls.SWFLoader;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.controls.Alert;
	import mx.controls.sliderClasses.Slider;
	import mx.events.FlexEvent;
	import mx.events.SliderEvent;
	import mx.states.State;
	import mx.styles.CSSStyleDeclaration;
	import mx.utils.LoaderUtil;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.samples.MediaContainerUIComponent;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.*;
	import org.osmf.utils.Version;
	
	import spark.components.Application;
	import spark.components.Label;
	import spark.components.TextArea;
	
	public class Player extends Application
	{
		Security.LOCAL_TRUSTED;
		
		[Bindable]
		public var isConnected:Boolean = false;
		
		private var mediaElement:MediaElement;
		private var factory:DefaultMediaFactory = new DefaultMediaFactory();
		private var player:MediaPlayer = new MediaPlayer();
		private var isScrubbing:Boolean = false;
		private var fullscreenCapable:Boolean = false;
		private var hardwareScaleCapable:Boolean = false;
		private var saveVideoObjX:Number;
		private var saveVideoObjY:Number;
		private var saveVideoObjW:Number;
		private var saveVideoObjH:Number;
		private var saveStageW:Number;
		private var saveStageH:Number;
		private var adjVideoObjW:Number;
		private var adjVideoObjH:Number;
		private var streamName:String;
		private var netconnection:NetConnection;		
		private var PlayVersionMin:Boolean;
		private var streamNames:XML;
		private var streamsVector:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();			
		private var dynResource:DynamicStreamingResource = null;
		public var prompt:Text;
		public var warn:Text;
		public var connectStr:TextInput;
		public var videoBackground:Label;
		public var videoFrame:spark.components.TextArea;
		public var playerVersion:Text;
		public var videoContainer:MediaContainerUIComponent;
		public var connectButton:Button;
		public var doPlay:Button;
		public var seekBar:Slider;
		public var volumeLevel:Slider;
		public var doRewind:Button;
		public var doFullscreen:Button;
		public var backdrop:Canvas;
		public var loadIcon:SWFLoader;
		
		public var re:RegExp = /(\/)/;
		public var streamTitle:Array;
		
		
		public var app:Application;
		
		public function Player()
		{
			super();
			this.addEventListener(FlexEvent.APPLICATION_COMPLETE, init);
		}
		
		private function init(event:FlexEvent):void
		{	
			stage.align="TL";
			stage.scaleMode="noScale";
			
			doFullscreen.addEventListener(MouseEvent.CLICK,enterFullscreen);	
			connectButton.addEventListener(MouseEvent.CLICK,connect);
			volumeLevel.addEventListener(SliderEvent.CHANGE, volumeChange);
			
			//grab page title from URL
			re = /(\/)/;
			streamTitle = loaderInfo.loaderURL.split(re);
			re = /(\.)/;
			streamTitle = streamTitle[streamTitle.length-1].split(re);
			
			//CHANGE THIS TO CHANGE STREAM URL
			connectStr.text = "http://164.76.124.33:1935/live/" + streamTitle[0] + "/manifest.f4m";
			
			// *********************** stream examples ******************//
			// http://164.76.124.33:1935/live/test/manifest.f4m
			// http://localhost:1935/live/smil:liveStreamNames.smil/manifest.f4m (server-side smil)
			// rtmp://localhost:1935/live/myStream
			// rtmp://localhost:1935/live/streamNames.xml (Dynamic Streams)
				
			OSMFSettings.enableStageVideo = true;
			
			videoContainer.container = new MediaContainer();

			checkVersion();
		
			var osmfVersion:String = org.osmf.utils.Version.version;
				
			playerVersion.text = Capabilities.version + " (Flash-OSMF " + osmfVersion + ")";
			
			
			saveStageW = stage.width;
			saveStageH = stage.height;
			
			saveVideoObjX = videoContainer.x;
			saveVideoObjY = videoContainer.y;
			saveVideoObjW = videoContainer.width;
			saveVideoObjH = videoContainer.height;

			connect(null);
		}
				
		private function xmlIOErrorHandler(event:IOErrorEvent):void
		{
			trace("XML IO Error: " + event.target);
			prompt.text = "XML IO Error: " + event.text;	
		}
		
		private function stopAll():void
		{		
			if (player.playing)
				player.stop();
			
			isConnected = false;
			
			if (mediaElement != null)
				videoContainer.container.removeMediaElement(mediaElement);
			
			mediaElement = null;
			netconnection = null;
			connectButton.label = "Connect";
			dynResource = null;
			prompt.text = "";
		}
		
		private function clear():void
		{
			prompt.text = "";
			dynResource = null;
		}
		
		private function connect(event:MouseEvent):void // Play button (connectButton)
		{			
			if (connectButton.label == "Disconnect")
			{
				stopAll();
				videoBackground.visible = true;
				loadIcon.visible = true;
				return;
			}
			var ok:Boolean = checkVersion();
			if (!ok)
			{
				stopAll();
				return;
			}
			clear();
			if (connectStr.text.toLowerCase().indexOf("rtmp://")>-1 && connectStr.text.toLowerCase().indexOf(".xml")>-1)
				streamName = connectStr.text.substring(connectStr.text.lastIndexOf("/")+1, connectStr.text.length);
			
			if (streamName == null)
			{
				loadStream();
			}
			else if (streamName.toLowerCase().indexOf(".xml") > 0)
			{	
				loadVector(streamName); // load Dynamic stream items first if stream name is a xml file
			}
		}
		
		private function loadVector(streamName:String):void
		{
			var url:String = connectStr.text;
						
			var loader:URLLoader=new URLLoader();
			loader.addEventListener(Event.COMPLETE,xmlHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR,xmlIOErrorHandler)			
			
			var request:URLRequest=new URLRequest();
			var requestURL:String = streamName;
			request.url = requestURL;
			
			loader.load(request)
		}
		
		private function xmlHandler(event:Event):void
		{
			var loader:URLLoader=URLLoader(event.target);
			streamNames = new XML(loader.data);
			
			var videos:XMLList = streamNames..video;
			
			for (var i:int=0; i<videos.length(); i++)
			{
				var video:XML = videos[i];
				var bitrate:String = video.attribute("system-bitrate");
				var item:DynamicStreamingItem = new DynamicStreamingItem(video.@src,Number(bitrate), video.@width, video.@height);
				streamsVector.push(item);
			}
			if (videos.length()>0)
			{
				dynResource = new DynamicStreamingResource(connectStr.text);				
				dynResource.streamItems = streamsVector;
			}
			loadStream();
		}
		
		private function loadStream():void
		{	
			mediaElement = factory.createMediaElement(new URLResource(connectStr.text));
			
			if (dynResource != null)
				mediaElement.resource=dynResource;
			
			player.media = mediaElement;	
			videoContainer.container.addMediaElement(mediaElement);	
			
			mediaElement.addEventListener(MediaErrorEvent.MEDIA_ERROR,function(event:MediaErrorEvent):void
			{
				trace("event.error.message: " + event.error.message);
				stopAll();
				prompt.text = event.error.message + " " + event.error.detail;
				return;
			});
			
			player.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, function(event:MediaPlayerCapabilityChangeEvent):void
			{
				isConnected = event.enabled;
				
				if (isConnected)
				{
					stage.addEventListener(FullScreenEvent.FULL_SCREEN, enterLeaveFullscreen);
				}else
				{
					stage.removeEventListener(FullScreenEvent.FULL_SCREEN, enterLeaveFullscreen);
				}
			});
			
			player.autoPlay = true;
			connectButton.label  = "Disconnect";
			videoBackground.visible = false;
			loadIcon.visible = false;
		}
			
		private function volumeChange(event:SliderEvent):void
		{
			player.volume = event.value;
		}
			
		private function enterLeaveFullscreen(event:FullScreenEvent):void
		{
			trace("enterLeaveFullscreen: "+ event.fullScreen);
			if (!event.fullScreen)
			{		
				// reset back to original state
				stage.displayState = StageDisplayState.NORMAL; 
				videoFrame.visible=true;
				stage.scaleMode = "noScale";
				videoContainer.width = saveVideoObjW;
				videoContainer.height = saveVideoObjH;
				videoContainer.x = saveVideoObjX;
				videoContainer.y = saveVideoObjY;
				backdrop.visible=true;
				//prompt.text="hardware cap=" + hardwareScaleCapable + "  wmodeGPU=" + stage.wmodeGPU + "  support=" + OSMFSettings.supportsStageVideo;
			}
		}
		
		private function enterFullscreen(event:MouseEvent):void
		{
			trace("enterFullscreen: "+hardwareScaleCapable);
						
			videoFrame.visible=false;
			if (hardwareScaleCapable)
			{				
				// grab the portion of the stage that is just the video frame
				//backdrop.visible=false;
				
				stage.fullScreenSourceRect = new Rectangle(
					videoContainer.x, videoContainer.y, 
					videoContainer.width, videoContainer.height);
			}
			else
			{
				stage.scaleMode = "noBorder";
				
				var videoAspectRatio:Number = videoContainer.width/videoContainer.height;
				var stageAspectRatio:Number = saveStageW/saveStageH;
				var screenAspectRatio:Number = Capabilities.screenResolutionX/Capabilities.screenResolutionY;
				
				// calculate the width and height of the scaled stage
				var stageObjW:Number = saveStageW;
				var stageObjH:Number = saveStageH;
				if (stageAspectRatio > screenAspectRatio)
					stageObjW = saveStageH*screenAspectRatio;
				else
					stageObjH = saveStageW/screenAspectRatio;
				
				// calculate the width and height of the video frame scaled against the new stage size
				var fsvideoContainerW:Number = stageObjW;
				var fsvideoContainerH:Number = stageObjH;
				
				if (videoAspectRatio > screenAspectRatio)
					fsvideoContainerH = stageObjW/videoAspectRatio;			
				else
					fsvideoContainerW = stageObjH*videoAspectRatio;
				// scale the video object
				videoContainer.width = fsvideoContainerW;
				videoContainer.height = fsvideoContainerH;
				videoContainer.x = (stageObjW-fsvideoContainerW)/2.0;
				videoContainer.y = (stageObjH-fsvideoContainerH)/2.0;

			}
			stage.displayState = StageDisplayState.FULL_SCREEN;
		}
		private function rewind(event:MouseEvent):void
		{
			player.seek(0);
			seekBar.value = 0;
		}
		
		private function checkVersion():Boolean
		{
			PlayVersionMin = testVersion(10, 1, 0, 0);
			hardwareScaleCapable = testVersion(9, 0, 60, 0);
			hardwareScaleCapable = true;
			if (!PlayVersionMin && connectStr.text.indexOf(".f4m") > 0)
			{
				prompt.text = "Sanjose Streaming not support in this Flash version.";
				return false;
			}
			else
			{
				//prompt.text="hardware cap=" + hardwareScaleCapable + "  wmodeGPU=" + stage.wmodeGPU + "  support=" + OSMFSettings.supportsStageVideo;
				return true;
			}
		}
		
		private function testVersion(v0:Number, v1:Number, v2:Number, v3:Number):Boolean
		{
			var version:String = Capabilities.version;
			var index:Number = version.indexOf(" ");
			version = version.substr(index+1);
			var verParts:Array = version.split(",");
			
			var i:Number;
			
			var ret:Boolean = true;
			while(true)
			{
				if (Number(verParts[0]) < v0)
				{
					ret = false;
					break;
				}
				else if (Number(verParts[0]) > v0)
					break;
				
				if (Number(verParts[1]) < v1)
				{
					ret = false;
					break;
				}
				else if (Number(verParts[1]) > v1)
					break;
				
				if (Number(verParts[2]) < v2)
				{
					ret = false;
					break;
				}
				else if (Number(verParts[2]) > v2)
					break;
				
				if (Number(verParts[3]) < v3)
				{
					ret = false;
					break;
				}
				break;
			}
			trace("testVersion: "+Capabilities.version+">="+v0+","+v1+","+v2+","+v3+": "+ret);	
			return ret;
		}
	}
}