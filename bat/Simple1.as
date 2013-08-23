package {
import lz.jprotoc.Int64;
import lz.jprotoc.Message;
public class Simple1 extends Message{

public var name:String;
public var id:int;
public var email:String;

public function Simple1(){messageEncode={1:["name",2,9],2:["id",2,5],3:["email",1,9]}}
}}