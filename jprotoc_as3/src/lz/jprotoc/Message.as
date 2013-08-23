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
		public function readFrom(bytes:IDataInput, len:int = -1):void {
			MessageUtils.readFrom(this, bytes, len);
		}
		public function writeTo(bytes:IDataOutput):IDataOutput {
			return MessageUtils.writeTo(this, bytes);
		}
		public function has(name:String):Boolean {
			return messageEncode && messageEncode[name] && messageEncode[name][3];
		}
		public function toString():String {
			return MessageUtils.msgToString(this);
		}
	}

}