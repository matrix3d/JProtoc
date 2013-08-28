JProtoc
=======

protoc with as3 will js etc

code just like <a href='http://code.google.com/p/protobuf/'>protobuf</a>.

put YourMsg.as and jprotoc_as3/src to your project

<pre>
//write
var msg:YourMsg=new YourMsg;
msg.field1=1;
var bytes:ByteArray = msg.writeTo(null);

//read
var msg:YourMsg=new YourMsg;
msg.readFrom(input,len);
trace(msg.field1);
</pre>

compile
--------

1.download protobuf 2.5 from the protobuf main page.

2.download JProtoc from the git.

3.enter bat fold.and change the path with your path protobuf and jProtoc.

4.run jprotocas3app.bat.and your can get the YourMsg.as
