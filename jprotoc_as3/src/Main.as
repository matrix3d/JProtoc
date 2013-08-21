package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import lz.jprotoc.Message;
	
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class Main extends Sprite 
	{
		private var loader:URLLoader;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			loader = new URLLoader;
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(new URLRequest("abc.bin"));
			loader.addEventListener(Event.COMPLETE, loader_complete);
		}
		
		private function loader_complete(e:Event):void 
		{
			var b:ByteArray = loader.data as ByteArray;
			b.endian = Endian.LITTLE_ENDIAN;
			//trace(b.length);
			var m:mtest1 = new mtest1;
			m.readFrom(b);
			trace(m.a);
		}
	}
}