package lz.jprotoc 
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class Message 
	{
		public var messageEncode:Object;
		public var messageHasFlag:Array = [];
		public function readFrom(bytes:IDataInput, len:int = -1):void {
			MessageUtils.readFrom(this, bytes, len);
		}
		public function writeTo(bytes:IDataOutput):IDataOutput {
			return MessageUtils.writeTo(this, bytes);
		}
		protected function has(number:int):Boolean {
			return messageHasFlag[messageEncode[number]];
		}
		public function toString():String {
			return MessageUtils.msgToString(this);
		}
	}

}