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
		public static var messageEncode:Object={};
		public var messageHasFlag:Array = [];
		public function readFrom(bytes:IDataInput, len:int = -1):void {
			MessageUtils.readFrom(this, bytes, len);
		}
		public function writeTo(bytes:IDataOutput):IDataOutput {
			return MessageUtils.writeTo(this, bytes);
		}
		public function has(number:int):Boolean {
			return messageHasFlag[number];
		}
		public function setHas(number:int, value:Boolean = true):void {
			messageHasFlag[number] = value;
		}
		public function toString():String {
			return MessageUtils.msgToString(this);
		}
	}

}