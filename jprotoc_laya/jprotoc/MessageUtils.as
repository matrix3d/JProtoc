package jprotoc 
{
	import laya.utils.Byte;
	/**
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class MessageUtils 
	{
		public static var CHAR_SET:String = "utf-8";
		
		public static function readFrom(msg:Message, bytes:Byte, len:int = -1):void {
			var affterLen:int = 0;
			if (len > 0) affterLen = bytes.bytesAvailable-len;
			while (bytes.bytesAvailable>affterLen) {
				var tag:uint = readVarint(bytes);
				if (tag == 0) continue;
				var number:int = tag >>> 3;
				var body:Object = msg.mMessageEncode[number];
				if(body){
					var name:String = body[0];
					var label:int = body[1];
					var type:int = body[2];
					var typeObj:Object = body[3];
				}
				//var value:Object = (MessageUtils["readtype" + type] || MessageUtils["readtype0"])(tag, bytes, typeObj);
				var value:Object;
				switch(type) {
					case 1:value = readtype1(tag, bytes, typeObj); break;
					case 2:value = readtype2(tag, bytes, typeObj); break;
					case 3:value = readtype3(tag, bytes, typeObj); break;
					case 4:value = readtype4(tag, bytes, typeObj); break;
					case 5:value = readtype5(tag, bytes, typeObj); break;
					case 6:value = readtype6(tag, bytes, typeObj); break;
					case 7:value = readtype7(tag, bytes, typeObj); break;
					case 8:value = readtype8(tag, bytes, typeObj); break;
					case 9:value = readtype9(tag, bytes, typeObj); break;
					case 10:value = readtype10(tag, bytes, typeObj); break;
					case 11:value = readtype11(tag, bytes, typeObj); break;
					case 12:value = readtype12(tag, bytes, typeObj); break;
					case 13:value = readtype13(tag, bytes, typeObj); break;
					case 14:value = readtype14(tag, bytes, typeObj); break;
					case 15:value = readtype15(tag, bytes, typeObj); break;
					case 16:value = readtype16(tag, bytes, typeObj); break;
					case 17:value = readtype17(tag, bytes, typeObj); break;
					case 18:value = readtype18(tag, bytes, typeObj); break;
					default:value = readtype0(tag, bytes, typeObj);
				}
				if(body){
					if (label == 3) {
						msg[name].push(value);
					}else {
						msg[name] = value;
					}
				}
			}
		}
		
		private static function readtype0(tag:int, bytes:Byte, typeObj:Object):Object {
			var wrieType:int = tag & 7;
			var value:Object;
			switch(wrieType) {
				case 0://Varint	int32, int64, uint32, uint64, sint32, sint64, bool, enum
					value = readVarint(bytes);
					break;
				case 2://Length-delimi	string, bytes, embedded messages, packed repeated fields
					value = readtype9(tag, bytes, typeObj);
					break;
				case 5://32-bit	fixed32, sfixed32, float
					value = bytes.getInt32();
					break;
				case 1://64-bit	fixed64, sfixed64, double
					value = bytes.getFloat64();
					break;
				//case 3://Start group	Groups (deprecated)
					//break;
				//case 4://End group	Groups (deprecated)
					//break;
				default:
					trace("read error");
			}
			return value;
		}
		private static function readtype1(tag:int, bytes:Byte, typeObj:Object):Object {
			return bytes.getFloat64();
		}
		private static function readtype2(tag:int, bytes:Byte, typeObj:Object):Object {
			return bytes.getFloat32();
		}
		private static function readtype3(tag:int, bytes:Byte, typeObj:Object):Object {
			return readVarint64(bytes);
		}
		private static function readtype4(tag:int, bytes:Byte, typeObj:Object):Object {
			return readVarint64(bytes);
		}
		private static function readtype5(tag:int, bytes:Byte, typeObj:Object):Object {
			return readVarint(bytes);
		}
		private static function readtype6(tag:int, bytes:Byte, typeObj:Object):Object {
			var v:Int64 = new Int64;
			v.low = bytes.getUint32();
			v.high = bytes.getUint32();
			return v;
		}
		private static function readtype7(tag:int, bytes:Byte, typeObj:Object):Object {
			return bytes.getInt32();
		}
		private static function readtype8(tag:int, bytes:Byte, typeObj:Object):Object {
			return readVarint(bytes)>0;
		}
		private static function readtype9(tag:int, bytes:Byte, typeObj:Object):Object {
			var blen:int = readVarint(bytes);
			if(blen>0){
				var temp:Byte = new Byte;
				temp.endian = Byte.LITTLE_ENDIAN;
				for (var i:int = 0; i < blen;i++ ){
					temp.writeByte(bytes.readByte());
				}
				
				//bytes.readBytes(temp, 0, blen);
				temp.pos = 0;
				return temp.readUTFBytes();
			}
			return "";
		}
		private static function readtype10(tag:int, bytes:Byte, typeObj:Object):Object {
			return null;
		}
		private static function readtype11(tag:int, bytes:Byte, typeObj:Object):Object {
			var blen:int = readVarint(bytes);
			var msg:Message = new typeObj as Message;
			msg.readFrom(bytes, blen);
			return msg;
		}
		private static function readtype12(tag:int, bytes:Byte, typeObj:Object):Object {
			var blen:int = readVarint(bytes);
			var temp:Byte = new Byte;
			temp.endian = Byte.LITTLE_ENDIAN;
			if (blen != 0) {
				for (var i:int = 0; i < blen;i++ ){
					temp.writeByte(bytes.readByte());
				}
				//bytes.readBytes(temp, 0, blen);
			}
			return temp;
		}
		private static function readtype13(tag:int, bytes:Byte, typeObj:Object):Object {
			return readVarint(bytes);
		}
		private static function readtype14(tag:int, bytes:Byte, typeObj:Object):Object {
			return readVarint(bytes);
		}
		private static function readtype15(tag:int, bytes:Byte, typeObj:Object):Object {
			return bytes.getUint32();
		}
		private static function readtype16(tag:int, bytes:Byte, typeObj:Object):Object {
			return readtype6(tag, bytes, typeObj);
		}
		private static function readtype17(tag:int, bytes:Byte, typeObj:Object):Object {
			return readVarint(bytes);
		}
		private static function readtype18(tag:int, bytes:Byte, typeObj:Object):Object {
			return readVarint64(bytes);
		}
		
		public static function writeTo(msg:Message,bytes:Byte):Byte {
			var messageEncode:Object = msg.mMessageEncode;
			if (messageEncode==null) {
				return null;
			}
			bytes =bytes|| new Byte;
			bytes.endian = Byte.LITTLE_ENDIAN;
			for (var numberStr:String in messageEncode) {
				var number:int = parseInt(numberStr);
				var body:Object = messageEncode[number];
				var label:int = body[1];
				if (label==1&&!msg.has(number)) {
					continue;
				}
				var name:String = body[0];
				var value:Object = msg[name];
				if (value==null) {
					continue;
				}
				var type:int = body[2];
				
				var wrieType:int = type2WrieType(type);
				var tag:int = (number << 3) | wrieType;
				if (label==3) {
					for each(var element:Object in value) {
						writeElementTo(element, type, tag, bytes);
					}
				}else {
					writeElementTo(value, type, tag, bytes);
				}
			}
			return bytes;
		}
		
		public static function writeElementTo(value:Object,type:int,tag:int,bytes:Byte):void {
			writeVarint(bytes, tag);
			switch (type) {
				case TYPE_FIXED32:
					bytes.writeInt32(value as int);
					break;
				case TYPE_SFIXED32:
					bytes.writeUint32(value as uint);
					break;
				case TYPE_FLOAT:
					bytes.writeFloat32(value as Number);
					break;
				case TYPE_DOUBLE:
				case TYPE_FIXED64:
				case TYPE_SFIXED64:
					bytes.writeFloat64(value as Number);
					break;
				case TYPE_INT32:
				case TYPE_SINT32:
				case TYPE_ENUM:
				case TYPE_UINT32:
					writeVarint(bytes, value as int);
					break;
				case TYPE_INT64:
				case TYPE_SINT64:
				case TYPE_UINT64:
					writeVarint64(bytes, value as Int64);
					break;
				case TYPE_BOOL:
					writeVarint(bytes, value?1:0);
					break;
				case TYPE_STRING:
				case TYPE_BYTES:
				case TYPE_MESSAGE:
					if (type==TYPE_MESSAGE) {
						var temp:Byte = value.writeTo(null);
					}else if (type==TYPE_BYTES) {
						temp = value as Byte;
					}else {
						temp = new Byte;
						temp.endian = Byte.LITTLE_ENDIAN;
						temp.writeUTFBytes(value as String);//, CHAR_SET);
					}
					writeVarint(bytes, temp.length);
					temp.pos = 0;
					for (var i:int = 0; i < temp.length;i++ ){
						bytes.writeByte(temp.readByte());
					}
					//bytes.writeBytes(temp, 0, temp.length);
			}
		}
		
		// Copyright (c) 2010 , NetEase.com,Inc. All rights reserved.
		// Copyright (c) 2012 , Yang Bo. All rights reserved.
		//
		// Author: Yang Bo (pop.atry@gmail.com)
		//
		// Use, modification and distribution are subject to the "New BSD License"
		// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.
		public static function readVarint(input:Byte):uint {
			var result:uint = 0
			for (var i:uint = 0;; i += 7) {
				const b:uint = input.getUint8()
				if (i < 32) {
					if (b >= 0x80) {
						result |= ((b & 0x7f) << i)
					} else {
						result |= (b << i)
						break
					}
				} else {
					while (input.getUint8() >= 0x80) {}
					break
				}
			}
			return result
		}
		
		// Copyright (c) 2010 , NetEase.com,Inc. All rights reserved.
		// Copyright (c) 2012 , Yang Bo. All rights reserved.
		//
		// Author: Yang Bo (pop.atry@gmail.com)
		//
		// Use, modification and distribution are subject to the "New BSD License"
		// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.
		public static function readVarint64(input:Byte):Int64 {
			const result:Int64 = new Int64
			var b:uint
			var i:uint = 0
			for (;; i += 7) {
				b = input.getUint8()
				if (i == 28) {
					break
				} else {
					if (b >= 0x80) {
						result.low |= ((b & 0x7f) << i)
					} else {
						result.low |= (b << i)
						return result
					}
				}
			}
			if (b >= 0x80) {
				b &= 0x7f
				result.low |= (b << i)
				result.high = b >>> 4
			} else {
				result.low |= (b << i)
				result.high = b >>> 4
				return result
			}
			for (i = 3;; i += 7) {
				b = input.getUint8()
				if (i < 32) {
					if (b >= 0x80) {
						result.high |= ((b & 0x7f) << i)
					} else {
						result.high |= (b << i)
						break
					}
				}
			}
			return result
		}
		
		// Copyright (c) 2010 , NetEase.com,Inc. All rights reserved.
		// Copyright (c) 2012 , Yang Bo. All rights reserved.
		//
		// Author: Yang Bo (pop.atry@gmail.com)
		//
		// Use, modification and distribution are subject to the "New BSD License"
		// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.
		public static function writeVarint(output:Byte,value:uint):void {
			value>>>=0;
			for (;;) {
				if (value < 0x80) {
					output.writeByte(value)
					return;
				} else {
					output.writeByte((value & 0x7F) | 0x80)
					value >>>= 7
				}
			}
		}
		
		// Copyright (c) 2010 , NetEase.com,Inc. All rights reserved.
		// Copyright (c) 2012 , Yang Bo. All rights reserved.
		//
		// Author: Yang Bo (pop.atry@gmail.com)
		//
		// Use, modification and distribution are subject to the "New BSD License"
		// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.
		public static function writeVarint64(output:Byte, value:Int64):void {
			var high:uint = value.high;
			var low:uint = value.low;
			if (high == 0) {
				writeVarint(output, low)
			} else {
				for (var i:uint = 0; i < 4; ++i) {
					output.writeByte((low & 0x7F) | 0x80)
					low >>>= 7
				}
				if ((high & (0xFFFFFFF << 3)) == 0) {
					output.writeByte((high << 4) | low)
				} else {
					output.writeByte((((high << 4) | low) & 0x7F) | 0x80)
					writeVarint(output, high >>> 3)
				}
			}
		}
		public static function type2WrieType(type:int):int {
			switch (type) {
				case TYPE_FIXED32:
				case TYPE_SFIXED32:
				case TYPE_FLOAT:
					return 5;
				case TYPE_DOUBLE:
				case TYPE_FIXED64:
				case TYPE_SFIXED64:
					return 1;
				case TYPE_INT32:
				case TYPE_SINT32:
				case TYPE_ENUM:
				case TYPE_UINT32:
				case TYPE_INT64:
				case TYPE_SINT64:
				case TYPE_UINT64:
				case TYPE_BOOL:
					return 0;
				case TYPE_STRING:
				case TYPE_MESSAGE:
				case TYPE_BYTES:
					return 2;
			}
			return -1;
		}
		
		private static const TYPE_DOUBLE:int=1;
		private static const TYPE_FLOAT:int=2;
		private static const TYPE_INT64:int=3;
		private static const TYPE_UINT64:int=4;
		private static const TYPE_INT32:int=5;
		private static const TYPE_FIXED64:int=6;
		private static const TYPE_FIXED32:int=7;
		private static const TYPE_BOOL:int=8;
		private static const TYPE_STRING:int=9;
		private static const TYPE_GROUP:int=10;
		private static const TYPE_MESSAGE:int=11;
		private static const TYPE_BYTES:int=12;
		private static const TYPE_UINT32:int=13;
		private static const TYPE_ENUM:int=14;
		private static const TYPE_SFIXED32:int=15;
		private static const TYPE_SFIXED64:int=16;
		private static const TYPE_SINT32:int=17;
		private static const TYPE_SINT64:int=18;
		
	}

}
